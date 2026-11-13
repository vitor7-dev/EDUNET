import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_state.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthState>().usuario!;
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: corPrimaria,
            child: Text(
              u.nome.isNotEmpty ? u.nome[0].toUpperCase() : '?',
              style: tema.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(u.nome, style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: corTexto))),
        Center(child: Text(u.email)),
        const SizedBox(height: 20),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: corPrimaria),
                title: const Text('Perfil'),
                subtitle: Text(u.perfil),
              ),
              if (u.telefone != null && u.telefone!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: corPrimaria),
                  title: const Text('Telefone'),
                  subtitle: Text(u.telefone!),
                ),
            ],
          ),
        ),
        const Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(Icons.accessibility_new, color: corPrimaria),
            title: Text('Acessibilidade'),
            subtitle: Text(
              'O app respeita o tamanho de fonte do sistema, possui leitura por TalkBack/VoiceOver, '
              'botões grandes e contraste adequado. Para texto maior, use Ajustes > Acessibilidade do celular.',
            ),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: tema.colorScheme.error,
            side: BorderSide(color: tema.colorScheme.error, width: 1.5),
          ),
          onPressed: () async {
            final sair = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sair da conta?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(80, 44)),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sair'),
                  ),
                ],
              ),
            );
            if (sair == true && context.mounted) await context.read<AuthState>().sair();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ],
    );
  }
}
