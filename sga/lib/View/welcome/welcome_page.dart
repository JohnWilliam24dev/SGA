import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show ElevatedButton, TextButton;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/shared.dart';

/// Tela inicial do SGA: marca, pulso animado e as duas portas de entrada,
/// Cadastre-se e Login. Não conhece as próximas telas: avisa por callbacks.
class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  final VoidCallback onRegister;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Div(
        width: 100.pct,
        align: Alignment.center,
        gap: 14.px,
        children: [
          const FadeIn(child: SgaLogo()),
          const FadeIn(
            delay: Duration(milliseconds: 150),
            child: Label(
              type: LabelType.title,
              text: 'SGA',
              textAlign: TextAlign.center,
            ),
          ),
          const FadeIn(
            delay: Duration(milliseconds: 250),
            child: Label(
              text: 'Sistema de Gerenciamento Artístico',
              textAlign: TextAlign.center,
            ),
          ),
          const FadeIn(delay: Duration(milliseconds: 350), child: PulseLine()),
          const FadeIn(
            delay: Duration(milliseconds: 600),
            child: Label(
              type: LabelType.caption,
              text: 'Sua arte, sua agenda e seus clientes em um só lugar.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          FadeIn(
            delay: const Duration(milliseconds: 750),
            child: Div(
              width: 100.pct,
              gap: 12.px,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087FEA),
                      foregroundColor: const Color(0xFFFFFFFF),
                    ),
                    child: const Text('Cadastre-se'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF053A68),
                    ),
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
