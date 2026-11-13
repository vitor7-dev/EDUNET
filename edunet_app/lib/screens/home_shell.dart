import 'package:flutter/material.dart';

import '../theme.dart';
import 'my_contracts_screen.dart';
import 'plans_screen.dart';
import 'profile_screen.dart';
import 'support_screen.dart';

/// Estrutura principal: barra de navegacao inferior com 4 abas.
/// As abas nao ficam em IndexedStack de proposito: cada troca recarrega os dados.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  static const _titulos = ['Planos', 'Minhas contratações', 'Suporte', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final telas = [
      PlansScreen(onContratado: () => setState(() => _indice = 1)),
      const MyContractsScreen(),
      const SupportScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        // Logo azul + título, como o cabeçalho do site
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: corPrimaria, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(_titulos[_indice], overflow: TextOverflow.ellipsis)),
          ],
        ),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: SafeArea(child: telas[_indice]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.speed_outlined), selectedIcon: Icon(Icons.speed), label: 'Planos'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Contratos'),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'Suporte'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
