import '../Core/network/network.dart';
import '../Domain/domain.dart';

/// Texto de erro para a tela: a mensagem da regra ou da API, quando há uma;
/// senão o [padrao].
String mensagemDeErro(Object erro, String padrao) => switch (erro) {
      CommissionRegraException(:final mensagem) => mensagem,
      StatusRegraException(:final mensagem) => mensagem,
      CatalogoRegraException(:final mensagem) => mensagem,
      ProdutoRegraException(:final mensagem) => mensagem,
      final ApiException e => e.mensagemParaUsuario,
      _ => padrao,
    };
