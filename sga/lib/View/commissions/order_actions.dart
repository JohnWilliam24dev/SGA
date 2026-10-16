import 'package:easy_ui/easy_ui.dart' show Toast, ToastType;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import 'commissions_controller.dart';
import 'new_order_sheet.dart';

/// Criação de pedido pelo Maker, para a tela de commissions: carrega o
/// catálogo, pergunta os dados e entrega o pedido ao controller.
mixin OrderActions<T extends StatefulWidget> on State<T> {
  CommissionsController get controller;
  CatalogoRepository get catalogo;

  void _aviso(String texto, ToastType tipo) =>
      Toast.show(context, text: texto, type: tipo);

  Future<void> novoPedido() async {
    final List<OpcaoDeTipo> opcoes;
    try {
      opcoes = await catalogo.carregarOpcoes();
    } catch (_) {
      if (mounted) _aviso('Não foi possível carregar o catálogo.', ToastType.error);
      return;
    }
    if (!mounted) return;
    if (opcoes.isEmpty) {
      _aviso(
        'Habilite um tipo de produto antes de criar um pedido.',
        ToastType.warning,
      );
      return;
    }
    final nova = await pedirNovoPedido(context, opcoes);
    if (nova == null || !mounted) return;
    final erro = await controller.criarPedido(nova);
    if (!mounted) return;
    if (erro != null) {
      _aviso(erro, ToastType.error);
    } else {
      _aviso('Pedido criado na coluna inicial.', ToastType.success);
    }
  }
}
