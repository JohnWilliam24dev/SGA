import 'package:easy_ui/easy_ui.dart' show Modal, Toast, ToastType;
import 'package:flutter/widgets.dart';

import '../../Domain/models/adicional_model.dart';
import '../../Domain/models/tipo_produto_model.dart';
import 'additional_editor.dart';
import 'catalog_entries.dart';
import 'type_editor.dart';

/// Ações do catálogo (criar, editar, excluir) sobre as listas em memória de
/// quem usa este mixin. Cada ação avisa o resultado por um Toast.
mixin CatalogActions<T extends StatefulWidget> on State<T> {
  List<CatalogType> get types;
  List<CatalogAdditional> get additionals;

  void _ok(String text) =>
      Toast.show(context, text: text, type: ToastType.success);

  void _erro(String text) =>
      Toast.show(context, text: text, type: ToastType.error);

  Future<bool> _confirmaExclusao(String title) async {
    final ok = await Modal.confirm(
      context,
      title: title,
      message: 'Esta ação não pode ser desfeita.',
      confirmText: 'Excluir',
      destructive: true,
    );
    return (ok ?? false) && mounted;
  }

  Future<void> editType([CatalogType? entry]) async {
    final draft = await Modal.sheet<TypeDraft>(
      context,
      builder: (_) => TypeEditor(
        initial: entry,
        additionals: [for (final a in additionals) a.model],
      ),
    );
    if (draft == null || !mounted) return;
    final model = TipoProdutoModel(
      id: entry?.model.id ?? 'type-${DateTime.now().microsecondsSinceEpoch}',
      nome: draft.name,
      precoBase: draft.basePrice,
      habilitado: draft.enabled,
    );
    final novo = CatalogType(
      model: model,
      additionalIds: draft.additionalIds,
      protected: entry?.protected ?? false,
    );
    setState(() {
      if (entry == null) {
        types.insert(0, novo);
      } else {
        types[types.indexOf(entry)] = novo;
      }
    });
    _ok(entry == null ? 'Tipo de produto criado.' : 'Tipo de produto atualizado.');
  }

  Future<void> editAdditional([CatalogAdditional? entry]) async {
    final draft = await Modal.sheet<AdditionalDraft>(
      context,
      builder: (_) => AdditionalEditor(initial: entry?.model),
    );
    if (draft == null || !mounted) return;
    final model = AdicionalModel(
      id: entry?.model.id ?? 'add-${DateTime.now().microsecondsSinceEpoch}',
      nome: draft.name,
      descricao: draft.description.isEmpty ? null : draft.description,
      precoFixo: draft.rule == PriceRule.fixed ? draft.value : null,
      porcentagem: draft.rule == PriceRule.percent ? draft.value : null,
      habilitado: draft.enabled,
    );
    final novo = CatalogAdditional(
      model: model,
      protected: entry?.protected ?? false,
    );
    setState(() {
      if (entry == null) {
        additionals.insert(0, novo);
      } else {
        additionals[additionals.indexOf(entry)] = novo;
      }
    });
    _ok(entry == null ? 'Adicional criado.' : 'Adicional atualizado.');
  }

  Future<void> removeType(CatalogType entry) async {
    if (!await _confirmaExclusao('Excluir tipo de produto')) return;
    if (entry.protected) {
      _erro(
        'Este tipo já foi usado em pedidos ou no portfólio. Desabilite-o '
        'para mantê-lo fora de novos pedidos.',
      );
      return;
    }
    setState(() => types.remove(entry));
    _ok('Tipo de produto excluído.');
  }

  Future<void> removeAdditional(CatalogAdditional entry) async {
    if (!await _confirmaExclusao('Excluir adicional')) return;
    if (entry.protected) {
      _erro(
        'Este adicional já foi usado em um pedido. Desabilite-o para não '
        'exibi-lo em novos formulários.',
      );
      return;
    }
    setState(() {
      additionals.remove(entry);
      for (final type in types) {
        type.additionalIds.remove(entry.model.id);
      }
    });
    _ok('Adicional excluído.');
  }
}
