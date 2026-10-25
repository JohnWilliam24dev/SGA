import 'package:easy_ui/easy_ui.dart' show Modal, Toast, ToastType;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';
import 'additional_editor.dart';
import 'catalog_entries.dart';
import 'type_editor.dart';

/// Ações do catálogo (carregar, criar, editar, habilitar, excluir) sobre o
/// [CatalogoAdminRepository]. Cada ação avisa o resultado por um Toast e, no
/// fim, relê o catálogo: a tela espelha o que o servidor guardou.
mixin CatalogActions<T extends StatefulWidget> on State<T> {
  CatalogoAdminRepository get repo;
  List<CatalogType> get types;
  set types(List<CatalogType> valor);
  List<CatalogAdditional> get additionals;
  set additionals(List<CatalogAdditional> valor);

  void _ok(String text) =>
      Toast.show(context, text: text, type: ToastType.success);

  void _erro(String text) =>
      Toast.show(context, text: text, type: ToastType.error);

  /// Relê tipos e adicionais; devolve o motivo se falhou.
  Future<String?> recarregar() async {
    try {
      final tipos = await repo.listarTipos();
      final adicionais = await repo.listarAdicionais();
      if (!mounted) return null;
      setState(() {
        types = [
          for (final t in tipos)
            CatalogType(model: t.tipo, additionalIds: {...t.adicionalIds}),
        ];
        additionals = [for (final a in adicionais) CatalogAdditional(model: a)];
      });
      return null;
    } catch (e) {
      return mensagemDeErro(e, 'Não foi possível carregar o catálogo.');
    }
  }

  /// Roda a [acao] e relê o catálogo, com sucesso ou não (uma falha no meio
  /// pode ter salvado parte).
  Future<void> _rodar(Future<void> Function() acao, String sucesso) async {
    String? falha;
    try {
      await acao();
    } catch (e) {
      falha = mensagemDeErro(e, 'Não foi possível salvar. Tente de novo.');
    }
    if (falha != null && mounted) _erro(falha);
    await recarregar();
    if (falha == null && mounted) _ok(sucesso);
  }

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
    await _rodar(
      () => repo.salvarTipo(
        id: entry?.model.id,
        nome: draft.name,
        precoBase: draft.basePrice,
        habilitado: draft.enabled,
        adicionalIds: draft.additionalIds,
      ),
      entry == null ? 'Tipo de produto criado.' : 'Tipo de produto atualizado.',
    );
  }

  Future<void> editAdditional([CatalogAdditional? entry]) async {
    final draft = await Modal.sheet<AdditionalDraft>(
      context,
      builder: (_) => AdditionalEditor(initial: entry?.model),
    );
    if (draft == null || !mounted) return;
    await _rodar(
      () => repo.salvarAdicional(
        id: entry?.model.id,
        nome: draft.name,
        descricao: draft.description,
        precoFixo: draft.rule == PriceRule.fixed ? draft.value : null,
        porcentagem: draft.rule == PriceRule.percent ? draft.value : null,
        habilitado: draft.enabled,
      ),
      entry == null ? 'Adicional criado.' : 'Adicional atualizado.',
    );
  }

  /// O interruptor muda na hora; se o servidor recusar, volta ao que estava.
  Future<void> alternarTipo(CatalogType entry, bool valor) async {
    final antes = entry.model;
    setState(() => entry.model = typeWithEnabled(antes, valor));
    try {
      await repo.definirTipoHabilitado(antes.id, valor);
    } catch (e) {
      if (!mounted) return;
      setState(() => entry.model = antes);
      _erro(mensagemDeErro(e, 'Não foi possível alterar o tipo.'));
    }
  }

  Future<void> alternarAdicional(CatalogAdditional entry, bool valor) async {
    final antes = entry.model;
    setState(() => entry.model = additionalWithEnabled(antes, valor));
    try {
      await repo.definirAdicionalHabilitado(antes.id, valor);
    } catch (e) {
      if (!mounted) return;
      setState(() => entry.model = antes);
      _erro(mensagemDeErro(e, 'Não foi possível alterar o adicional.'));
    }
  }

  Future<void> removeType(CatalogType entry) async {
    if (!await _confirmaExclusao('Excluir tipo de produto')) return;
    await _rodar(
      () => repo.excluirTipo(entry.model.id),
      'Tipo de produto excluído.',
    );
  }

  Future<void> removeAdditional(CatalogAdditional entry) async {
    if (!await _confirmaExclusao('Excluir adicional')) return;
    await _rodar(
      () => repo.excluirAdicional(entry.model.id),
      'Adicional excluído.',
    );
  }
}
