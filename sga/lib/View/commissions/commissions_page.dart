import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'commission_card.dart';

/// Página principal: o quadro kanban de commissions.
///
/// As colunas e os resumos vêm do [repository] (hoje simulado). Ao soltar um
/// card, a tela atualiza o quadro na hora e avisa o repositório; se ele
/// falhar, o quadro volta ao que era e um aviso aparece.
///
/// Um toque simples no card avisa por [onOpenCommission] (com o título da
/// coluna onde ele está) para abrir o detalhe; apertar e segurar move o card.
class CommissionsPage extends StatefulWidget {
  const CommissionsPage({
    super.key,
    required this.repository,
    required this.onOpenCommission,
  });

  final CommissionRepository repository;
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
            emptyLabel: 'Nenhum pedido aqui',
          ),
        ),
      ),
    );
  }
}
