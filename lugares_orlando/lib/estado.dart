// ignore_for_file: unnecessary_getters_setters
import 'package:flutter/material.dart';

import 'autenticador.dart';

enum Situacao { mostrandoLugares, mostrandoDetalhes }

class EstadoApp extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoLugares;
  Situacao get situacao => _situacao;
  set situacao(Situacao situacao) {
    _situacao = situacao;
  }

  int _idLugar = 0;
  int get idLugar => _idLugar;
  set idLugar(int idLugar) {
    _idLugar = idLugar;
  }

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  set usuario(Usuario? usuario) {
    _usuario = usuario;
  }

  void mostrarLugares() {
    situacao = Situacao.mostrandoLugares;

    notifyListeners();
  }

  void mostrarDetalhes(int idLugar) {
    situacao = Situacao.mostrandoDetalhes;
    this.idLugar = idLugar;

    notifyListeners();
  }

  void onLogin(Usuario usuario) {
    _usuario = usuario;

    notifyListeners();
  }

  void onLogout() {
    _usuario = null;

    notifyListeners();
  }

  bool temUsuarioLogado() {
    return _usuario != null;
  }
}

late EstadoApp estadoApp;
