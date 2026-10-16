import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';

/// Rota de página do app (uma tela empilhada no Navigator).
Route<void> appRoute(WidgetBuilder builder) {
  return MaterialPageRoute<void>(builder: builder);
}

/// Dados de commissions simulados em memória (até a integração com o banco).
/// Um só repositório para o app todo, para o quadro lembrar as mudanças
/// enquanto o app estiver aberto.
final CommissionRepository commissionRepository = FakeCommissionRepository(
  statusRepository: statusRepository,
);

/// Tipos de produto e adicionais disponíveis para montar um pedido.
final CatalogoRepository catalogoRepository = const FakeCatalogoRepository();

/// As colunas do quadro (status do Maker). Pergunta ao repositório de
/// commissions quantos cartões há em cada uma, para não excluir coluna cheia.
final StatusRepository statusRepository = FakeStatusRepository(
  contarCommissions: (statusId) => commissionRepository.contarPorStatus(statusId),
);
