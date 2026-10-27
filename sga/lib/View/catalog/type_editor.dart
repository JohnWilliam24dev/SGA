import 'package:easy_ui/easy_ui.dart' show Toast, ToastType;
import 'package:flutter/material.dart'
    show CheckboxListTile, Divider, ListTileControlAffinity;
import 'package:flutter/widgets.dart';

import '../../Domain/models/adicional_model.dart';
import '../../Core/theme/sga_theme.dart';
import 'catalog_entries.dart';
import 'catalog_limits.dart';
import 'editor_fields.dart';
import 'editor_sheet.dart';

/// O que o editor de tipo devolve ao salvar.
class TypeDraft {
  const TypeDraft({
    required this.name,
    required this.basePrice,
    required this.enabled,
    required this.additionalIds,
  });

  final String name;
  final double basePrice;
  final bool enabled;
  final Set<String> additionalIds;
}

/// Editor de tipo de produto: nome, preço base, habilitado e os adicionais
/// que esse tipo pode oferecer.
class TypeEditor extends StatefulWidget {
  const TypeEditor({super.key, required this.initial, required this.additionals});

  final CatalogType? initial;
  final List<AdicionalModel> additionals;

  @override
  State<TypeEditor> createState() => _TypeEditorState();
}

class _TypeEditorState extends State<TypeEditor> {
  late final _name = TextEditingController(text: widget.initial?.model.nome);
  late final _price = TextEditingController(
    text: widget.initial?.model.precoBase.toStringAsFixed(2),
  );
  late bool _enabled = widget.initial?.model.habilitado ?? true;
  late final Set<String> _selected = {...?widget.initial?.additionalIds};

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  void _aviso(String texto) =>
      Toast.show(context, text: texto, type: ToastType.warning);

  void _save() {
    final value = double.tryParse(_price.text.replaceAll(',', '.'));
    final erro = erroDoTipo(
      nome: _name.text,
      preco: value,
      vinculados: _selected.length,
    );
    if (erro != null) return _aviso(erro);
    Navigator.of(context).pop(
      TypeDraft(
        name: _name.text.trim(),
        basePrice: value!,
        enabled: _enabled,
        additionalIds: _selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditorSheet(
      title: widget.initial == null
          ? 'Novo tipo de produto'
          : 'Editar tipo de produto',
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorTextField(controller: _name, label: 'Nome'),
          const SizedBox(height: 14),
          EditorTextField(
            controller: _price,
            label: 'Preço base (R\$)',
            decimal: true,
          ),
          const SizedBox(height: 10),
          EnabledField(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          const Divider(height: 28),
          const EditorHeading('Adicionais vinculados'),
          const SizedBox(height: 4),
          Text(
            'Marque os adicionais que poderão ser escolhidos neste tipo.',
            style: TextStyle(
              fontSize: 12,
              color: SgaColors.of(context).muted,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.additionals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Nenhum adicional cadastrado ainda.'),
            )
          else
            for (final add in widget.additionals)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _selected.contains(add.id),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(add.nome),
                subtitle: Text(add.habilitado ? 'Habilitado' : 'Desabilitado'),
                onChanged: (value) => setState(() {
                  if (value ?? false) {
                    _selected.add(add.id);
                  } else {
                    _selected.remove(add.id);
                  }
                }),
              ),
        ],
      ),
    );
  }
}
