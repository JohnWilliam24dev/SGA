import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart';

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass_app_shell.dart';
import 'status_settings_panel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.statusRepository});

  final StatusRepository statusRepository;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          child: ValueListenableBuilder<AppThemeMode>(
            valueListenable: sgaThemeMode,
            builder: (context, mode, child) {
              final dark = mode == AppThemeMode.dark;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aparência',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: sgaOnSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha como prefere visualizar o SGA.',
                    style: TextStyle(color: sgaMuted),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Modo escuro'),
                    subtitle: Text(dark ? 'Ativado' : 'Desativado'),
                    value: dark,
                    onChanged: (enabled) => sgaThemeMode.value = enabled
                        ? AppThemeMode.dark
                        : AppThemeMode.light,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        StatusSettingsPanel(repository: statusRepository),
      ],
    ),
  );
}
