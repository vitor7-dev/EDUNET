import 'package:flutter/material.dart';

// ---- Paleta alinhada ao site EDUNET ----
const corPrimaria = Color(0xFF2563EB); // azul dos botões do site
const corAzulEscuro = Color(0xFF1E3A8A);
const corFundo = Color(0xFFF8FAFC); // cinza-azulado claro das páginas
const corTexto = Color(0xFF111827); // quase preto
const corBorda = Color(0xFFE5E7EB); // cinza claro de bordas

// Degradê azul-escuro -> azul (fundo das telas de login e cadastro no site)
const gradienteAuth = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF111B33), Color(0xFF1E3A8A), Color(0xFF2563EB)],
);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: corPrimaria,
    primary: corPrimaria,
    surface: Colors.white,
  );
  final raio = BorderRadius.circular(10);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: corFundo,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: corTexto,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: corTexto, fontSize: 20, fontWeight: FontWeight.w700),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: corBorda),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: raio, borderSide: const BorderSide(color: corBorda)),
      enabledBorder: OutlineInputBorder(borderRadius: raio, borderSide: const BorderSide(color: corBorda)),
      focusedBorder: OutlineInputBorder(borderRadius: raio, borderSide: const BorderSide(color: corPrimaria, width: 2)),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52), // alvo de toque grande (acessibilidade)
        backgroundColor: corPrimaria,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: corPrimaria,
        side: const BorderSide(color: corPrimaria, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: corPrimaria),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Color(0xFFDBEAFE),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: corPrimaria,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),

    chipTheme: const ChipThemeData(side: BorderSide.none, shape: StadiumBorder()),

    dividerTheme: const DividerThemeData(color: corBorda),
  );
}

/// Tema local para telas sobre o fundo em degradê (login e cadastro):
/// campos translúcidos com texto branco e botão branco com texto azul-escuro.
ThemeData temaAuth(BuildContext context) {
  OutlineInputBorder borda(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c, width: w),
      );
  const erroClaro = Color(0xFFFECACA);
  return Theme.of(context).copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(255, 255, 255, 0.18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
      errorStyle: const TextStyle(color: erroClaro),
      border: borda(const Color.fromRGBO(255, 255, 255, 0.25)),
      enabledBorder: borda(const Color.fromRGBO(255, 255, 255, 0.25)),
      focusedBorder: borda(Colors.white, 2),
      errorBorder: borda(erroClaro),
      focusedErrorBorder: borda(erroClaro, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: Colors.white,
        foregroundColor: corAzulEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
    ),
  );
}

/// Cartão translúcido central das telas de login e cadastro.
BoxDecoration decoracaoVidro() => BoxDecoration(
      color: const Color.fromRGBO(255, 255, 255, 0.14),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.25)),
      boxShadow: const [
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 30, offset: Offset(0, 12)),
      ],
    );

void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: erro ? scheme.error : null,
      behavior: SnackBarBehavior.floating,
    ));
}
