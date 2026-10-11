import 'dart:async';
import 'dart:math' as math;

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart' show Scrollbar;
import 'package:flutter/widgets.dart' hide Icon;

import 'kanban_column_view.dart';
import 'kanban_models.dart';

/// Quadro kanban multiplataforma, no estilo Trello/Jira.
///
/// Recebe uma **lista de colunas** (não há colunas fixas) e é *controlado*:
/// ao soltar um card o board só avisa por [onMove]; quem guarda o estado
/// atualiza a lista e o board se redesenha.
///
/// **Mover um card** exige apertar e segurar por um instante (mouse ou
/// toque); um clique/toque simples fica livre para abrir os detalhes, e
/// deslizar sem segurar rola o quadro. Perto das bordas o quadro rola sozinho.
///
/// **Largura de tablet/desktop:** colunas lado a lado numa faixa com rolagem
/// horizontal (arrastar o fundo também rola).
///
/// **Largura de celular:** uma coluna por vez, em páginas que sempre encaixam
/// (nunca ficam pela metade); um leve deslizar vai para a coluna seguinte e,
/// com o card na mão, levá-lo até a borda da tela troca de coluna sozinho.
///
/// [cardHeight] é a altura padrão dos cards: o conteúdo mostra só o começo
/// do texto, não precisa caber inteiro.
class KanbanBoard<T> extends StatefulWidget {
  const KanbanBoard({
    super.key,
    required this.columns,
    required this.itemId,
    required this.itemBuilder,
    required this.onMove,
    this.onItemTap,
    this.onColumnMove,
    this.columnActionsBuilder,
    this.cardHeight = 112,
    this.emptyLabel = 'Nenhum item aqui',
  }) : assert(cardHeight > 0, 'cardHeight deve ser > 0.');

  final List<KanbanColumnData<T>> columns;
  final String Function(T item) itemId;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<KanbanMove> onMove;

  /// Chamado num clique/toque simples no card. Apertar e segurar (mover) e
  /// deslizar (rolar) não disparam esse callback.
  final ValueChanged<T>? onItemTap;

  /// Quando informado, cada coluna ganha à direita do cabeçalho um ícone de
  /// arrastar: levá-lo para outro ponto do quadro reordena as colunas e este
  /// callback avisa o resultado. Só na largura de tablet/desktop; no celular
  /// (uma coluna por página) a ordem muda pelas ações da coluna.
  final ValueChanged<KanbanColumnMove>? onColumnMove;

  /// Botão de ações de cada coluna (ex.: um menu de três pontinhos), colocado
  /// no cabeçalho, depois da contagem de itens. Recebe o índice da coluna.
  final Widget Function(
    BuildContext context,
    KanbanColumnData<T> column,
    int index,
  )?
  columnActionsBuilder;
  final double cardHeight;
  final String emptyLabel;

  @override
  State<KanbanBoard<T>> createState() => _KanbanBoardState<T>();
}

class _KanbanBoardState<T> extends State<KanbanBoard<T>> {
  static const double _gap = 10;
  static const double _listPadding = 8;
  static const double _desktopColumnWidth = 300;
  static const double _desktopSpacing = 16;
  static const double _desktopPadding = 16;
  static const double _pageFraction = 0.86;
  static const double _pageMargin = 6;

  // Rolagem automática.
  static const double _edge = 72;
  static const double _boardEdge = 110;
  static const double _maxSpeed = 14;
  static const double _pageEdge = 44;
  static const Duration _pageDwell = Duration(milliseconds: 350);
  static const Duration _pageCooldown = Duration(milliseconds: 700);

  final ScrollController _horizontalController = ScrollController();
  final PageController _pageController = PageController(
    viewportFraction: _pageFraction,
  );
  final Map<String, ScrollController> _listControllers =
      <String, ScrollController>{};
  final Map<String, GlobalKey> _columnKeys = <String, GlobalKey>{};
  final Map<String, GlobalKey> _listKeys = <String, GlobalKey>{};
  final GlobalKey _boardKey = GlobalKey();

  // Estado do arrasto em andamento.
  String? _draggingId;
  String? _fromColumnId;
  int _fromIndex = 0;
  String? _hoverColumnId;
  int _hoverIndex = 0;
  Offset? _pointer;
  Timer? _ticker;
  DateTime? _edgeSince;
  DateTime? _lastFlip;
  bool _mobileLayout = false;

