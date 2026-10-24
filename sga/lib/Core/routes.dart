/// Navegação do SGA. As telas não se conhecem: cada uma recebe daqui os
/// callbacks para ir à próxima. O código fica em `routes/`, por assunto:
/// entrada (boas-vindas, login, cadastro), área logada e detalhe do pedido.
library;

export 'routes/auth_routes.dart'
    show
        buildLoginScreen,
        buildRegisterScreen,
        buildTwoFactorSetupScreen,
        buildWelcomeScreen;
export 'routes/commission_routes.dart' show buildCommissionDetailScreen;
export 'routes/main_routes.dart' show buildMainScreen;
