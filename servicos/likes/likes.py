from flask import Flask, jsonify
import mysql.connector as mysql

servico = Flask("likes")

SERVIDOR_BANCO = "banco"
USUARIO_BANCO = "root"
SENHA_BANCO = "admin"
NOME_BANCO = "pontosturisticos"

def get_conexao_com_bd():
    conexao = mysql.connect(host=SERVIDOR_BANCO, user=USUARIO_BANCO, password=SENHA_BANCO, database=NOME_BANCO)

    return conexao

@servico.get("/info")
def get_info():
    return jsonify(
        descricao = "gerenciamento de curtidas do pontos turísticos - orlando",
        versao = "1.0"
    )

@servico.get("/likes_por_feed/<int:id_do_feed>")
def likes_por_lugar(id_do_feed):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT count(*) as quantidade " +  
        "FROM likes " +
        "WHERE likes.feed = " + str(id_do_feed)
    )
    likes = cursor.fetchone()

    conexao.close()

    return jsonify(curtidas = likes["quantidade"])

@servico.get("/curtiu/<string:conta>/<int:id_do_feed>")
def curtiu(conta, id_do_feed):
    conexao = get_conexao_com_bd()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT count(*) as quantidade " +  
        "FROM likes " +
        "WHERE likes.feed = " + str(id_do_feed) + " AND likes.email = '" + conta + "'"
    )
    likes = cursor.fetchone()

    conexao.close()

    return jsonify(curtiu = likes["quantidade"] > 0)

@servico.post("/curtir/<string:conta>/<int:id_do_feed>")
def curtir(conta, id_do_feed):
    resultado = jsonify(situacao = "ok", erro = "")

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    try:
        cursor.execute(f"INSERT INTO likes(feed, email) VALUES ({str(id_do_feed)}, '{conta}')")
        conexao.commit()
    except:
        conexao.rollback()
        resultado = jsonify(situacao = "erro", erro = "erro curtindo o lugar")

    conexao.close()

    return resultado

@servico.post("/descurtir/<string:conta>/<int:id_do_feed>")
def descurtir(conta, id_do_feed):
    resultado = jsonify(situacao = "ok", erro = "")

    conexao = get_conexao_com_bd()
    cursor = conexao.cursor()
    try:
        cursor.execute(f"DELETE FROM likes WHERE feed = {str(id_do_feed)} AND email = '{conta}'")
        conexao.commit()
    except:
        conexao.rollback()
        resultado = jsonify(situacao = "erro", erro = "erro descurtindo o lugar")

    conexao.close()

    return resultado


if __name__ == "__main__":
    servico.run(host="0.0.0.0", debug=True)