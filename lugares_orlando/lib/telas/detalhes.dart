import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:share_plus/share_plus.dart';

import '../estado.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() => DetalhesState();
}

const tamanhoDaPagina = 4;

class DetalhesState extends State<Detalhes> {
  late dynamic _feedEstatico;
  late dynamic _comentariosEstaticos;

  late PageController _controladorSlides;
  late int _slideSelecionado;

  bool _temLugar = false;
  dynamic _lugar;

  bool _temComentarios = false;
  List<dynamic> _comentarios = [];
  late TextEditingController _controladorNovoComentario;
  bool _carregandoComentarios = false;

  int _proximaPagina = 1;

  bool _curtiu = false;
  bool _tecladoVisivel = false;

  @override
  void initState() {
    _lerBancoEstatico();
    _iniciarSlides();

    _controladorNovoComentario = TextEditingController();

    super.initState();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<void> _lerBancoEstatico() async {
    String stringJson = await rootBundle.loadString('assets/json/feed.json');
    _feedEstatico = await json.decode(stringJson);

    stringJson = await rootBundle.loadString('assets/json/comentarios.json');
    _comentariosEstaticos = await json.decode(stringJson);

    _carregarLugar();
    _carregarComentarios();
  }

  void _carregarLugar() {
    _lugar = _feedEstatico['pontos_turisticos']
        .firstWhere((lugar) => lugar['_id'] == estadoApp.idLugar);

    setState(() {
      _temLugar = _lugar != null;

      _carregandoComentarios = false;
    });
  }

  void _carregarComentarios() {
    setState(() {
      _carregandoComentarios = true;
    });

    var maisComentarios = [];
    _comentariosEstaticos['comentarios'].where((item) {
      return item['feed_correspondente'] == estadoApp.idLugar;
    }).forEach((item) {
      maisComentarios.add(item);
    });

    final totalDeComentariosParaCarregar = _proximaPagina * tamanhoDaPagina;
    if (maisComentarios.length >= totalDeComentariosParaCarregar) {
      maisComentarios =
          maisComentarios.sublist(0, totalDeComentariosParaCarregar);
    }

    setState(() {
      _temComentarios = maisComentarios.isNotEmpty;
      _comentarios = maisComentarios;

      _proximaPagina += 1;

      _carregandoComentarios = false;
    });
  }

  Future<void> _atualizarComentarios() async {
    _comentarios = [];
    _proximaPagina = 1;

    _carregarComentarios();
  }

  void _adicionarComentario() {
    if (estadoApp.usuario != null) {
      final comentario = {
        "conteudo": _controladorNovoComentario.text, 
        "nome": estadoApp.usuario!.nome,        
        "data_e_horario": DateTime.now().toString(),
        "feed_correspondente": estadoApp.idLugar
      };

      setState(() {
        _comentarios.insert(0, comentario);
      });
    }
  }

  String _formatarData(String dataHora) {
    DateTime dateTime = DateTime.parse(dataHora);
    DateFormat formatador = DateFormat("dd/MM/yyyy HH:mm");

    return formatador.format(dateTime);
  }

  Widget _exibirMensagemComentariosInexistentes() {
    return const Center(
        child: Padding(
            padding: EdgeInsets.all(14.0),
            child: Text('Não existem comentários sobre este lugar',
                style: TextStyle(color: Colors.black, fontSize: 14))));
  }

  List<Widget> _exibirComentarios() {
    return [
      const Center(
          child: Text(
        "Comentários",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      )),
      estadoApp.temUsuarioLogado()
          ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: TextField(
                  controller: _controladorNovoComentario,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: 'Digite aqui seu comentário...',
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _adicionarComentario();
                          },
                          child: const Icon(Icons.send)))))
          : const SizedBox.shrink(),
      _temComentarios
          ? Expanded(
              child: FlatList(
              data: _comentarios,
              loading: _carregandoComentarios,
              numColumns: 1,
              onRefresh: () {
                _controladorNovoComentario.clear();

                return _atualizarComentarios();
              },
              onEndReached: () {
                _carregarComentarios();
              },
              onEndReachedDelta: 200,
              buildItem: (item, int index) {
                return Dismissible(
                    key: Key(_comentarios[index]['_id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.red,
                        child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: Icon(Icons.delete)))),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        final comentario = _comentarios[index];
                        setState(() {
                          _comentarios.removeAt(index);
                        });

                        showDialog(
                            context: context,
                            builder: (BuildContext contexto) {
                              return AlertDialog(
                                title:
                                    const Text("Deseja apagar o comentário?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _comentarios.insert(
                                              index, comentario);
                                        });

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("não")),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {});

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("sim"))
                                ],
                              );
                            });
                      }
                    },
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              _comentarios[index]["conteudo"],
                              style: const TextStyle(fontSize: 12),
                            )),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, left: 6.0),
                                    child: Text(
                                      _comentarios[index]["nome"],
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      _formatarData(
                                          _comentarios[index]["data_e_horario"]),
                                      style: const TextStyle(fontSize: 12),
                                    )),
                              ],
                            )),
                      ],
                    )));
              },
              listEmptyWidget: Container(
                  alignment: Alignment.center,
                  child: const Text("Não existem lugares para exibir :(")),
            ))
          : _exibirMensagemComentariosInexistentes()
    ];
  }

