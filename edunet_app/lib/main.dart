import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/auth_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthState();
  await auth.init();
  runApp(ChangeNotifierProvider.value(value: auth, child: const EdunetApp()));
}

class EdunetApp extends StatelessWidget {
  const EdunetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EDUNET',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: Consumer<AuthState>(
        builder: (_, auth, __) => auth.logado ? const HomeShell() : const LoginScreen(),
      ),
    );
  }
}
