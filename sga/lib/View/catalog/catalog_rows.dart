import 'package:flutter/material.dart' show Switch;
import 'package:flutter/widgets.dart';

import '../../Core/theme/sga_theme.dart';
import '../../Shared/formatters.dart';
import 'catalog_entries.dart';

/// Rótulo pequeno em cima e valor embaixo, numa coluna de largura fixa.
class RowField extends StatelessWidget {
  const RowField(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.disabled,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 135,
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Interruptor "Habilitado" / "Desabilitado" de uma linha.
class StatusSwitch extends StatelessWidget {
  const StatusSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(
          value ? 'Habilitado' : 'Desabilitado',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value ? colors.success : colors.disabled,
          ),
        ),
      ],
    );
  }
}

class TypeRow extends StatelessWidget {
  const TypeRow({super.key, required this.item, required this.onEnabled});

  final CatalogType item;
  final ValueChanged<bool> onEnabled;

  @override
  Widget build(BuildContext context) {
    final total = item.additionalIds.length;
    return Wrap(
      spacing: 28,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RowField('Nome', item.model.nome),
        RowField('Preço base', formatarMoeda(item.model.precoBase)),
        RowField('Adicionais', '$total vinculado${total == 1 ? '' : 's'}'),
        StatusSwitch(value: item.model.habilitado, onChanged: onEnabled),
      ],
    );
  }
}

class AdditionalRow extends StatelessWidget {
  const AdditionalRow({super.key, required this.item, required this.onEnabled});

  final CatalogAdditional item;
  final ValueChanged<bool> onEnabled;

  @override
  Widget build(BuildContext context) {
    final model = item.model;
    final pct = model.porcentagem;
    final regra = model.precoFixo != null
        ? formatarMoeda(model.precoFixo!)
        : '${pct!.toStringAsFixed(pct % 1 == 0 ? 0 : 2)}% do preço base';
    return Wrap(
      spacing: 28,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RowField('Nome', model.nome),
        RowField('Descrição', model.descricao ?? '—'),
        RowField('Preço/regra', regra),
        StatusSwitch(value: model.habilitado, onChanged: onEnabled),
      ],
    );
  }
}
