import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../theme.dart';
import 'contract_screen.dart';

class PlansScreen extends StatefulWidget {
  final VoidCallback onContratado;
  const PlansScreen({super.key, required this.onContratado});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Future<({List<Plano> planos, bool doCache})> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = ApiClient.instance.planos();
  }

  Future<void> _recarregar() async {
    final f = ApiClient.instance.planos();
    setState(() => _futuro = f);
    try {
      await f;
    } catch (_) {}
  }

  Future<void> _contratar(Plano p) async {
    final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ContractScreen(plano: p)));
    if (ok == true) widget.onContratado();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _Erro(mensagem: snap.error.toString(), onTentar: _recarregar);
        }
        final dados = snap.data!;
        final tema = Theme.of(context);
        return RefreshIndicator(
          onRefresh: _recarregar,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
                child: Column(
                  children: [
                    Text(
                      'Escolha Seu Plano Ideal',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: corTexto),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todos os planos incluem fibra óptica, sem fidelidade e instalação grátis.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (dados.doCache)
                const Card(
                  color: Color(0xFFFFF4CE),
                  child: ListTile(
                    leading: Icon(Icons.cloud_off),
                    title: Text('Você está offline'),
                    subtitle: Text('Mostrando os planos salvos da última sincronização. Puxe para atualizar.'),
                  ),
                ),
              for (final p in dados.planos) _PlanoCard(plano: p, onContratar: () => _contratar(p)),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  '* Valores promocionais para novos clientes.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanoCard extends StatelessWidget {
  final Plano plano;
  final VoidCallback onContratar;
  const _PlanoCard({required this.plano, required this.onContratar});

  // Mesmo destaque do site: o plano "Plus" recebe o selo "Mais Popular".
  bool get _popular => plano.nome.trim().toLowerCase() == 'plus';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final popular = _popular;
    return Semantics(
      label: 'Plano ${plano.nome}, ${plano.velocidadeTexto}, ${plano.precoTexto} por mês',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, popular ? 14 : 0, 0, 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              margin: EdgeInsets.zero,
              elevation: popular ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: popular ? corPrimaria : corBorda, width: popular ? 2 : 1),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      plano.nome,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: corTexto),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plano.velocidadeTexto,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: corPrimaria),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: plano.precoTexto,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: corTexto),
                        ),
                        const TextSpan(text: ' /mês', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                      ]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _Beneficio(plano.descricao),
                    const _Beneficio('Download e upload simétricos'),
                    const _Beneficio('Instalação grátis'),
                    const _Beneficio('Sem fidelidade'),
                    const _Beneficio('Suporte técnico 24h'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onContratar,
                      style: popular ? null : FilledButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), foregroundColor: corTexto),
                      child: const Text('Assinar Agora'),
                    ),
                  ],
                ),
              ),
            ),
            if (popular)
              Positioned(
                top: -12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(color: corPrimaria, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Mais Popular', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Beneficio extends StatelessWidget {
  final String texto;
  const _Beneficio(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check, size: 18, color: corTexto),
            const SizedBox(width: 8),
            Expanded(child: Text(texto)),
          ],
        ),
      );
}

class _Erro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentar;
  const _Erro({required this.mensagem, required this.onTentar});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(mensagem, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: onTentar, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
}
