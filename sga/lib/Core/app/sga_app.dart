import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Data/data.dart';
import '../../Domain/domain.dart';
import '../network/network.dart';
import '../theme/sga_theme.dart';
import 'auth_scope.dart';
import 'sessao_gate.dart';

/// Raiz do SGA: tema azul explícito, pack próprio e a navegação por sessão.
///
/// Sem [sessao] e [auth], usa auth simulada em memória (testes e demo). O
/// `main` passa as versões reais.
class SgaApp extends StatefulWidget {
  const SgaApp({super.key, this.sessao, this.auth})
      : assert(
          (sessao == null) == (auth == null),
          'Informe sessao e auth juntos, ou nenhum.',
        );

  final SessaoStore? sessao;
  final AuthRepository? auth;

  @override
  State<SgaApp> createState() => _SgaAppState();
}

class _SgaAppState extends State<SgaApp> {
  late final SessaoStore _sessao =
      widget.sessao ?? SessaoStore(MemoryTokenStorage());
  late final AuthRepository _auth = widget.auth ?? FakeAuthRepository(_sessao);

  @override
  void dispose() {
    if (widget.sessao == null) _sessao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      auth: _auth,
      sessao: _sessao,
      child: ValueListenableBuilder<AppThemeMode>(
        valueListenable: sgaThemeMode,
        builder: (context, mode, child) => EasyApp(
          title: 'SGA',
          theme: AppTheme(mode: mode, light: sgaTheme.light, dark: sgaTheme.dark),
          stylePack: sgaPack,
          home: const SessaoGate(),
        ),
      ),
    );
  }
}
