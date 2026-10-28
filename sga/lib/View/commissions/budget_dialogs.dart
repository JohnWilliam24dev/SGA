import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

import '../../Shared/formatters.dart';

/// Confirmação de fechar o orçamento (e, com [concluir], mover o pedido
/// para Concluído).
Future<bool> confirmarFechamento(
  BuildContext context,
  double valor, {
  required bool concluir,
}) async {
  final ok = await Modal.confirm(
    context,
    title: concluir ? 'Fechar e concluir?' : 'Fechar orçamento?',
    message:
        'O valor de ${formatarMoeda(valor)} não poderá mais ser editado e '
        'passa a valer no lugar do valor simulado.'
        '${concluir ? ' O pedido vai para a coluna Concluído.' : ''}',
    confirmText: concluir ? 'Fechar e concluir' : 'Fechar orçamento',
  );
  return ok == true;
}

Future<bool> confirmarReabertura(BuildContext context) async {
  final ok = await Modal.confirm(
    context,
    title: 'Reabrir orçamento?',
    message:
        'O valor volta a poder ser editado e deixa de substituir o valor '
        'simulado até você fechar de novo.',
    confirmText: 'Reabrir orçamento',
  );
  return ok == true;
}
