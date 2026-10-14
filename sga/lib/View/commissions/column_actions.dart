import 'package:easy_ui/easy_ui.dart' show KanbanColumnMove, Toast, ToastType;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import 'column_menu.dart';
import 'commissions_controller.dart';

/// Ações das colunas do quadro (criar, renomear, tipo, mover, excluir) para a
/// tela de commissions: pergunta ao usuário e entrega o pedido ao controller.
mixin ColumnActions<T extends StatefulWidget> on State<T> {
  CommissionsController get controller;

  void avisarErro(String mensagem) =>
      Toast.show(context, text: mensagem, type: ToastType.error);

  Future<void> _resolver(Future<String?> resultado) async {
    final erro = await resultado;
    if (erro != null && mounted) avisarErro(erro);
  }

  Future<void> novaColuna() async {
    final nome = await pedirNomeDaColuna(
      context,
      titulo: 'Nova coluna',
      confirmar: 'Criar',
    );
    if (nome == null || !mounted) return;
    await _resolver(
      controller.executarStatus(() => controller.statusRepository.criar(nome)),
    );
  }

  Future<void> _renomear(CommissionColumn coluna) async {
    final nome = await pedirNomeDaColuna(
      context,
      titulo: 'Renomear coluna',
      confirmar: 'Salvar',
      inicial: coluna.titulo,
    );
    if (nome == null || !mounted) return;
    await _resolver(
      controller.executarStatus(
        () => controller.statusRepository.renomear(coluna.id, nome),
      ),
    );
  }

  Future<void> _alterarTipo(CommissionColumn coluna) async {
    final tipo = await pedirTipoDaColuna(context, atual: coluna.tipo);
    if (tipo == null || tipo == coluna.tipo || !mounted) return;
    await _resolver(
      controller.executarStatus(
        () => controller.statusRepository.trocarTipo(coluna.id, tipo),
      ),
    );
  }

  Future<void> _excluir(CommissionColumn coluna) async {
    final confirmou = await confirmarExclusaoDaColuna(context, coluna.titulo);
    if (!confirmou || !mounted) return;
    await _resolver(
      controller.executarStatus(
        () => controller.statusRepository.excluir(coluna.id),
      ),
    );
  }

  Future<void> aoMoverColuna(KanbanColumnMove movimento) =>
      _resolver(controller.reordenarColuna(movimento));

  /// Menu dos três pontinhos da coluna [indice] (de [total] colunas).
  Widget menuDaColuna(CommissionColumn coluna, int indice, int total) {
    KanbanColumnMove passo(int delta) => KanbanColumnMove(
      columnId: coluna.id,
      fromIndex: indice,
      toIndex: indice + delta,
    );
    return ColumnMenuButton(
      columnId: coluna.id,
      canMoveLeft: indice > 0,
      canMoveRight: indice < total - 1,
      onRename: () => _renomear(coluna),
      onChangeType: () => _alterarTipo(coluna),
      onMoveLeft: () => aoMoverColuna(passo(-1)),
      onMoveRight: () => aoMoverColuna(passo(1)),
      onDelete: () => _excluir(coluna),
    );
  }
}