Widget _exibirLugar() {
  List<Widget> widgets = [];

  if (!_tecladoVisivel) {
    widgets.addAll([
      SizedBox(
        height: 230,
        child: Stack(children: [
          PageView.builder(
            itemCount: _lugar['fotos'].length, // Quantidade de fotos do lugar
            controller: _controladorSlides,
            onPageChanged: (slide) {
              setState(() {
                _slideSelecionado = slide;
              });
            },
            itemBuilder: (context, pagePosition) {
              return Image.asset(
                'assets/imgs/${_lugar["fotos"][pagePosition]}', // Caminho da imagem
                fit: BoxFit.cover,
              );
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Column(children: [
              estadoApp.temUsuarioLogado()
                  ? IconButton(
                      onPressed: () {
                        if (_curtiu) {
                          setState(() {
                            _lugar['likes'] = _lugar['likes'] - 1;
                            _curtiu = false;
                          });
                        } else {
                          setState(() {
                            _lugar['likes'] = _lugar['likes'] + 1;
                            _curtiu = true;
                          });
                        }
                      },
                      icon: Icon(
                        _curtiu ? Icons.favorite : Icons.favorite_border,
                      ),
                      color: Colors.red,
                      iconSize: 32)
                  : const SizedBox.shrink(),
              IconButton(
                onPressed: () {
                  final texto =
                      'Vamos para o ${_lugar["nome"]} em Orlando? \n\n\nBaixe o Pontos Turísticos - Orlando na PlayStore!';
                  Share.share(texto);
                },
                icon: const Icon(Icons.share),
                color: Colors.blue,
                iconSize: 32,
              ),
            ]),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: PageViewDotIndicator(
          currentItem: _slideSelecionado,
          count: _lugar['fotos'].length, // Quantidade de fotos do lugar
          unselectedColor: Colors.black26,
          selectedColor: Colors.blue,
          duration: const Duration(milliseconds: 200),
          boxShape: BoxShape.circle,
        ),
      ),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _temLugar
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _lugar["nome"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            _temLugar
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(_lugar["descricao"],
                        style: const TextStyle(fontSize: 12)),
                  )
                : const SizedBox.shrink(),
            _temLugar
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                    child: Row(
                      children: [
                        Text(
                          _lugar["entrada"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              Text(
                                _lugar["likes"].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    ]);
  }
    widgets.addAll(_exibirComentarios());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              estadoApp.mostrarLugares();
            },
            child: const Icon(Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _exibirMensagemLugarInexistente() {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton(
              onPressed: () {
                estadoApp.mostrarLugares();
              },
              child: const Icon(Icons.arrow_back))),
      const Material(
          color: Colors.transparent,
          child: Text('Lugar não existe ou foi removido :-(',
              style: TextStyle(color: Colors.black, fontSize: 14))),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibility(
        onChanged: (bool visivel) {
          setState(() {
            _tecladoVisivel = visivel;
          });
        },
        child: _temLugar
            ? _exibirLugar()
            : _exibirMensagemLugarInexistente());
  }
}