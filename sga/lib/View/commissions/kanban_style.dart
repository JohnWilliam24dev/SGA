import 'package:easy_ui/easy_ui.dart';

/// Pack do card de pedido: padding enxuto e tipografia um pouco menor que a
/// do resto do app, para caber tudo na altura padrão do card.
///
/// O card o aplica a si mesmo, assim o card "na mão" durante o arrasto (que
/// é desenhado fora da página) fica igual ao da coluna.
final StylePack sgaKanbanPack = StylePack.define(
  name: 'sga_kanban',
  card: const CardStyleSpec(
    radius: 10,
    elevation: ElevationLevel.subtle,
    paddingSteps: 1,
  ),
  label: const LabelStyleSpec(subtitleScale: 1.05, captionScale: 0.93),
);

StylePack _boardPack(double columnOpacity) => StylePack.define(
  name: 'sga_board',
  card: const CardStyleSpec(
    radius: 14,
    elevation: ElevationLevel.none,
    paddingSteps: 0,
  ),
  kanban: KanbanStyleSpec(
    radius: 14,
    columnBackgroundOpacity: columnOpacity,
    dragTilt: 0.035,
  ),
  label: const LabelStyleSpec(
    headingScale: 1.1,
    subtitleScale: 1.05,
    captionScale: 0.93,
  ),
);

/// Pack do quadro no tema claro: colunas em azul cheio (sem moldura
/// branca), título de coluna em ~15px e o card inclinado (~2°) enquanto é
/// arrastado, como no Trello.
final StylePack sgaBoardPack = _boardPack(1);

// No escuro o azul cheio estoura contra o fundo; com metade da opacidade a
// coluna vira um azul profundo, que ainda destaca os cards escuros.
final StylePack _sgaBoardPackDark = _boardPack(0.5);

/// O pack do quadro para o tema atual.
StylePack sgaBoardPackFor({required bool dark}) =>
    dark ? _sgaBoardPackDark : sgaBoardPack;
