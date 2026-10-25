import 'package:easy_ui/easy_ui.dart' show KanbanColumnMove, KanbanMove;
import 'package:flutter/foundation.dart';

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';
import 'commissions_paginacao.dart';

/// Estado e regras do quadro de commissions, sem nenhum widget: a tela só
/// desenha o que está aqui e mostra os avisos que os métodos devolvem.
///
/// Os métodos que podem falhar devolvem a mensagem de erro (ou `null`).
class CommissionsController extends ChangeNotifier
    with CommissionsPaginacao {
  CommissionsController({
    required this.repository,
    required this.statusRepository,
  }) {
    // Pedido criado ou editado (no detalhe, por exemplo): o quadro se
    // atualiza sozinho, sem o aviso de carregamento.
    repository.addListener(_aoMudar);
  }

  @override
  final CommissionRepository repository;
  final StatusRepository statusRepository;

  @override
  List<CommissionColumn>? colunas;
  bool falhou = false;
  bool _vivo = true;

  Future<void> _aoMudar() async {
    try {
      colunas = await repository.carregarQuadro();
      notifyListeners();
    } catch (_) {
      // Mantém o quadro que já está na tela.
    }
  }

  @override
  void dispose() {
    repository.removeListener(_aoMudar);
    _vivo = false;
    super.dispose();
  }

  // Respostas de rede podem chegar depois de a tela fechar.
  @override
  void notifyListeners() {
    if (_vivo) super.notifyListeners();
  }

  Future<void> carregar() async {
    falhou = false;
    notifyListeners();
    try {
      colunas = await repository.carregarQuadro();
    } catch (_) {
      falhou = true;
    }
    notifyListeners();
  }

  /// Cria um pedido na coluna inicial; devolve o motivo se foi recusado.
  Future<String?> criarPedido(NovaCommission nova) async {
    try {
      await repository.criar(nova);
      return null;
    } catch (e) {
      return mensagemDeErro(e, 'Não foi possível criar o pedido.');
    }
  }

  /// Move o card na hora; se o repositório falhar, o quadro volta ao que era.
  Future<String?> mover(KanbanMove<CommissionResumoModel> movimento) async {
    final anteriores = colunas;
    if (anteriores == null) return null;

    colunas = moverCommission(
      anteriores,
      commissionId: movimento.itemId,
      paraColunaId: movimento.toColumnId,
      paraIndice: movimento.toIndex,
    );
    notifyListeners();
    try {
      await repository.mover(
        commissionId: movimento.itemId,
        paraColunaId: movimento.toColumnId,
        paraIndice: movimento.toIndex,
      );
      return null;
    } catch (e) {
      colunas = anteriores;
      notifyListeners();
      return mensagemDeErro(e, 'Não foi possível mover a commission.');
    }
  }

  /// Roda uma alteração nas colunas. Em qualquer caso recarrega o quadro,
  /// para a tela espelhar o que ficou salvo; devolve o motivo se foi recusada.
  Future<String?> executarStatus(Future<void> Function() acao) async {
    String? erro;
    try {
      await acao();
    } catch (e) {
      erro = mensagemDeErro(e, 'Não foi possível salvar a alteração.');
    }
    await carregar();
    return erro;
  }

  /// Reordena as colunas: mostra a nova ordem na hora e o repositório
  /// confirma (ou recusa, e o quadro volta ao que estava salvo).
  Future<String?> reordenarColuna(KanbanColumnMove movimento) async {
    final anteriores = colunas;
    if (anteriores == null) return null;

    final novas = moverColuna(
      anteriores,
      columnId: movimento.columnId,
      paraIndice: movimento.toIndex,
    );
    colunas = novas;
    notifyListeners();
    return executarStatus(
      () => statusRepository.reordenar([for (final c in novas) c.id]),
    );
  }
}
