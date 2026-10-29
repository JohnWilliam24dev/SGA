import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import 'google_section.dart';
import 'orcamento_section.dart';
import 'two_factor_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.doisFator,
    this.config,
    this.onVincularGoogle,
  });

  /// Vincula a conta Google; sem ele, a seção Conta Google some.
  final Future<bool> Function()? onVincularGoogle;

  /// Modalidade de orçamento; sem ele, a seção some.
  final ConfigMakerRepository? config;

  /// Gestão do 2FA; sem ele (testes de layout), a seção Segurança some.
  final DoisFatorRepository? doisFator;

  @override
  Widget build(BuildContext context) => Card(
    child: ValueListenableBuilder<AppThemeMode>(
      valueListenable: sgaThemeMode,
      builder: (context, mode, _) {
        final dark = mode == AppThemeMode.dark;
        return Div(
          width: 100.pct,
          children: [
            const Label(type: LabelType.title, text: 'Aparência'),
            const Label(
              type: LabelType.caption,
              text: 'Escolha como prefere visualizar o SGA.',
            ),
            Div(
              direction: ResponsiveDirection(mobile: LayoutDirection.horizontal),
              align: Alignment.centerLeft,
              children: [
                LayoutItem(
                  size: 1.fr,
                  child: Div(
                    gap: 0.px,
                    children: [
                      const Label(text: 'Modo escuro'),
                      Label(
                        type: LabelType.caption,
                        text: dark ? 'Ativado' : 'Desativado',
                      ),
                    ],
                  ),
                ),
                Toggle(
                  value: dark,
                  onChanged: (enabled) => sgaThemeMode.value = enabled
                      ? AppThemeMode.dark
                      : AppThemeMode.light,
                ),
              ],
            ),
            if (config != null) OrcamentoSection(repository: config!),
            if (onVincularGoogle != null)
              GoogleSection(onVincular: onVincularGoogle!),
            if (doisFator != null) TwoFactorSection(repository: doisFator!),
          ],
        );
      },
    ),
  );
}
