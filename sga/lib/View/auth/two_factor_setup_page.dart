import 'dart:async';

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'recovery_codes_step.dart';
import 'two_factor_qr_step.dart';

/// Ativação obrigatória do 2FA (sessão restrita): primeiro o QR e a
/// confirmação do código, depois os códigos de recuperação, exibidos uma
/// única vez. Só ao continuar a sessão vira completa e o app abre.
class TwoFactorSetupPage extends StatefulWidget {
  const TwoFactorSetupPage({
    super.key,
    required this.onCarregar,
    required this.onConfirmar,
    required this.onConcluir,
    required this.onLogout,
  });

  /// Devolve `null` se a conta já tem 2FA ativo.
  final Future<DoisFatorInicio?> Function() onCarregar;
  final Future<List<String>> Function(String codigo) onConfirmar;
  final Future<void> Function() onConcluir;
  final VoidCallback onLogout;

  @override
  State<TwoFactorSetupPage> createState() => _TwoFactorSetupPageState();
}

class _TwoFactorSetupPageState extends State<TwoFactorSetupPage> {
  List<String>? _codigos;

  @override
  Widget build(BuildContext context) {
    final codigos = _codigos;
    return AuthShell(
      child: Div(
        width: 100.pct,
        align: Alignment.center,
        children: [
          const Reveal(child: SgaLogo(size: 54)),
          Card(
            variant: CardVariant.glass,
            child: codigos != null
                ? RecoveryCodesStep(codigos: codigos, onConcluir: widget.onConcluir)
                : AsyncView<DoisFatorInicio?>(
                    load: widget.onCarregar,
                    loading: const Padding(
                      padding: EdgeInsets.all(32),
                      child: Loader(message: 'Preparando a verificação...'),
                    ),
                    error: (context, erro, tentarDeNovo) => ErrorState(
                      description: erro is UserFacingException ? erro.message : null,
                      onRetry: tentarDeNovo,
                    ),
                    empty: EmptyState(
                      title: 'Verificação em duas etapas já ativa',
                      description: 'Sua conta já está protegida. Continue para abrir o SGA.',
                      action: Button(text: 'Continuar', onPressed: _continuar),
                    ),
                    builder: (context, inicio) => TwoFactorQrStep(
                      inicio: inicio!,
                      onConfirmar: (codigo) async {
                        final lista = await widget.onConfirmar(codigo);
                        if (mounted) setState(() => _codigos = lista);
                      },
                    ),
                  ),
          ),
          if (codigos == null)
            Button(text: 'Sair', variant: ButtonVariant.link, onPressed: widget.onLogout),
        ],
      ),
    );
  }

  Future<void> _continuar() async {
    try {
      await widget.onConcluir();
    } on UserFacingException catch (e) {
      if (mounted) Toast.error(context, text: e.message);
    }
  }
}
