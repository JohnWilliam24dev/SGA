import 'dart:async';

import 'package:easy_ui/easy_ui.dart' show Toast, ToastType;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';

/// Grava o perfil no servidor quando o usuário o altera. Sem repositório
/// (dados simulados), não faz nada: o perfil fica só na tela.
mixin ProfilePersistencia<T extends StatefulWidget> on State<T> {
  MakerRepository? get repositorio;
  String? get makerId;
  Maker get makerAtual;

  Maker? _salvo; // o que o servidor guarda hoje
  Timer? _atraso;

  /// Marca [maker] como o que está no servidor (ao abrir, ou quando o
  /// perfil é recarregado de lá).
  void marcarSalvo(Maker maker) => _salvo = maker;

  @override
  void initState() {
    super.initState();
    _salvo = makerAtual;
  }

  /// Grava o [makerAtual]: já, ou [depois] de uma pausa na digitação (os
  /// termos são salvos enquanto se escreve). [silencioso] só avisa se algo
  /// der errado.
  void persistirMaker({Duration depois = Duration.zero, bool silencioso = false}) {
    if (repositorio == null || makerId == null) return;
    _atraso?.cancel();
    if (depois == Duration.zero) {
      _enviar(silencioso: silencioso);
    } else {
      _atraso = Timer(depois, () => _enviar(silencioso: silencioso));
    }
  }

  Future<void> _enviar({required bool silencioso, bool avisar = true}) async {
    final novo = makerAtual;
    try {
      await repositorio!.salvar(
        makerId!,
        anterior: _salvo ?? novo,
        novo: novo,
      );
      _salvo = novo;
      if (!avisar || !mounted || silencioso) return;
      Toast.show(context, text: 'Perfil salvo.', type: ToastType.success);
    } catch (e) {
      if (!avisar || !mounted) return;
      final texto = mensagemDeErro(e, 'Não foi possível salvar o perfil.');
      Toast.show(context, text: texto, type: ToastType.error);
    }
  }

  @override
  void dispose() {
    final pendente = _atraso?.isActive ?? false;
    _atraso?.cancel();
    // Saiu da tela com um texto ainda por gravar: grava sem avisar.
    if (pendente) _enviar(silencioso: true, avisar: false);
    super.dispose();
  }
}
