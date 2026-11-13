import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../theme.dart';

class MyContractsScreen extends StatefulWidget {
  const MyContractsScreen({super.key});

  @override
  State<MyContractsScreen> createState() => _MyContractsScreenState();
}

class _MyContractsScreenState extends State<MyContractsScreen> {
  late Future<List<Contratacao>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = ApiClient.instance.minhasContratacoes();
  }

  Future<void> _recarregar() async {
    final f = ApiClient.instance.minhasContratacoes();
    setState(() => _futuro = f);
    try {
      await f;
    } catch (_) {}
  }

  Future<void> _cancelar(Contratacao c) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar plano?'),
        content: Text('Deseja cancelar o plano ${c.nomePlano}? Você pode contratar outro depois.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar plano'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    try {
      await ApiClient.instance.cancelar(c.id);
      if (mounted) mostrarMensagem(context, 'Plano cancelado.');
      _recarregar();
    } on ApiException catch (e) {
      if (mounted) mostrarMensagem(context, e.message, erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contratacao>>(
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
                  Icon(Icons.receipt_long_outlined, size: 56, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 12),
                  Text('Você ainda não contratou nenhum plano.\nAcesse a aba Planos para começar.', textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        final tema = Theme.of(context);
        return RefreshIndicator(
          onRefresh: _recarregar,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final c = lista[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${c.nomePlano} - ${c.velocidadeTexto}',
                              style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: corTexto),
                            ),
                          ),
                          Chip(
                            label: Text(
                              c.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.ativa ? const Color(0xFF1E40AF) : const Color(0xFF4B5563),
                              ),
                            ),
                            backgroundColor: c.ativa ? const Color(0xFFDBEAFE) : const Color(0xFFF3F4F6),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatarPreco(c.preco) + ' /mês',
                        style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: corPrimaria),
                      ),
                      const SizedBox(height: 10),
                      Text('Instalação: ${c.endereco}'),
                      Text('Contratado em ${formatarData(c.data)}'),
                      if (c.dataCancelamento != null) Text('Cancelado em ${formatarData(c.dataCancelamento!)}'),
                      if (c.ativa) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: tema.colorScheme.error),
                            onPressed: () => _cancelar(c),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancelar plano'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
