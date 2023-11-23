// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lugares_orlando/autenticador.dart';

final URL_SERVICOS = Uri.parse("http://10.0.2.2");

final URL_LUGARES = "${URL_SERVICOS.toString()}:5001/lugares";
final URL_LUGAR = "${URL_SERVICOS.toString()}:5001/lugar";

final URL_COMENTARIOS = "${URL_SERVICOS.toString()}:5002/comentarios";
final URL_ADICIONAR_COMENTARIO = "${URL_SERVICOS.toString()}:5002/adicionar";
final URL_REMOVER_COMENTARIO = "${URL_SERVICOS.toString()}:5002/remover";

final URL_CURTIU = "${URL_SERVICOS.toString()}:5003/curtiu";
final URL_CURTIR = "${URL_SERVICOS.toString()}:5003/curtir";
final URL_DESCURTIR = "${URL_SERVICOS.toString()}:5003/descurtir";

final URL_ARQUIVOS = "${URL_SERVICOS.toString()}:5005";

class ServicoLugares {
  Future<List<dynamic>> getLugares(int pagina, int tamanhoPagina) async {
    final resposta = await http
        .get(Uri.parse("${URL_LUGARES.toString()}/$pagina/$tamanhoPagina"));
    final lugares = jsonDecode(resposta.body);

    return lugares;
  }

  Future<List<dynamic>> findLugares(
      int pagina, int tamanhoPagina, String nome) async {
    final resposta = await http.get(
        Uri.parse("${URL_LUGARES.toString()}/$pagina/$tamanhoPagina/$nome"));
    final lugares = jsonDecode(resposta.body);

    return lugares;
  }

  Future<Map<String, dynamic>> findLugar(int idLugar) async {
    final resposta =
        await http.get(Uri.parse("${URL_LUGAR.toString()}/$idLugar"));
    final lugares = jsonDecode(resposta.body);

    return lugares;
  }
}

class ServicoCurtidas {
  Future<bool> curtiu(Usuario usuario, int idLugar) async {
    final resposta = await http
        .get(Uri.parse("${URL_CURTIU.toString()}/${usuario.email}/$idLugar"));
    final resultado = jsonDecode(resposta.body);

    return resultado["curtiu"] as bool;
  }

  Future<dynamic> curtir(Usuario usuario, int idLugar) async {
    final resposta = await http.post(
        Uri.parse("${URL_CURTIR.toString()}/${usuario.email}/$idLugar"));

    return jsonDecode(resposta.body);
  }

  Future<dynamic> descurtir(Usuario usuario, int idLugar) async {
    final resposta = await http.post(
        Uri.parse("${URL_DESCURTIR.toString()}/${usuario.email}/$idLugar"));

    return jsonDecode(resposta.body);
  }
}

class ServicoComentarios {
  Future<List<dynamic>> getComentarios(
      int idLugar, int pagina, int tamanhoPagina) async {
    final resposta = await http.get(Uri.parse(
        "${URL_COMENTARIOS.toString()}/$idLugar/$pagina/$tamanhoPagina"));
    final comentarios = jsonDecode(resposta.body);

    return comentarios;
  }

  Future<dynamic> adicionar(
      int idLugar, Usuario usuario, String comentario) async {
    final resposta = await http.post(Uri.parse(
        "${URL_ADICIONAR_COMENTARIO.toString()}/$idLugar/${usuario.nome}/${usuario.email}/$comentario"));

    return jsonDecode(resposta.body);
  }

  Future<dynamic> remover(int idComentario) async {
    final resposta = await http.delete(
        Uri.parse("${URL_REMOVER_COMENTARIO.toString()}/$idComentario"));

    return jsonDecode(resposta.body);
  }
}

String caminhoArquivo(String arquivo) {
  return "${URL_ARQUIVOS.toString()}/$arquivo";
}
