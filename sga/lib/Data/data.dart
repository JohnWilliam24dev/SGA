/// Camada de dados: repositórios que falam com a API (e suas versões
/// simuladas). Os contratos ficam em `Domain/`.
library;

export 'auth/fake_auth_repository.dart';
export 'auth/fake_two_factor_repository.dart';
export 'auth/http_auth_repository.dart';
export 'auth/http_two_factor_repository.dart';
export 'catalogo/http_catalogo_repository.dart';
export 'commission/http_commission_repository.dart';
export 'maker/http_maker_repository.dart';
export 'produto/http_produto_repository.dart';
export 'status/http_status_repository.dart';
