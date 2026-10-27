import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Perfil na API: `GET` e `PATCH /makers/me` (o dono vem do token; o
/// `PATCH /makers/:id` foi removido do backend). A API tem só `nome`,
/// `termosCondicoes` e `facoENaoFaco` (as duas listas viram um texto, ver
/// `codificarEscopo`); o resto do [Maker] fica só no app.
class HttpMakerRepository implements MakerRepository {
  HttpMakerRepository(this._client);

  final ApiClient _client;

  @override
  Future<Maker> carregar(String makerId) async {
    final json = mapaDe(await _client.get('/makers/me'));
    final escopo = decodificarEscopo(json['facoENaoFaco'] as String?);
    return Maker(
      nome: json['nome'] as String,
      email: '',
      senha: '',
      aceitouTermos: true,
      termosServico: json['termosCondicoes'] as String? ?? '',
      faz: escopo.faz,
      naoFaz: escopo.naoFaz,
    );
  }

  @override
  Future<List<String>> salvar(
    String makerId, {
    required Maker anterior,
    required Maker novo,
  }) async {
    final corpo = <String, Object>{
      if (novo.nome != anterior.nome) 'nome': novo.nome,
      if (novo.termosServico != anterior.termosServico)
        'termosCondicoes': novo.termosServico,
      if (!_mesmasListas(anterior, novo))
        'facoENaoFaco': codificarEscopo(novo.faz, novo.naoFaz),
    };
    if (corpo.isNotEmpty) await _client.patch('/makers/me', corpo: corpo);
    return [
      if (novo.email != anterior.email) 'e-mail',
      if (novo.nomeArtistico != anterior.nomeArtistico) 'nome artístico',
      if (novo.portfolio != anterior.portfolio) 'portfólio',
      if (novo.biografia != anterior.biografia) 'biografia',
      if (novo.telefone != anterior.telefone) 'telefone',
      if (novo.cidade != anterior.cidade) 'cidade',
      if (novo.estado != anterior.estado) 'estado',
      if (novo.instagram != anterior.instagram) 'instagram',
    ];
  }

  bool _mesmasListas(Maker a, Maker b) =>
      a.faz.join('\n') == b.faz.join('\n') &&
      a.naoFaz.join('\n') == b.naoFaz.join('\n');
}
