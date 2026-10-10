import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../routes.dart';
import '../theme/sga_theme.dart';

/// Raiz do SGA: tema azul explícito, pack próprio e a tela inicial.
class SgaApp extends StatefulWidget {
  const SgaApp({super.key});

  @override
  State<SgaApp> createState() => _SgaAppState();
}

class _SgaAppState extends State<SgaApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: sgaThemeMode,
      builder: (context, mode, child) => EasyApp(
        title: 'SGA',
        theme: AppTheme(mode: mode, light: sgaTheme.light, dark: sgaTheme.dark),
        stylePack: sgaPack,
        home: Builder(builder: buildWelcomeScreen),
      ),
    );
  }
}
