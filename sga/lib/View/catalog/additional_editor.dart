import 'package:easy_ui/easy_ui.dart' show Toast, ToastType;
import 'package:flutter/material.dart' show RadioGroup, RadioListTile;
import 'package:flutter/widgets.dart';

import '../../Domain/models/adicional_model.dart';
import 'editor_fields.dart';
import 'editor_sheet.dart';

enum PriceRule { fixed, percent }

/// O que o editor de adicional devolve ao salvar.
class AdditionalDraft {
  const AdditionalDraft({
    required this.name,
    required this.description,
    required this.rule,
    required this.value,
    required this.enabled,
  });

  final String name;
  final String description;
  final PriceRule rule;
  final double value;
  final bool enabled;
}

/// Editor de adicional: nome, descrição, regra de preço (fixo ou
/// porcentagem sobre o preço base) e habilitado.
class AdditionalEditor extends StatefulWidget {
  const AdditionalEditor({super.key, required this.initial});

  final AdicionalModel? initial;

  @override
  State<AdditionalEditor> createState() => _AdditionalEditorState();
}

class _AdditionalEditorState extends State<AdditionalEditor> {
  late final _name = TextEditingController(text: widget.initial?.nome);
  late final _description = TextEditingController(
    text: widget.initial?.descricao,
  );
  late final _value = TextEditingController(
    text: (widget.initial?.porcentagem ?? widget.initial?.precoFixo)
        ?.toStringAsFixed(2),
  );
  late PriceRule _rule = widget.initial?.porcentagem != null
      ? PriceRule.percent
      : PriceRule.fixed;
  late bool _enabled = widget.initial?.habilitado ?? true;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _value.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_value.text.replaceAll(',', '.'));
    if (_name.text.trim().isEmpty || value == null || value < 0) {
      Toast.show(
        context,
        text: 'Informe nome e valor válido.',
        type: ToastType.warning,
      );
      return;
    }
    Navigator.of(context).pop(
      AdditionalDraft(
        name: _name.text.trim(),
        description: _description.text.trim(),
        rule: _rule,
        value: value,
        enabled: _enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = _rule == PriceRule.percent;
    return EditorSheet(
      title: widget.initial == null ? 'Novo adicional' : 'Editar adicional',
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorTextField(controller: _name, label: 'Nome'),
          const SizedBox(height: 14),
          EditorTextField(
            controller: _description,
            label: 'Descrição (opcional)',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const EditorHeading('Regra de preço'),
          const SizedBox(height: 4),
          RadioGroup<PriceRule>(
            groupValue: _rule,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _rule = value;
                _value.clear();
              });
            },
            child: const Column(
              children: [
                RadioListTile<PriceRule>(
                  contentPadding: EdgeInsets.zero,
                  value: PriceRule.fixed,
                  title: Text('Preço fixo'),
                  subtitle: Text('Ex.: R\$ 15,00'),
                ),
                RadioListTile<PriceRule>(
                  contentPadding: EdgeInsets.zero,
                  value: PriceRule.percent,
                  title: Text('Porcentagem'),
                  subtitle: Text('Aplicada sobre o preço base do produto.'),
                ),
              ],
            ),
          ),
          EditorTextField(
            key: ValueKey(_rule),
            controller: _value,
            label: percent ? 'Porcentagem (%)' : 'Valor fixo (R\$)',
            decimal: true,
          ),
          const SizedBox(height: 10),
          EnabledField(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}
