import 'package:flutter/widgets.dart';

import 'scope_panel.dart';

const _fazPadrao = [
  'Ilustração digital',
  'Capas de álbum',
  'Personagens originais',
];
const _naoFazPadrao = [
  'Imitação de estilo de outro artista',
  'Conteúdo ofensivo ou discriminatório',
];

/// A lista a mostrar: a do Maker ou, se ele ainda não escreveu nada, os
/// exemplos de sempre (que só viram dele se ele os editar).
List<String> itensOuPadrao(List<String> itens, {required bool faz}) =>
    List.of(itens.isEmpty ? (faz ? _fazPadrao : _naoFazPadrao) : itens);

/// Os painéis "Eu faço" e "Eu não faço": lado a lado, ou um sobre o outro
/// quando a tela é [narrow].
class ScopePair extends StatelessWidget {
  const ScopePair({
    super.key,
    required this.faz,
    required this.naoFaz,
    required this.narrow,
    required this.onEdit,
  });

  final List<String> faz;
  final List<String> naoFaz;
  final bool narrow;

  /// Abre o editor da lista: a de "faço" (`true`) ou a de "não faço".
  final void Function({required bool faz}) onEdit;

  @override
  Widget build(BuildContext context) {
    final fazPanel = ScopePanel(
      does: true,
      items: faz,
      onEdit: () => onEdit(faz: true),
    );
    final naoFazPanel = ScopePanel(
      does: false,
      items: naoFaz,
      onEdit: () => onEdit(faz: false),
    );
    if (narrow) {
      return Column(children: [fazPanel, const SizedBox(height: 12), naoFazPanel]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: fazPanel),
        const SizedBox(width: 14),
        Expanded(child: naoFazPanel),
      ],
    );
  }
}
