import 'package:easy_ui/easy_ui.dart' show Button, ButtonVariant;
import 'package:flutter/material.dart' show SwitchListTile;
import 'package:flutter/widgets.dart';

import '../../Core/theme/sga_theme.dart';

/// Moldura dos editores (folha que sobe de baixo): título, o formulário e os
/// botões Cancelar e Salvar.
class EditorSheet extends StatelessWidget {
  const EditorSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: SgaColors.of(context).heading,
                ),
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    Button(
                      text: 'Cancelar',
                      variant: ButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Button(text: 'Salvar', onPressed: onSave),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interruptor "Habilitado" dos editores, com a explicação embaixo.
class EnabledField extends StatelessWidget {
  const EnabledField({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: const Text('Habilitado'),
      subtitle: Text(
        value ? 'Disponível em novos pedidos.' : 'Oculto dos novos pedidos.',
      ),
    );
  }
}
