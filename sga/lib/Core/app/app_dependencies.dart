import '../../Data/data.dart';
import '../../Domain/domain.dart';
import '../network/network.dart';

/// Os repositórios da área logada, reunidos num lugar só. O app escolhe aqui
/// entre os dados simulados (testes e demo) e os da API.
class AppDependencies {
  const AppDependencies({
    required this.commission,
    required this.status,
    required this.catalogo,
  });

  /// Dados simulados em memória, um conjunto novo a cada chamada.
  factory AppDependencies.simuladas() {
    late final CommissionRepository commission;
    // O status precisa contar os pedidos de cada coluna (regra de exclusão),
    // e o repositório de pedidos precisa do status: um ponta no outro.
    final status = FakeStatusRepository(
      contarCommissions: (statusId) => commission.contarPorStatus(statusId),
    );
    commission = FakeCommissionRepository(statusRepository: status);
    return AppDependencies(
      commission: commission,
      status: status,
      catalogo: const FakeCatalogoRepository(),
    );
  }

  /// Status e quadro na API. O catálogo ainda é simulado (entra em HTTP numa
  /// fase própria).
  factory AppDependencies.http(ApiClient client) => AppDependencies(
        commission: HttpCommissionRepository(client),
        status: HttpStatusRepository(client),
        catalogo: const FakeCatalogoRepository(),
      );

  final CommissionRepository commission;
  final StatusRepository status;
  final CatalogoRepository catalogo;
}
