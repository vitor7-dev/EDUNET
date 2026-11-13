import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';

class AuthState extends ChangeNotifier {
  final _api = ApiClient.instance;
  Usuario? usuario;

  bool get logado => usuario != null;

  /// Restaura a sessao salva (token no armazenamento seguro).
  Future<void> init() async {
    await _api.carregarToken();
    if (!_api.temToken) return;
    try {
      usuario = await _api.me();
    } on ApiException catch (e) {
      // Token invalido/expirado: descarta. Sem rede: tambem volta ao login.
      if (e.statusCode == 401) await _api.salvarToken(null);
    }
  }

  Future<void> login(String email, String senha) async {
    usuario = await _api.login(email.trim(), senha);
    notifyListeners();
  }

  Future<void> cadastrar({required String nome, required String email, required String senha, String? telefone, String? cpf}) async {
    usuario = await _api.cadastrar(nome: nome.trim(), email: email.trim(), senha: senha, telefone: telefone?.trim(), cpf: cpf?.trim());
    notifyListeners();
  }

  Future<void> sair() async {
    await _api.salvarToken(null);
    usuario = null;
    notifyListeners();
  }
}
