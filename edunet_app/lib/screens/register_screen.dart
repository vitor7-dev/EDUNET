import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../state/auth_state.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _cpf = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    for (final c in [_nome, _email, _telefone, _cpf, _senha, _confirma]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await context.read<AuthState>().cadastrar(
            nome: _nome.text,
            email: _email.text,
            senha: _senha.text,
            telefone: _telefone.text,
            cpf: _cpf.text.replaceAll(RegExp(r'\D'), ''),
          );
      // Fecha a tela de cadastro: o AuthGate (main.dart) ja mostra a Home.
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.message, erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const campo = TextStyle(color: Colors.white);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: gradienteAuth),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24 + kToolbarHeight, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Theme(
                  data: temaAuth(context),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    decoration: decoracaoVidro(),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            child: const Icon(Icons.person_rounded, size: 56, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cadastro',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Crie sua conta agora',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _nome,
                            style: campo,
                            cursorColor: Colors.white,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline)),
                            validator: (v) => (v == null || v.trim().length < 3) ? 'Informe seu nome completo.' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            style: campo,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '') ? null : 'Informe um e-mail válido.',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefone,
                            style: campo,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Telefone com DDD (opcional)', prefixIcon: Icon(Icons.phone_outlined)),
                            validator: (v) {
                              final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                              if (d.isEmpty) return null;
                              return (d.length == 10 || d.length == 11) ? null : 'Digite o telefone com DDD.';
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cpf,
                            style: campo,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'CPF (opcional, só números)', prefixIcon: Icon(Icons.badge_outlined)),
                            validator: (v) {
                              final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                              if (d.isEmpty) return null;
                              return d.length == 11 ? null : 'CPF deve ter 11 números.';
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senha,
                            style: campo,
                            cursorColor: Colors.white,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Senha (mínimo 6 caracteres)', prefixIcon: Icon(Icons.lock_outline)),
                            validator: (v) => (v == null || v.length < 6) ? 'A senha deve ter pelo menos 6 caracteres.' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirma,
                            style: campo,
                            cursorColor: Colors.white,
                            obscureText: true,
                            onFieldSubmitted: (_) => _cadastrar(),
                            decoration: const InputDecoration(labelText: 'Confirmar senha', prefixIcon: Icon(Icons.lock_reset)),
                            validator: (v) => v == _senha.text ? null : 'As senhas não coincidem.',
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _carregando ? null : _cadastrar,
                            child: _carregando
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: corAzulEscuro),
                                  )
                                : const Text('Cadastrar'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Já possui conta? Fazer login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
