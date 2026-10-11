import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'column_menu.dart';
import 'commission_card.dart';

/// Página principal: o quadro kanban de commissions.
///
/// As colunas e os resumos vêm do [repository] (hoje simulado). Ao soltar um
/// card, a tela atualiza o quadro na hora e avisa o repositório; se ele
/// falhar, o quadro volta ao que era e um aviso aparece.
///
/// O fluxo também se define aqui, no próprio quadro: o ícone à direita do
/// título arrasta a coluna para onde quiser, os três pontinhos à esquerda
/// abrem renomear, alterar tipo, mover e excluir, e "Nova coluna" cria uma.
/// As regras do quadro (uma coluna Inicial, ao menos uma Concluído e uma
/// Cancelado, nada de excluir coluna com pedidos) vêm do [statusRepository],
/// que recusa a operação; a tela mostra o motivo.
///
/// Um toque simples no card avisa por [onOpenCommission] (com o título da
/// coluna onde ele está) para abrir o detalhe; apertar e segurar move o card.
class CommissionsPage extends StatefulWidget {
  const CommissionsPage({
    super.key,
    required this.repository,
    required this.statusRepository,
    required this.onOpenCommission,
  });

  final CommissionRepository repository;
  final StatusRepository statusRepository;
  final void Function(CommissionResumoModel commission, String statusNome)
  onOpenCommission;

  @override
  State<CommissionsPage> createState() => _CommissionsPageState();
}

