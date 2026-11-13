import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late Future<List<Chamado>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = ApiClient.instance.meusChamados();
  }

  Future<void> _recarregar() async {
    final f = ApiClient.instance.meusChamados();
    setState(() => _futuro = f);
    try {
      await f;
    } catch (_) {}
  }

  Future<void> _novoChamado() async {
    final criou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NovoChamadoSheet(),
    );
    if (criou == true) _recarregar();
  }

  // Apenas visual: cores e rótulo do chip conforme o status (os valores vindos da API não mudam).
  ({Color fundo, Color texto}) _coresStatus(String s) => switch (s) {
        'Resolvido' => (fundo: const Color(0xFFDCFCE7), texto: const Color(0xFF166534)),
        'EmAndamento' => (fundo: const Color(0xFFFEF3C7), texto: const Color(0xFF92400E)),
        _ => (fundo: const Color(0xFFDBEAFE), texto: const Color(0xFF1E40AF)),
      };

  String _rotuloStatus(String s) => s == 'EmAndamento' ? 'Em andamento' : s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoChamado,
        icon: const Icon(Icons.add),
        label: const Text('Novo chamado'),
      ),
      body: FutureBuilder<List<Chamado>>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(onPressed: _recarregar, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
                ]),
              ),
            );
          }
          final lista = snap.data!;
          if (lista.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.support_agent_outlined, size: 56, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 12),
                    Text('Nenhum chamado aberto.\nToque em "Novo chamado" para falar com o suporte 24h.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: lista.length,
              itemBuilder: (_, i) {
                final c = lista[i];
                final cores = _coresStatus(c.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
                    title: Text(c.assunto, style: const TextStyle(fontWeight: FontWeight.w700, color: corTexto)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${c.descricao}\nAberto em ${formatarData(c.abertura)}'),
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(
                        _rotuloStatus(c.status),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cores.texto),
                      ),
                      backgroundColor: cores.fundo,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NovoChamadoSheet extends StatefulWidget {
  const _NovoChamadoSheet();

  @override
  State<_NovoChamadoSheet> createState() => _NovoChamadoSheetState();
}

class _NovoChamadoSheetState extends State<_NovoChamadoSheet> {
  final _form = GlobalKey<FormState>();
  final _assunto = TextEditingController();
  final _descricao = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _assunto.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final msg = await ApiClient.instance.abrirChamado(_assunto.text.trim(), _descricao.text.trim());
      if (!mounted) return;
      mostrarMensagem(context, msg);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.message, erro: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Novo chamado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: corTexto),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assunto,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Assunto', hintText: 'Ex.: Internet lenta', prefixIcon: Icon(Icons.title)),
              validator: (v) => (v == null || v.trim().length < 3) ? 'Informe o assunto.' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descricao,
              maxLength: 500,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Descreva o problema', alignLabelWithHint: true),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Descreva com pelo menos 10 caracteres.' : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Enviar chamado'),
            ),
          ],
        ),
      ),
    );
  }
}
