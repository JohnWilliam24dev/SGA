import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'commission_card.dart';

/// Página principal: o quadro kanban de commissions.
///
/// As colunas e os pedidos vêm do [repository] (hoje simulado). Ao soltar um
/// card, a tela atualiza o quadro na hora e avisa o repositório; se ele
/// falhar, o quadro volta ao que era e um aviso aparece.
class CommissionsPage extends StatefulWidget {
  const CommissionsPage({super.key, required this.repository});

  final CommissionRepository repository;

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

    return StylePackScope(
      pack: sgaKanbanPack,
      child: KanbanBoard<Commission>(
        cardHeight: 120,
        columns: [
          for (final coluna in colunas)
            KanbanColumnData<Commission>(
              id: coluna.id,
              title: coluna.titulo,
              items: coluna.commissions,
            ),
        ],
        itemId: (commission) => commission.id,
        itemBuilder: (context, commission) =>
            CommissionCard(commission: commission),
        onMove: _mover,
        emptyLabel: 'Nenhuma commission aqui',
      ),
    );
  }
}
