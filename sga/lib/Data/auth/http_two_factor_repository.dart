import '../../Core/network/network.dart';
import '../../Domain/domain.dart';

Map<String, dynamic> _mapa(Object? json) =>
    Map<String, dynamic>.from(json as Map);

/// Ativação do 2FA na API: `/auth/2fa/estado`, `/iniciar` e `/confirmar`,
/// mais a renovação que libera a sessão completa. Todas valem também para
/// a sessão restrita (`ativar2fa`).
class HttpDoisFatorRepository implements DoisFatorRepository {
  HttpDoisFatorRepository({required ApiClient client, required SessaoStore sessao})
      : _client = client,
        _sessao = sessao;

  final ApiClient _client;
  final SessaoStore _sessao;

  @override
  Future<DoisFatorInicio?> iniciar() async {
    final estado = _mapa(await _client.get('/auth/2fa/estado'));
    if (estado['ativo'] == true) return null;
    final json = _mapa(await _client.post('/auth/2fa/iniciar'));
    return DoisFatorInicio(
      segredo: json['segredo'] as String,
      uri: json['uri'] as String,
    );
  }

  @override
  Future<List<String>> confirmar(String codigo) async {
    final json = _mapa(
      await _client.post('/auth/2fa/confirmar', corpo: {'codigo': codigo}),
    );
    return List<String>.from(json['codigosRecuperacao'] as List);
  }

  @override
  Future<DoisFatorEstado> estado() async {
    final json = _mapa(await _client.get('/auth/2fa/estado'));
    return DoisFatorEstado(
      ativo: json['ativo'] == true,
      codigosRecuperacaoRestantes:
          (json['codigosRecuperacaoRestantes'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<List<String>> regenerarCodigos({
    required String codigo,
    String? senha,
  }) async {
    final json = _mapa(
      await _client.post(
        '/auth/2fa/codigos-recuperacao',
        corpo: {
          'codigo': codigo,
          if (senha != null && senha.isNotEmpty) 'senha': senha,
        },
      ),
    );
    return List<String>.from(json['codigosRecuperacao'] as List);
  }

  @override
  Future<void> concluirAtivacao() async {
    try {
      await _client.renovarSessao();
    } finally {
      // Dá certo: o escopo vira completo. Dá errado de vez: a sessão foi
      // apagada. Nos dois casos o store precisa reler.
      await _sessao.sincronizar();
    }
  }
}
