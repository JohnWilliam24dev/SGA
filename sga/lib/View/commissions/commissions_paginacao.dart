import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';

/// "Carregar mais" por coluna: a API traz 50 pedidos por vez.
mixin CommissionsPaginacao on ChangeNotifier {
  CommissionRepository get repository;
  List<CommissionColumn>? get colunas;
  set colunas(List<CommissionColumn>? valor);

  /// Colunas que estão buscando a próxima página agora.
  final Set<String> carregandoMais = {};

  /// Busca a próxima página da coluna e a junta ao que já está na tela;
  /// devolve o motivo se falhou.
  Future<String?> carregarMais(String colunaId) async {
    final atuais = colunas ?? const <CommissionColumn>[];
    final alvo = atuais.where((c) => c.id == colunaId);
    if (alvo.isEmpty || !alvo.first.temMais) return null;
    if (!carregandoMais.add(colunaId)) return null;
    notifyListeners();
    try {
      final pagina = await repository.carregarMais(
        colunaId,
        offset: alvo.first.commissions.length,
      );
      colunas = [
        for (final c in colunas ?? atuais)
          if (c.id == colunaId) _juntar(c, pagina) else c,
      ];
      return null;
    } catch (e) {
      return mensagemDeErro(e, 'Não foi possível carregar mais pedidos.');
    } finally {
      carregandoMais.remove(colunaId);
      notifyListeners();
    }
  }

  /// Acrescenta a página ao fim da coluna, sem repetir pedidos que já
  /// estavam lá (um pedido movido para a coluna pode reaparecer na página).
  CommissionColumn _juntar(
    CommissionColumn coluna,
    Pagina<CommissionResumoModel> pagina,
  ) {
    final ids = {for (final c in coluna.commissions) c.id};
    return coluna.copyWith(
      commissions: [
        ...coluna.commissions,
        ...pagina.itens.where((c) => !ids.contains(c.id)),
      ],
      total: pagina.total,
      temMais: pagina.temMais,
    );
  }
}