  // Arrasto de uma coluna (só no layout largo).
  String? _draggingColumnId;
  int _columnFromIndex = 0;
  int _columnHoverIndex = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    _horizontalController.dispose();
    _pageController.dispose();
    for (final controller in _listControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ---- chaves e controllers por coluna --------------------------------------

  GlobalKey _keyOf(Map<String, GlobalKey> keys, String id) {
    return keys.putIfAbsent(id, () => GlobalKey());
  }

  ScrollController _listControllerOf(String id) {
    return _listControllers.putIfAbsent(id, () => ScrollController());
  }

  RenderBox? _boxOf(GlobalKey? key) {
    final object = key?.currentContext?.findRenderObject();
    if (object is RenderBox && object.attached && object.hasSize) return object;
    return null;
  }

  Rect? _rectOf(GlobalKey? key) {
    final box = _boxOf(key);
    if (box == null) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  // ---- ciclo do arrasto -------------------------------------------------------

  void _onDragStarted(String itemId, String columnId) {
    final column = widget.columns.firstWhere((c) => c.id == columnId);
    final index = column.items.indexWhere((i) => widget.itemId(i) == itemId);

    setState(() {
      _draggingId = itemId;
      _fromColumnId = columnId;
      _fromIndex = index;
      // O espaço reservado nasce exatamente onde o card estava.
      _hoverColumnId = columnId;
      _hoverIndex = index;
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _onDragUpdate(Offset pointer) {
    _pointer = pointer;
    _updateHover();
  }

  void _onDragEnd() {
    final itemId = _draggingId;
    final from = _fromColumnId;
    final to = _hoverColumnId;
    final toIndex = _hoverIndex;
    final fromIndex = _fromIndex;

    _ticker?.cancel();
    _ticker = null;
    _pointer = null;
    _edgeSince = null;

    if (!mounted) return;
    setState(() {
      _draggingId = null;
      _fromColumnId = null;
      _hoverColumnId = null;
    });

    if (itemId == null || from == null || to == null) return;
    if (to == from && toIndex == fromIndex) return; // soltou onde estava
    widget.onMove(
      KanbanMove(
        itemId: itemId,
        fromColumnId: from,
        toColumnId: to,
        toIndex: toIndex,
      ),
    );
  }

  // ---- ciclo do arrasto de coluna ------------------------------------------

  void _onColumnDragStarted(String columnId) {
    final index = widget.columns.indexWhere((c) => c.id == columnId);
    setState(() {
      _draggingColumnId = columnId;
      _columnFromIndex = index;
      // O espaço reservado nasce onde a coluna estava.
      _columnHoverIndex = index;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _onColumnDragUpdate(Offset pointer) {
    _pointer = pointer;
    _updateColumnHover();
  }

  void _onColumnDragEnd() {
    final columnId = _draggingColumnId;
    final from = _columnFromIndex;
    final to = _columnHoverIndex;

    _ticker?.cancel();
    _ticker = null;
    _pointer = null;

    if (!mounted) return;
    setState(() => _draggingColumnId = null);

    if (columnId == null || to == from) return; // soltou onde estava
    widget.onColumnMove?.call(
      KanbanColumnMove(columnId: columnId, fromIndex: from, toIndex: to),
    );
  }

  /// Posição (entre as colunas, sem contar a arrastada) sobre a qual o
  /// ponteiro está. Com a coluna arrastada fora do caminho e o espaço
  /// reservado no lugar, todas as "vagas" têm a mesma largura, então a conta
  /// não depende do que está desenhado e o espaço não fica pulando.
  void _updateColumnHover() {
    final pointer = _pointer;
    if (_draggingColumnId == null || pointer == null) return;
    final rect = _rectOf(_boardKey);
    if (rect == null) return;

    final scroll = _horizontalController.hasClients
        ? _horizontalController.offset
        : 0.0;
    final x = pointer.dx - rect.left + scroll - _desktopPadding;
    final slot = (x / (_desktopColumnWidth + _desktopSpacing)).floor();
    final index = math.max(0, math.min(widget.columns.length - 1, slot));
    if (index != _columnHoverIndex) {
      setState(() => _columnHoverIndex = index);
    }
  }

  // ---- onde o card cairia -------------------------------------------------------

  /// Descobre a coluna sob o ponteiro e a posição dentro dela. Se o ponteiro
  /// estiver fora de qualquer coluna (ex.: no vão entre duas), mantém o
  /// último destino válido, para soltar ali não cancelar o movimento.
  void _updateHover() {
    final pointer = _pointer;
    if (_draggingId == null || pointer == null) return;

    for (final column in widget.columns) {
      final rect = _rectOf(_columnKeys[column.id]);
      if (rect == null || !rect.contains(pointer)) continue;

      final index = _indexAt(column, pointer);
      if (column.id != _hoverColumnId || index != _hoverIndex) {
        setState(() {
          _hoverColumnId = column.id;
          _hoverIndex = index;
        });
      }
      return;
    }
  }

  /// Posição (entre os itens, sem contar o arrastado) sobre a qual o ponteiro
  /// está. Os cards têm altura fixa, então cada "vaga" tem o mesmo tamanho.
  int _indexAt(KanbanColumnData<T> column, Offset pointer) {
    final count = column.items
        .where((i) => widget.itemId(i) != _draggingId)
        .length;
    final listBox = _boxOf(_listKeys[column.id]);
    if (listBox == null) return count;

    final controller = _listControllers[column.id];
    final scroll = (controller != null && controller.hasClients)
        ? controller.offset
        : 0.0;
    final top = listBox.localToGlobal(Offset.zero).dy;
    final y = pointer.dy - top + scroll - _listPadding;
    final slot = (y / (widget.cardHeight + _gap)).floor();
    return math.max(0, math.min(count, slot));
  }

  // ---- rolagem automática ------------------------------------------------------

  void _tick() {
    final pointer = _pointer;
    if (pointer == null) return;
    if (_draggingColumnId != null) {
      _autoScrollBoard(pointer);
      _updateColumnHover();
      return;
    }
    if (_draggingId == null) return;

    _autoScrollList(pointer);
    if (_mobileLayout) {
      _autoFlipPage(pointer);
    } else {
      _autoScrollBoard(pointer);
    }
    // Rolar (ou trocar de página) muda o que está sob o ponteiro parado.
    _updateHover();
  }

  double _edgeDelta(
    double value,
    double start,
    double end, [
    double edge = _edge,
  ]) {
    if (value < start + edge) {
      final t = ((start + edge - value) / edge).clamp(0.0, 1.0).toDouble();
      return -_maxSpeed * t;
    }
    if (value > end - edge) {
      final t = ((value - (end - edge)) / edge).clamp(0.0, 1.0).toDouble();
      return _maxSpeed * t;
    }
    return 0;
  }

  void _scrollBy(ScrollController controller, double delta) {
    if (delta == 0 || !controller.hasClients) return;
    final position = controller.position;
    final target = (controller.offset + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    controller.jumpTo(target);
  }

  void _autoScrollList(Offset pointer) {
    final columnId = _hoverColumnId;
    if (columnId == null) return;
    final controller = _listControllers[columnId];
    final rect = _rectOf(_listKeys[columnId]);
    if (controller == null || rect == null) return;
    _scrollBy(controller, _edgeDelta(pointer.dy, rect.top, rect.bottom));
  }

  void _autoScrollBoard(Offset pointer) {
    final rect = _rectOf(_boardKey);
    if (rect == null) return;
    _scrollBy(
      _horizontalController,
      _edgeDelta(pointer.dx, rect.left, rect.right, _boardEdge),
    );
  }

  void _autoFlipPage(Offset pointer) {
    final rect = _rectOf(_boardKey);
    if (rect == null || !_pageController.hasClients) return;

    var direction = 0;
    if (pointer.dx < rect.left + _pageEdge) {
      direction = -1;
    } else if (pointer.dx > rect.right - _pageEdge) {
      direction = 1;
    }
    if (direction == 0) {
      _edgeSince = null;
      return;
    }

    final now = DateTime.now();
    _edgeSince ??= now;
    final waited = now.difference(_edgeSince!) >= _pageDwell;
    final cooled =
        _lastFlip == null || now.difference(_lastFlip!) >= _pageCooldown;
    if (!waited || !cooled) return;

    final current = (_pageController.page ?? 0).round();
    final target = math.max(
      0,
      math.min(widget.columns.length - 1, current + direction),
    );
    if (target == current) return;
    _lastFlip = now;
    _goToPage(target);
  }

  void _goToPage(int page) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ---- construção ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 480.0;
        // Largura de celular: uma coluna por vez, em páginas que encaixam.
        // Vale pela largura (e não pela plataforma) para funcionar também
        // numa janela de navegador estreita.
        final mobile = Breakpoints.standard.sizeFor(width) == ScreenSize.mobile;
        _mobileLayout = mobile;

        // Por padrão o Flutter não deixa o mouse arrastar áreas roláveis;
        // aqui deixamos (arrastar o fundo do quadro rola, como no Trello).
        final behavior = ScrollConfiguration.of(context)
            .copyWith(dragDevices: PointerDeviceKind.values.toSet());

        return ScrollConfiguration(
          behavior: behavior,
          child: SizedBox(
            key: _boardKey,
            width: width,
            height: height,
            child: mobile ? _buildMobile(width) : _buildDesktop(height),
          ),
        );
      },
    );
  }

  Widget _buildColumn(KanbanColumnData<T> column, double cardWidth) {
    return KanbanColumnView<T>(
      key: ValueKey<String>('kanban-view-${column.id}'),
      column: column,
      columnKey: _keyOf(_columnKeys, column.id),
      listKey: _keyOf(_listKeys, column.id),
      scrollController: _listControllerOf(column.id),
      cardWidth: cardWidth,
      cardHeight: widget.cardHeight,
      gap: _gap,
      listPadding: _listPadding,
      draggingId: _draggingId,
      hoverIndex: _hoverColumnId == column.id ? _hoverIndex : null,
      emptyLabel: widget.emptyLabel,
      itemId: widget.itemId,
      itemBuilder: widget.itemBuilder,
      onItemTap: widget.onItemTap,
      onDragStarted: (id) => _onDragStarted(id, column.id),
      onDragUpdate: _onDragUpdate,
      onDragEnd: _onDragEnd,
      columnWidth: _desktopColumnWidth,
      actions: widget.columnActionsBuilder?.call(
        context,
        column,
        widget.columns.indexWhere((c) => c.id == column.id),
      ),
      showDragHandle: widget.onColumnMove != null && !_mobileLayout,
      onColumnDragStarted: () => _onColumnDragStarted(column.id),
      onColumnDragUpdate: _onColumnDragUpdate,
      onColumnDragEnd: _onColumnDragEnd,
    );
  }

  Widget _columnPlaceholder() {
    final tokens = AppThemeScope.tokensOf(context);
    return SizedBox(
      key: const ValueKey<String>('kanban-column-placeholder'),
      width: _desktopColumnWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tokens.primaryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(double height) {
    final children = _desktopChildren();
    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(_desktopPadding),
        child: SizedBox(
          height: math.max(0.0, height - 2 * _desktopPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }

  /// As colunas lado a lado. Durante o arrasto de uma coluna, ela continua na
  /// árvore (para o fim do arrasto ser avisado) mas sem ocupar espaço, e um
  /// espaço reservado marca onde ela cairia.
  List<Widget> _desktopChildren() {
    final children = <Widget>[];
    final dragging = _draggingColumnId != null;
    var placed = 0;
    var slot = 0;

    void add(Widget child) {
      if (placed > 0) children.add(const SizedBox(width: _desktopSpacing));
      children.add(child);
      placed++;
    }

    for (final column in widget.columns) {
      final hidden = column.id == _draggingColumnId;
      if (!hidden) {
        if (dragging && _columnHoverIndex == slot) add(_columnPlaceholder());
        slot++;
      }
      final view = _ColumnSlot(
        key: ValueKey<String>('kanban-slot-${column.id}'),
        hidden: hidden,
        width: _desktopColumnWidth,
        child: _buildColumn(column, _desktopColumnWidth - 2 * _listPadding),
      );
      if (hidden) {
        children.add(view);
      } else {
        add(view);
      }
    }
    if (dragging && _columnHoverIndex == slot) add(_columnPlaceholder());
    return children;
  }

  Widget _buildMobile(double width) {
    final columns = widget.columns;
    final cardWidth = math.max(
      0.0,
      width * _pageFraction - 2 * _pageMargin - 2 * _listPadding,
    );

    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              for (final column in columns)
                _KeepAlive(
                  key: ValueKey<String>('kanban-page-${column.id}'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _pageMargin,
                      8,
                      _pageMargin,
                      8,
                    ),
                    child: _buildColumn(column, cardWidth),
                  ),
                ),
            ],
          ),
        ),
        _buildDots(),
      ],
    );
  }

  Widget _buildDots() {
    final tokens = AppThemeScope.tokensOf(context);
    final count = widget.columns.length;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        final position =
            _pageController.hasClients && _pageController.position.hasPixels
            ? (_pageController.page ?? 0.0)
            : 0.0;
        final current = position.round();

        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _goToPage(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == current ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == current
                            ? tokens.primaryColor
                            : tokens.mutedTextColor.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Uma coluna do layout largo. Escondida (durante o arrasto dela), não ocupa
/// espaço mas segue montada; ter sempre o mesmo tipo de widget aqui evita que
/// o Flutter recrie a coluna (e perca o arrasto) ao esconder.
class _ColumnSlot extends StatelessWidget {
  const _ColumnSlot({
    super.key,
    required this.hidden,
    required this.width,
    required this.child,
  });

  final bool hidden;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: hidden,
      child: SizedBox(width: width, child: child),
    );
  }
}

/// Mantém a página montada mesmo fora da tela: se a coluna de onde o card
/// saiu fosse descartada pelo `PageView`, o fim do arrasto se perderia.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({super.key, required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