class _CommissionsPageState extends State<CommissionsPage> {
  List<CommissionColumn>? _colunas;
  bool _falhou = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _falhou = false);
    try {
      final colunas = await widget.repository.carregarQuadro();
      if (!mounted) return;
      setState(() => _colunas = colunas);
    } catch (_) {
      if (!mounted) return;
      setState(() => _falhou = true);
    }
  }

  Future<void> _mover(KanbanMove movimento) async {
    final anteriores = _colunas;
    if (anteriores == null) return;

    setState(() {
      _colunas = moverCommission(
        anteriores,
        commissionId: movimento.itemId,
        paraColunaId: movimento.toColumnId,
        paraIndice: movimento.toIndex,
      );
    });

    try {
      await widget.repository.mover(
        commissionId: movimento.itemId,
        paraColunaId: movimento.toColumnId,
        paraIndice: movimento.toIndex,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _colunas = anteriores);
      Toast.show(
        context,
        text: 'Não foi possível mover a commission.',
        type: ToastType.error,
      );
    }
  }

  /// Roda uma alteração nas colunas; se o repositório recusar, mostra o
  /// motivo. Em qualquer caso recarrega o quadro, para a tela espelhar o que
  /// ficou salvo.
  Future<void> _executarStatus(Future<void> Function() acao) async {
    String? erro;
    try {
      await acao();
    } on StatusRegraException catch (e) {
      erro = e.mensagem;
    } catch (_) {
      erro = 'Não foi possível salvar a alteração.';
    }
    if (!mounted) return;
    if (erro != null) {
      Toast.show(context, text: erro, type: ToastType.error);
    }
    await _carregar();
  }

  Future<void> _novaColuna() async {
    final nome = await pedirNomeDaColuna(
      context,
      titulo: 'Nova coluna',
      confirmar: 'Criar',
    );
    if (nome == null || !mounted) return;
    await _executarStatus(() => widget.statusRepository.criar(nome));
  }

  Future<void> _renomear(CommissionColumn coluna) async {
    final nome = await pedirNomeDaColuna(
      context,
      titulo: 'Renomear coluna',
      confirmar: 'Salvar',
      inicial: coluna.titulo,
    );
    if (nome == null || !mounted) return;
    await _executarStatus(
      () => widget.statusRepository.renomear(coluna.id, nome),
    );
  }

  Future<void> _alterarTipo(CommissionColumn coluna) async {
    final tipo = await pedirTipoDaColuna(context, atual: coluna.tipo);
    if (tipo == null || tipo == coluna.tipo || !mounted) return;
    await _executarStatus(
      () => widget.statusRepository.trocarTipo(coluna.id, tipo),
    );
  }

  Future<void> _excluir(CommissionColumn coluna) async {
    final confirmou = await confirmarExclusaoDaColuna(context, coluna.titulo);
    if (!confirmou || !mounted) return;
    await _executarStatus(() => widget.statusRepository.excluir(coluna.id));
  }

  /// Reordena as colunas: a tela mostra a nova ordem na hora e o repositório
  /// confirma (ou recusa, e o quadro volta ao que estava salvo).
  Future<void> _moverColuna(KanbanColumnMove movimento) async {
    final anteriores = _colunas;
    if (anteriores == null) return;

    final novas = moverColuna(
      anteriores,
      columnId: movimento.columnId,
      paraIndice: movimento.toIndex,
    );
    setState(() => _colunas = novas);
    await _executarStatus(
      () => widget.statusRepository.reordenar([for (final c in novas) c.id]),
    );
  }

  Widget _menuDaColuna(CommissionColumn coluna, int indice, int total) {
    return ColumnMenuButton(
      columnId: coluna.id,
      canMoveLeft: indice > 0,
      canMoveRight: indice < total - 1,
      onRename: () => _renomear(coluna),
      onChangeType: () => _alterarTipo(coluna),
      onMoveLeft: () => _moverColuna(
        KanbanColumnMove(
          columnId: coluna.id,
          fromIndex: indice,
          toIndex: indice - 1,
        ),
      ),
      onMoveRight: () => _moverColuna(
        KanbanColumnMove(
          columnId: coluna.id,
          fromIndex: indice,
          toIndex: indice + 1,
        ),
      ),
      onDelete: () => _excluir(coluna),
    );
  }

  void _abrir(CommissionResumoModel commission) {
    final colunas = _colunas ?? const <CommissionColumn>[];
    final coluna = colunas.firstWhere(
      (c) => c.commissions.any((item) => item.id == commission.id),
      orElse: () => const CommissionColumn(
        id: '',
        titulo: '',
        tipo: StatusTipo.emAndamento,
        ordem: 0,
      ),
    );
    widget.onOpenCommission(commission, coluna.titulo);
  }

  @override
  Widget build(BuildContext context) {
    final colunas = _colunas;

    if (_falhou) {
      return Div(
        position: LayoutPosition.center,
        align: Alignment.center,
        children: [
          const Label(
            type: LabelType.error,
            text: 'Não foi possível carregar o quadro',
          ),
          Button(
            text: 'Tentar de novo',
            variant: ButtonVariant.outline,
            onPressed: _carregar,
          ),
        ],
      );
    }
    if (colunas == null) {
      return const Loader(message: 'Carregando commissions...');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Button(
                text: 'Nova coluna',
                variant: ButtonVariant.outline,
                onPressed: _novaColuna,
              ),
            ),
          ),
          Expanded(
            child: GlassPanel(
              padding: const EdgeInsets.all(12),
              child: StylePackScope(
                pack: sgaKanbanPack,
                child: KanbanBoard<CommissionResumoModel>(
                  cardHeight: 104,
                  columns: [
                    for (final coluna in colunas)
                      KanbanColumnData<CommissionResumoModel>(
                        id: coluna.id,
                        title: coluna.titulo,
                        items: coluna.commissions,
                      ),
                  ],
                  itemId: (commission) => commission.id,
                  itemBuilder: (context, commission) =>
                      CommissionCard(commission: commission),
                  onMove: _mover,
                  onItemTap: _abrir,
                  onColumnMove: _moverColuna,
                  columnActionsBuilder: (context, column, indice) =>
                      _menuDaColuna(colunas[indice], indice, colunas.length),
                  emptyLabel: 'Nenhum pedido aqui',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
