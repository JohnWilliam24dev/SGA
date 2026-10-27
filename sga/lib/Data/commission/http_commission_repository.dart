import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';
import 'http_commission_acoes.dart';

/// Quadro e detalhe de commissions na API: `GET /commissions`, paginação por
/// coluna, `GET /commissions/:id` e `PATCH /commissions/:id/mover`.
///
/// Criar pedido, adicionais e orçamento ficam em [HttpCommissionAcoes].
class HttpCommissionRepository extends ChangeNotifier
    with HttpCommissionAcoes
    implements CommissionRepository {
  HttpCommissionRepository(this._client);

  final ApiClient _client;

  @override
  ApiClient get cliente => _client;

  /// 400 e 409 do servidor viram [CommissionRegraException] (mensagem dele).
  @override
  Future<T> regra<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      if (e.ehRegra) throw CommissionRegraException(e.mensagem);
      rethrow;
    }
  }

  @override
  Future<List<CommissionColumn>> carregarQuadro() => regra(() async {
        final json = mapaDe(await _client.get('/commissions'));
        final colunas = [
          for (final c in listaDe(json['colunas'])) colunaDeApi(c),
        ];
        return colunas..sort((a, b) => a.ordem.compareTo(b.ordem));
      });

  @override
  Future<Pagina<CommissionResumoModel>> carregarMais(
    String statusId, {
    required int offset,
  }) => regra(() async {
        final json = mapaDe(
          await _client.get(
            '/commissions',
            query: {'statusId': statusId, 'offset': offset},
          ),
        );
        final coluna = colunaDeApi(listaDe(json['colunas']).first);
        return Pagina(
          itens: coluna.commissions,
          total: coluna.quantidade,
          temMais: coluna.temMais,
        );
      });

  @override
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId) =>
      regra(() async => detalheDeApi(
            mapaDe(await _client.get('/commissions/$commissionId')),
          ));

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) => regra(() => _client.patch(
        '/commissions/$commissionId/mover',
        corpo: {
          'statusId': paraColunaId,
          'posicao': paraIndice.clamp(0, 100000),
        },
      ));

  @override
  Future<int> contarPorStatus(String statusId) async {
    for (final s in listaDe(await _client.get('/status'))) {
      if (s['id'] == statusId) return s['totalCommissions'] as int? ?? 0;
    }
    return 0;
  }
}
