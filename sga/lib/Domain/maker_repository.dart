import 'maker.dart';

/// Perfil do Maker na API: o servidor guarda o nome, os termos de serviço e
/// o texto "faço e não faço" (o [Maker] tem só isso, mais o e-mail da sessão).
abstract interface class MakerRepository {
  /// Perfil guardado no servidor. Sem e-mail nem senha: a API não os devolve.
  Future<Maker> carregar(String makerId);

  /// Grava o que mudou entre [anterior] e [novo] (nada, se nada mudou).
  Future<void> salvar(
    String makerId, {
    required Maker anterior,
    required Maker novo,
  });
}
