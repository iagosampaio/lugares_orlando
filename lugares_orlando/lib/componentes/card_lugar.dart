import 'package:flutter/material.dart';
import 'package:lugares_orlando/estado.dart';

class CardLugar extends StatefulWidget {
  final dynamic lugar;

  const CardLugar(this.lugar, {super.key});

  @override
  State<CardLugar> createState() {
    return CardLugarState();
  }
}

class CardLugarState extends State<CardLugar> {
  @override
  Widget build(BuildContext context) {
    final List<dynamic> fotosLugar = widget.lugar["fotos"];
    String primeiraFoto = fotosLugar.isNotEmpty ? fotosLugar[0].toString() : '';

    Color corEntrada = Colors.black;
    if (widget.lugar["entrada"] == "Entrada Paga") {
      corEntrada = Colors.red;
    } else if (widget.lugar["entrada"] == "Entrada Gratuita") {
      corEntrada = const Color.fromARGB(255, 22, 141, 6);
    } 

    return SizedBox(
      height: 350,
      child: GestureDetector(
        onTap: () {
          estadoApp.mostrarDetalhes(widget.lugar["_id"]);
        },
        child: Card(
          elevation: 4, // Adiciona sombra ao card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: const Color.fromARGB(255, 3, 199, 248),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              primeiraFoto.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: Image.asset('assets/imgs/$primeiraFoto'),
                    )
                  : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  widget.lugar["nome"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Aumenta o tamanho da fonte
                    color: Color.fromARGB(255, 0, 17, 255), // Muda a cor do título
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 5, bottom: 10),
                child: Text(
                  widget.lugar["descricao"],
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255), // Muda a cor do texto da descrição
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      widget.lugar["entrada"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: corEntrada, // Cor condicional da entrada
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red, // Muda a cor do ícone de curtidas
                          size: 18,
                        ),
                        Text(
                          widget.lugar["likes"].toString(),
                          style: const TextStyle(
                            color: Colors.red, // Muda a cor do número de curtidas
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}