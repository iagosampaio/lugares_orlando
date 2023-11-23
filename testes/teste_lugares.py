import unittest
import urllib.request
import json

URL_LUGARES = "http://localhost:5001/lugares"
URL_LUGAR = "http://localhost:5001/lugar"

TAMANHO_DA_PAGINA = 4
NOME_DO_LUGAR = "parque"

class TesteLugares(unittest.TestCase):

    def acessar(self, url):
        resposta = urllib.request.urlopen(url)
        dados = resposta.read()
        return dados.decode("utf-8")
        
    def testar_01_lazy_loading(self):
        dados = self.acessar(f"{URL_LUGARES}/1/{TAMANHO_DA_PAGINA}")
        lugares = json.loads(dados)

        self.assertEqual(len(lugares), TAMANHO_DA_PAGINA)
        self.assertEqual(lugares[0]['lugar_id'], 1)

    def testar_02_pesquisa_lugar_pelo_id(self):
        dados = self.acessar(f"{URL_LUGAR}/1")
        lugar = json.loads(dados)

        self.assertEqual(lugar['lugar_id'], 1)

    def testar_03_pesquisa_lugar_pelo_nome(self):
        dados = self.acessar(f"{URL_LUGARES}/1/{TAMANHO_DA_PAGINA}/{NOME_DO_LUGAR}")
        lugares = json.loads(dados)

        for lugar in lugares:
            self.assertIn(NOME_DO_LUGAR, lugar['nome_lugar'].lower())