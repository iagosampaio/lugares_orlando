// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lugares_orlando/autenticador.dart';
import 'package:lugares_orlando/componentes/card_lugar.dart';
import 'package:lugares_orlando/estado.dart';

class Lugares extends StatefulWidget {
  const Lugares({super.key});

  @override
  State<StatefulWidget> createState() => LugaresState();
}

const tamanhoDaPagina = 4;

class LugaresState extends State<Lugares> {
  late dynamic _feedEstatico;
  List<dynamic> _lugares = [];

  String _filtro = "";
  late TextEditingController _controladorFiltro;

  bool _carregando = false;
  int _proximaPagina = 1;

  @override
  void initState() {
    _lerFeedEstatico();
    _controladorFiltro = TextEditingController();

    _recuperarUsuarioLogado();

    super.initState();
  }

  void _recuperarUsuarioLogado() {
    Autenticador.recuperarUsuario().then((usuario) {
      if (usuario != null) {
        setState(() {
          estadoApp.onLogin(usuario);
        });
      }
    });
  }

  Future<void> _lerFeedEstatico() async {
    final stringJson = await rootBundle.loadString('assets/json/feed.json');
    _feedEstatico = await json.decode(stringJson);

    _carregarLugares();
  }

  void _carregarLugares() {
    setState(() {
      _carregando = true;
    });

    var maisLugares = [];

    if (_filtro.isNotEmpty) {
      List<dynamic> lugares = _feedEstatico['pontos_turisticos'];
      lugares.where((item) {
        String nomeLugar = item['nome'];
        String tipoEntrada = item['entrada'];
        return nomeLugar.toLowerCase().contains(_filtro.toLowerCase()) ||
        tipoEntrada.toLowerCase().contains(_filtro.toLowerCase());
      }).forEach((item) {
        maisLugares.add(item);
      });
    } else {
      maisLugares = _lugares;
      final totalDeFeedsParaCarregar = _proximaPagina * tamanhoDaPagina;
      if (_feedEstatico['pontos_turisticos'].length >= totalDeFeedsParaCarregar) {
        maisLugares =
            _feedEstatico['pontos_turisticos'].sublist(0, totalDeFeedsParaCarregar);
      } else {
        maisLugares = _feedEstatico['pontos_turisticos'];
      }
    }

    setState(() {
      _carregando = false;
      _proximaPagina += 1;

      _lugares = maisLugares;
    });
  }

  Future<void> _atualizarLugares() async {
    _lugares = [];
    _proximaPagina = 1;

    _carregarLugares();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const SizedBox.shrink(),
          actions: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                  controller: _controladorFiltro,
                  onSubmitted: (texto) {
                    _filtro = texto;

                    _atualizarLugares();
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search))),
            )),
            Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: estadoApp.temUsuarioLogado()
                    ? GestureDetector(
                        onTap: () {
                          Autenticador.logout().then((_) {
                            Fluttertoast.showToast(
                                msg: "Você não está mais conectado.");

                            setState(() {
                              estadoApp.onLogout();
                            });
                          });
                        },
                        child: const Icon(Icons.logout, size: 30))
                    : GestureDetector(
                        onTap: () {
                          Autenticador.login().then((usuario) {
                            Fluttertoast.showToast(
                                msg: "Você foi conectado com sucesso.");

                            setState(() {
                              estadoApp.onLogin(usuario);
                            });
                          });
                        },
                        child: const Icon(Icons.person, size: 30)))
          ],
        ),
        body: FlatList(
          data: _lugares,
          loading: _carregando,
          numColumns: 2,
          onRefresh: () {
            _filtro = "";
            _controladorFiltro.clear();

            return _atualizarLugares();
          },
          onEndReached: () {
            _carregarLugares();
          },
          onEndReachedDelta: 200,
          buildItem: (item, int index) {
            return CardLugar(item);
          },
          listEmptyWidget: Container(
              alignment: Alignment.center,
              child: const Text("Não existem lugares para exibir :(")),
        ));
  }
}
