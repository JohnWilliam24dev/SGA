import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import 'add_menu_button.dart';
import 'column_actions.dart';
import 'commissions_board.dart';
import 'commissions_controller.dart';
import 'order_actions.dart';

/// Página principal: o quadro kanban de commissions.
///
/// O estado e as regras moram no [CommissionsController]; as ações das
/// colunas (nova, renomear, tipo, mover, excluir) em [ColumnActions]; a
/// criação de pedido em [OrderActions]; o desenho em [CommissionsBoard]. Aqui só se liga uma coisa à outra.
///
/// Um toque simples no card avisa por [onOpenCommission] (com o título da
/// coluna onde ele está) para abrir o detalhe; apertar e segurar move o card.
class CommissionsPage extends StatefulWidget {
  const CommissionsPage({
    super.key,
    required this.repository,
    required this.statusRepository,
    required this.onOpenCommission,
    this.catalogo,
  });

  final CommissionRepository repository;
  final StatusRepository statusRepository;

  /// Tipos e adicionais para montar um pedido novo.
  final CatalogoRepository? catalogo;
  final void Function(CommissionResumoModel commission, String statusNome)
  onOpenCommission;

  @override
  State<CommissionsPage> createState() => _CommissionsPageState();
}

class _CommissionsPageState extends State<CommissionsPage>
    with ColumnActions<CommissionsPage>, OrderActions<CommissionsPage> {
  @override
  late final CommissionsController controller = CommissionsController(
    repository: widget.repository,
    statusRepository: widget.statusRepository,
  );

  @override
  CatalogoRepository get catalogo =>
      widget.catalogo ?? const FakeCatalogoRepository();

  @override
  void initState() {
    super.initState();
    controller.carregar();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _mover(KanbanMove<CommissionResumoModel> movimento) async {
    final erro = await controller.mover(movimento);
    if (erro != null && mounted) avisarErro(erro);
  }

  void _abrir(CommissionResumoModel commission) {
    final colunas = controller.colunas ?? const <CommissionColumn>[];
    final coluna = colunas.where(
      (c) => c.commissions.any((item) => item.id == commission.id),
    );
    widget.onOpenCommission(
      commission,
      coluna.isEmpty ? '' : coluna.first.titulo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final colunas = controller.colunas;
        if (controller.falhou) {
          return _FalhaNoQuadro(onRetry: controller.carregar);
        }
        if (colunas == null) {
          return const Loader(message: 'Carregando commissions...');
        }
        return Stack(
          children: [
            Positioned.fill(
              child: CommissionsBoard(
                colunas: colunas,
                onMove: _mover,
                onItemTap: _abrir,
                onColumnMove: aoMoverColuna,
                menuDaColuna: menuDaColuna,
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: AddMenuButton(
                onAddColumn: novaColuna,
                onAddOrder: novoPedido,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FalhaNoQuadro extends StatelessWidget {
  const _FalhaNoQuadro({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
          onPressed: onRetry,
        ),
      ],
    );
  }
}
