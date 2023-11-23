// ignore_for_file: avoid_print, constant_identifier_names

import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lugares_orlando/apis/servicos.dart';
import 'package:lugares_orlando/autenticador.dart';
import 'package:lugares_orlando/componentes/card_lugar.dart';
import 'package:lugares_orlando/estado.dart';

class Lugares extends StatefulWidget {
  const Lugares({super.key});

  @override
  State<StatefulWidget> createState() => LugaresState();
}

const TAMANHO_DA_PAGINA = 4;

class LugaresState extends State<Lugares> {
  List<dynamic> _lugares = [];

  String _filtro = "";
  late TextEditingController _controladorFiltro;

  bool _carregando = false;
  int _proximaPagina = 1;

  late ServicoLugares _servicoLugares;

  @override
  void initState() {
    _controladorFiltro = TextEditingController();
    _recuperarUsuarioLogado();

    _servicoLugares = ServicoLugares();
    _carregarLugares();

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

  void _carregarLugares() {
    setState(() {
      _carregando = true;
    });

    if (_filtro.isNotEmpty) {
      _servicoLugares
          .findLugares(_proximaPagina, TAMANHO_DA_PAGINA, _filtro)
          .then((lugares) {
        setState(() {
          _carregando = false;
          _proximaPagina += 1;

          _lugares.addAll(lugares);
        });
      });
    } else {
      _servicoLugares
          .getLugares(_proximaPagina, TAMANHO_DA_PAGINA)
          .then((lugares) {
        setState(() {
          _carregando = false;
          _proximaPagina += 1;

          _lugares.addAll(lugares);
        });
      });
    }
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
                  // usar onChanged quando a filtragem jah ocorrer enquanto o
                  // usuario digitas
                  // onChanged: (texto) {
                  //   _filtro = texto;
                  // },
                  // usar onSubmitted quando a filtragem tiver que ocorrer
                  // depois do usuario digitar e confirmar
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
                                msg: "você não está mais conectado");

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
                                msg: "você foi conectado com sucesso");

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
            print(item);

            return CardLugar(item);
          },
          listEmptyWidget: Container(
              alignment: Alignment.center,
              child: const Text("Não existem lugares para exibir :(")),
        ));
  }
}
