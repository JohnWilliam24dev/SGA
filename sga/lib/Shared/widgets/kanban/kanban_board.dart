import 'dart:async';
import 'dart:math' as math;

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart' show Scrollbar;
import 'package:flutter/rendering.dart' show RenderBox;
import 'package:flutter/widgets.dart' hide Icon;

import 'kanban_column_view.dart';
import 'kanban_models.dart';

/// Quadro kanban multiplataforma, no estilo Trello/Jira.
///
/// Recebe uma **lista de colunas** (não há colunas fixas) e é *controlado*:
/// ao soltar um card o board só avisa por [onMove]; quem guarda o estado
/// atualiza a lista e o board se redesenha.
///
/// **Desktop/tablet largo:** colunas lado a lado numa faixa com rolagem
/// horizontal. Arrasta-se o card direto com o mouse; perto das bordas o
/// quadro rola sozinho (na horizontal e dentro de cada coluna).
///
/// **Celular:** uma coluna por vez, em páginas que sempre encaixam (nunca
/// ficam pela metade); um leve deslizar vai para a coluna seguinte. O card é
/// pego com um toque longo; ao levá-lo até a borda da tela, o quadro troca de
/// coluna sozinho.
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
    this.cardHeight = 112,
    this.emptyLabel = 'Nenhum item aqui',
  }) : assert(cardHeight > 0, 'cardHeight deve ser > 0.');

  final List<KanbanColumnData<T>> columns;
  final String Function(T item) itemId;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<KanbanMove> onMove;
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
  final PageController _pageController =
      PageController(viewportFraction: _pageFraction);
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

  bool get _useLongPress {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return false;
    }
  }

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
    final count =
        column.items.where((i) => widget.itemId(i) != _draggingId).length;
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
    if (_draggingId == null || pointer == null) return;

    _autoScrollList(pointer);
    if (_mobileLayout) {
      _autoFlipPage(pointer);
    } else {
      _autoScrollBoard(pointer);
    }
    // Rolar (ou trocar de página) muda o que está sob o ponteiro parado.
    _updateHover();
  }

  double _edgeDelta(double value, double start, double end, [double edge = _edge]) {
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
    final target = math.max(0, math.min(widget.columns.length - 1, current + direction));
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
        final height = constraints.hasBoundedHeight ? constraints.maxHeight : 480.0;
        // Páginas (uma coluna por vez) só em aparelho de toque: com mouse, uma
        // janela estreita continua com as colunas lado a lado e rolagem.
        final mobile = _useLongPress &&
            Breakpoints.standard.sizeFor(width) == ScreenSize.mobile;
        _mobileLayout = mobile;

        // Por padrão o Flutter não deixa o mouse arrastar áreas roláveis;
        // aqui deixamos (arrastar o fundo do quadro rola, como no Trello).
        final behavior = ScrollConfiguration.of(context).copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        );

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
      useLongPress: _useLongPress,
      emptyLabel: widget.emptyLabel,
      itemId: widget.itemId,
      itemBuilder: widget.itemBuilder,
      onDragStarted: (id) => _onDragStarted(id, column.id),
      onDragUpdate: _onDragUpdate,
      onDragEnd: _onDragEnd,
    );
  }

  Widget _buildDesktop(double height) {
    final columns = widget.columns;
    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: math.max(0.0, height - 32),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(width: _desktopSpacing),
                SizedBox(
                  width: _desktopColumnWidth,
                  child: _buildColumn(
                    columns[i],
                    _desktopColumnWidth - 2 * _listPadding,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
        final position = _pageController.hasClients &&
                _pageController.position.hasPixels
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
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
