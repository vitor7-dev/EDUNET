import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../theme.dart';

class ContractScreen extends StatefulWidget {
  final Plano plano;
  const ContractScreen({super.key, required this.plano});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final _form = GlobalKey<FormState>();
  final _endereco = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final msg = await ApiClient.instance.contratar(widget.plano.id, _endereco.text);
      if (!mounted) return;
      mostrarMensagem(context, msg);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.message, erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plano;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar contratação')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: corPrimaria, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.bolt, color: corPrimaria, size: 36),
                      title: Text(
                        '${p.nome} - ${p.velocidadeTexto}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: corTexto),
                      ),
                      subtitle: Text('${p.precoTexto} por mês. Sem fidelidade.'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _endereco,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Endereço de instalação',
                    hintText: 'Rua, número, bairro, cidade',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().length < 8) ? 'Informe o endereço completo.' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _carregando ? null : _confirmar,
                  child: _carregando
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Confirmar contratação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
