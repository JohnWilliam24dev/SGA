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
    required this.catalogoAdmin,
    required this.produtos,
    required this.relatorios,
    required this.config,
    this.maker,
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
      catalogoAdmin: FakeCatalogoAdminRepository(),
      produtos: FakeProdutoRepository(),
      relatorios: FakeRelatorioRepository(commission),
      config: FakeConfigMakerRepository(),
    );
  }

  /// Status, quadro, catálogo, produtos, relatórios e perfil na API.
  factory AppDependencies.http(ApiClient client) {
    final catalogo = HttpCatalogoRepository(client);
    return AppDependencies(
      commission: HttpCommissionRepository(client),
      status: HttpStatusRepository(client),
      catalogo: catalogo,
      catalogoAdmin: catalogo,
      produtos: HttpProdutoRepository(client),
      relatorios: HttpRelatorioRepository(client),
      config: HttpConfigMakerRepository(client),
      maker: HttpMakerRepository(client),
    );
  }

  final CommissionRepository commission;
  final StatusRepository status;
  final CatalogoRepository catalogo;
  final CatalogoAdminRepository catalogoAdmin;
  final ProdutoRepository produtos;
  final RelatorioRepository relatorios;
  final ConfigMakerRepository config;

  /// Perfil na API; `null` nos dados simulados (o perfil fica só no app).
  final MakerRepository? maker;
}
