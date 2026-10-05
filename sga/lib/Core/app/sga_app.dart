import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../routes.dart';
import '../theme/sga_theme.dart';

/// Raiz do SGA: tema azul explícito, pack próprio e a tela inicial.
class SgaApp extends StatelessWidget {
  const SgaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyApp(
      title: 'SGA',
      theme: sgaTheme,
      stylePack: sgaPack,
      home: Builder(builder: buildWelcomeScreen),
    );
  }
}
