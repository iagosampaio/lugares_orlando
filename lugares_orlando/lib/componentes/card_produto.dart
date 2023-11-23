// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:lugares_orlando/apis/servicos.dart';
import 'package:lugares_orlando/estado.dart';

class CardLugar extends StatefulWidget {
  final dynamic lugar;

  const CardLugar(this.lugar, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CardLugarState();
  }
}

class CardLugarState extends State<CardLugar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 330,
        child: GestureDetector(
            onTap: () {
              estadoApp.mostrarDetalhes(widget.lugar["lugar_id"]);
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                      child: Image.network(
                          caminhoArquivo(widget.lugar["imagem1"]))),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            widget.lugar["nome_lugar"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ))
                    ]),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, top: 5, bottom: 10),
                    child: Text(
                      widget.lugar["descricao"],
                    ),
                  ),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        widget.lugar["entrada"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                          Text(
                            widget.lugar["curtidas"].toString(),
                          ),
                        ],
                      ),
                    )
                  ])
                ],
              ),
            )));
  }
}
