import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' show FormValues, Toast, ToastType;
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../Domain/domain.dart';
import 'products_controller.dart';

/// Ações da tela de Produtos que falam com o usuário: escolher a imagem
/// (já conferindo formato e tamanho), carregar mais e salvar, cada uma
/// avisando o resultado por um Toast.
mixin ProductsAcoes<T extends StatefulWidget> on State<T> {
  ProductsController get controller;

  Future<Uint8List?> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    final bytes = await image?.readAsBytes();
    final erro = bytes == null ? null : erroDaImagem(bytes);
    if (erro != null && mounted) {
      Toast.show(context, text: erro, type: ToastType.warning);
      return null;
    }
    return bytes;
  }

  Future<void> carregarMais() async {
    final erro = await controller.carregarMais();
    if (erro != null && mounted) {
      Toast.show(context, text: erro, type: ToastType.error);
    }
  }

  Future<void> save(FormValues values) async {
    final adicionando = controller.editing == null;
    final aviso = await controller.salvar(values);
    if (!mounted) return;
    if (aviso != null) {
      Toast.show(context, text: aviso, type: ToastType.warning);
      return;
    }
    Toast.show(
      context,
      text: adicionando ? 'Produto adicionado.' : 'Produto atualizado.',
      type: ToastType.success,
    );
  }
}
