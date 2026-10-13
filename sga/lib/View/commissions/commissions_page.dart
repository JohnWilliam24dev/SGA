import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import 'column_menu.dart';
import 'commission_card.dart';

/// Página principal: o quadro kanban de commissions.
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
  Future<List<CommissionColumn>>? _loading;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() => _loading = widget.repository.carregarQuadro());
  }

  Future<void> _mover(KanbanMove movimento) async {
    final colunas = await _loading;
    if (colunas == null) return;

    final anteriores = List<CommissionColumn>.from(colunas);

    setState(() {
      _loading = Future.value(moverCommission(
        colunas,
        commissionId: movimento.itemId,
        paraColunaId: movimento.toColumnId,
        paraIndice: movimento.toIndex,
      ));
    });

    try {
      await widget.repository.mover(
        commissionId: movimento.itemId,
        paraColunaId: movimento.toColumnId,
        paraIndice: movimento.toIndex,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = Future.value(anteriores));
      Toast.show('Não foi possível mover a commission.');
    }
  }

  Future<void> _executarStatus(Future<void> Function() acao) async {
    try {
      await acao();
      _carregar();
    } on Exception catch (e) {
      if (!mounted) return;
      Toast.show(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      load: () => _loading!,
      builder: (context, colunas) => KanbanBoard<CommissionResumoModel>(
        items: (colId) => colunas.firstWhere((c) => c.status.id == colId).commissions,
        columns: colunas
            .map((c) => KanbanColumnData<CommissionResumoModel>(
                  id: c.status.id,
                  title: c.status.nome,
                ))
            .toList(),
        onMove: _mover,
        onColumnMove: (m) => _executarStatus(
          () => widget.statusRepository.reordenar(
            colunas.map((c) => c.status.id).toList()..remove(m.columnId)..insert(m.toIndex, m.columnId),
          ),
        ),
        columnHeaderLeading: (col) => ColumnMenuButton(
          columnId: col.id,
          canMoveLeft: colunas.first.status.id != col.id,
          canMoveRight: colunas.last.status.id != col.id,
          onRename: () async {
            final nome = await pedirNomeDaColuna(
              context,
              titulo: 'Renomear coluna',
              confirmar: 'Salvar',
              inicial: col.title,
            );
            if (nome != null) {
              _executarStatus(() => widget.statusRepository.renomear(col.id, nome));
            }
          },
          onChangeType: () async {
            final tipo = await pedirTipoDaColuna(
              context,
              atual: colunas.firstWhere((c) => c.status.id == col.id).status.tipo,
            );
            if (tipo != null) {
              _executarStatus(() => widget.statusRepository.trocarTipo(col.id, tipo));
            }
          },
          onMoveLeft: () {
            final idx = colunas.indexWhere((c) => c.status.id == col.id);
            if (idx > 0) {
              final newIds = colunas.map((c) => c.status.id).toList();
              newIds.removeAt(idx);
              newIds.insert(idx - 1, col.id);
              _executarStatus(() => widget.statusRepository.reordenar(newIds));
            }
          },
          onMoveRight: () {
            final idx = colunas.indexWhere((c) => c.status.id == col.id);
            if (idx < colunas.length - 1) {
              final newIds = colunas.map((c) => c.status.id).toList();
              newIds.removeAt(idx);
              newIds.insert(idx + 1, col.id);
              _executarStatus(() => widget.statusRepository.reordenar(newIds));
            }
          },
          onDelete: () async {
            if (await confirmarExclusaoDaColuna(context, col.title)) {
              _executarStatus(() => widget.statusRepository.excluir(col.id));
            }
          },
        ),
        cardBuilder: (context, item, col) => CommissionCard(
          commission: item,
          onTap: () => widget.onOpenCommission(item, col.title),
        ),
        trailing: Button(
          'Nova coluna',
          icon: Icons.add,
          onPressed: () async {
            final nome = await pedirNomeDaColuna(
              context,
              titulo: 'Nova coluna',
              confirmar: 'Criar',
            );
            if (nome != null) {
              _executarStatus(() => widget.statusRepository.criar(nome));
            }
          },
        ),
      ),
    );
  }
}
