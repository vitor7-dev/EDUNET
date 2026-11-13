import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

/// Cliente HTTP unico do app: injeta o JWT, trata erros e mantem cache offline dos planos.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _storage = const FlutterSecureStorage();
  String? _token;

  bool get temToken => _token != null;

  Future<void> carregarToken() async => _token = await _storage.read(key: 'jwt');

  Future<void> salvarToken(String? token) async {
    _token = token;
    if (token == null) {
      await _storage.delete(key: 'jwt');
    } else {
      await _storage.write(key: 'jwt', value: token);
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(const Duration(seconds: 15));
      final body = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
      if (r.statusCode >= 200 && r.statusCode < 300) return body;
      if (r.statusCode == 401 && _token != null) {
        throw ApiException('Sua sessao expirou. Faca login novamente.', 401);
      }
      throw ApiException(_mensagemDeErro(body, r.statusCode), r.statusCode);
    } on SocketException {
      throw ApiException('Sem conexao com o servidor. Verifique sua internet e o endereco da API.');
    } on TimeoutException {
      throw ApiException('O servidor demorou para responder. Tente novamente.');
    } on http.ClientException {
      throw ApiException('Nao foi possivel conectar ao servidor.');
    } on FormatException {
      throw ApiException('Resposta inesperada do servidor.');
    }
  }

  String _mensagemDeErro(dynamic body, int status) {
    if (body is Map) {
      if (body['mensagem'] is String) return body['mensagem'] as String;
      // Erros de validacao do ASP.NET (ProblemDetails)
      final erros = body['errors'];
      if (erros is Map && erros.isNotEmpty) {
        final primeiro = erros.values.first;
        if (primeiro is List && primeiro.isNotEmpty) return primeiro.first.toString();
      }
    }
    return 'Erro $status ao processar a requisicao.';
  }

  // ---------- Autenticacao ----------
  Future<Usuario> login(String email, String senha) async {
    final b = await _send(() => http.post(_uri('/api/auth/login'),
        headers: _headers, body: jsonEncode({'email': email, 'senha': senha})));
    await salvarToken(b['token'] as String);
    return Usuario.fromJson(b['usuario'] as Map<String, dynamic>);
  }

  Future<Usuario> cadastrar({required String nome, required String email, required String senha, String? telefone, String? cpf}) async {
    final b = await _send(() => http.post(_uri('/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'telefone': (telefone == null || telefone.isEmpty) ? null : telefone,
          'cpf': (cpf == null || cpf.isEmpty) ? null : cpf,
        })));
    await salvarToken(b['token'] as String);
    return Usuario.fromJson(b['usuario'] as Map<String, dynamic>);
  }

  Future<Usuario> me() async {
    final b = await _send(() => http.get(_uri('/api/auth/me'), headers: _headers));
    return Usuario.fromJson(b as Map<String, dynamic>);
  }

  // ---------- Planos (com cache offline = sincronizacao de dados) ----------
  /// Retorna os planos e um flag indicando se vieram do cache local.
  Future<({List<Plano> planos, bool doCache})> planos() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final b = await _send(() => http.get(_uri('/api/planos'), headers: _headers)) as List;
      final lista = b.map((e) => Plano.fromJson(e as Map<String, dynamic>)).toList();
      await prefs.setString('planos_cache', jsonEncode(lista.map((p) => p.toJson()).toList()));
      return (planos: lista, doCache: false);
    } on ApiException {
      final cache = prefs.getString('planos_cache');
      if (cache == null) rethrow;
      final lista = (jsonDecode(cache) as List).map((e) => Plano.fromJson(e as Map<String, dynamic>)).toList();
      return (planos: lista, doCache: true);
    }
  }

  // ---------- Contratacoes ----------
  Future<List<Contratacao>> minhasContratacoes() async {
    final b = await _send(() => http.get(_uri('/api/contratacoes/minhas'), headers: _headers)) as List;
    return b.map((e) => Contratacao.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> contratar(int idPlano, String endereco) async {
    final b = await _send(() => http.post(_uri('/api/contratacoes'),
        headers: _headers, body: jsonEncode({'idPlano': idPlano, 'endereco': endereco})));
    return (b['mensagem'] as String?) ?? 'Plano contratado!';
  }

  Future<void> cancelar(int idContratacao) async {
    await _send(() => http.post(_uri('/api/contratacoes/$idContratacao/cancelar'), headers: _headers));
  }

  // ---------- Suporte ----------
  Future<List<Chamado>> meusChamados() async {
    final b = await _send(() => http.get(_uri('/api/chamados/meus'), headers: _headers)) as List;
    return b.map((e) => Chamado.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> abrirChamado(String assunto, String descricao) async {
    final b = await _send(() => http.post(_uri('/api/chamados'),
        headers: _headers, body: jsonEncode({'assunto': assunto, 'descricao': descricao})));
    return (b['mensagem'] as String?) ?? 'Chamado aberto!';
  }
}
