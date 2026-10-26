import 'maker.dart';

/// Perfil do Maker na API. Hoje o servidor só guarda o nome, os termos de
/// serviço e o texto "faço e não faço"; os outros campos do [Maker] valem
/// só enquanto o app está aberto.
abstract interface class MakerRepository {
  /// Perfil guardado no servidor. Sem e-mail nem senha: a API não os devolve.
  Future<Maker> carregar(String makerId);

  /// Grava o que mudou entre [anterior] e [novo] (nada, se nada mudou).
  /// Devolve os campos alterados que o servidor ainda **não** guarda.
  Future<List<String>> salvar(
    String makerId, {
    required Maker anterior,
    required Maker novo,
  });
}
