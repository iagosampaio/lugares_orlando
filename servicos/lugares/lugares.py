from flask import Flask, jsonify
from urllib.request import urlopen
import mysql.connector as mysql
import json

servico = Flask("lugares")

SERVIDOR_BANCO = "banco"
USUARIO_BANCO = "root"
SENHA_BANCO = "admin"
NOME_BANCO = "pontosturisticos"

def get_conexao_com_bd():
    conexao = mysql.connect(host=SERVIDOR_BANCO, user=USUARIO_BANCO, password=SENHA_BANCO, database=NOME_BANCO)

    return conexao


URL_LIKES = "http://likes:5000/likes_por_feed/"
def get_quantidade_de_curtidas(id_do_feed):
    url = URL_LIKES + str(id_do_feed)
    resposta = urlopen(url)
    resposta = resposta.read()
    resposta = json.loads(resposta)

    return resposta["curtidas"]

@servico.get("/info")
def get_info():
    return jsonify(
        descricao = "gerenciamento de lugares do pontos turísticos - orlando",
        versao = "1.0"
    )

@servico.get("/lugares/<int:pagina>/<int:tamanho_da_pagina>")
def get_lugares(pagina, tamanho_da_pagina):
    lugares = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute(
        "SELECT feeds.id as lugar_id, DATE_FORMAT(feeds.data, '%Y-%m-%d %H:%i') as data, " +
        "lugares.nome as nome_lugar, lugares.descricao, lugares.entrada as entrada, " +
        "lugares.imagem1, IFNULL(lugares.imagem2, '') as imagem2, IFNULL(lugares.imagem3, '') as imagem3 " +
        "FROM feeds, lugares " +
        "WHERE lugares.id = feeds.lugar " +
        "ORDER BY data desc " +
        "LIMIT " + str((pagina - 1) * tamanho_da_pagina) + ", " + str(tamanho_da_pagina)
    )
    lugares = cursor.fetchall()
    if lugares:
        for lugar in lugares:
            lugar["curtidas"] = get_quantidade_de_curtidas(lugar['lugar_id'])

    conexao.close()

    return jsonify(lugares)

@servico.get("/lugares/<int:pagina>/<int:tamanho_da_pagina>/<string:nome_do_lugar>")
def find_lugares(pagina, tamanho_da_pagina, nome_do_lugar):
    lugares = []

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute(
        "SELECT feeds.id as lugar_id, DATE_FORMAT(feeds.data, '%Y-%m-%d %H:%i') as data, " +
        "lugares.nome as nome_lugar, lugares.descricao, lugares.entrada as entrada, " +
        "lugares.imagem1, IFNULL(lugares.imagem2, '') as imagem2, IFNULL(lugares.imagem3, '') as imagem3 " +
        "FROM feeds, lugares " +
        "WHERE lugares.id = feeds.lugar " +
        "AND lugares.nome LIKE '%" + nome_do_lugar + "%' "  +
        "ORDER BY data desc " +
        "LIMIT " + str((pagina - 1) * tamanho_da_pagina) + ", " + str(tamanho_da_pagina)
    )
    lugares = cursor.fetchall()
    if lugares:
        for lugar in lugares:
            lugar["curtidas"] = get_quantidade_de_curtidas(lugar['lugar_id'])

    conexao.close()

    return jsonify(lugares)

@servico.get("/lugar/<int:id_do_feed>")
def find_lugar(id_do_feed):
    lugar = {}

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute(
        "SELECT feeds.id as lugar_id, DATE_FORMAT(feeds.data, '%Y-%m-%d %H:%i') as data, " +
        "lugares.nome as nome_lugar, lugares.descricao, lugares.entrada as entrada, " +
        "lugares.imagem1, IFNULL(lugares.imagem2, '') as imagem2, IFNULL(lugares.imagem3, '') as imagem3 " +
        "FROM feeds, lugares " +
        "WHERE lugares.id = feeds.lugar " +
        "AND feeds.id = " + str(id_do_feed)
    )
    lugar = cursor.fetchone()
    if lugar:
        lugar["curtidas"] = get_quantidade_de_curtidas(id_do_feed)

    conexao.close()

    return jsonify(lugar)


if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)