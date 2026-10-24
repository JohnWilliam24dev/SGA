import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Quadro e detalhe de commissions na API: `GET /commissions`, paginação por
/// coluna, `GET /commissions/:id` e `PATCH /commissions/:id/mover`.
///
/// Criar pedido, trocar adicionais e fechar orçamento ainda não têm
/// contrato fechado no backend: recusam com uma mensagem clara em vez de
/// fingir que deram certo.
class HttpCommissionRepository extends ChangeNotifier
    implements CommissionRepository {
  HttpCommissionRepository(this._client);

  static const _indisponivel =
      'Esta ação ainda não está disponível com o servidor.';

  final ApiClient _client;

  /// 400 e 409 do servidor viram [CommissionRegraException] (mensagem dele).
  Future<T> _regra<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      if (e.ehRegra) throw CommissionRegraException(e.mensagem);
      rethrow;
    }
  }

  @override
  Future<List<CommissionColumn>> carregarQuadro() => _regra(() async {
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
  }) => _regra(() async {
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
      _regra(() async => detalheDeApi(
            mapaDe(await _client.get('/commissions/$commissionId')),
          ));

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) => _regra(() => _client.patch(
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

  @override
  Future<CommissionDetalhadaModel> criar(NovaCommission nova) async =>
      throw const CommissionRegraException(_indisponivel);

  @override
  Future<void> salvarAdicionais(
    String commissionId,
    List<CommissionAdicionalModel> adicionais,
  ) async => throw const CommissionRegraException(_indisponivel);

  @override
  Future<void> fecharOrcamento(String commissionId, double valor) async =>
      throw const CommissionRegraException(_indisponivel);

  /// Sem a regra do "orçamento fechado" na API, a edição fica desligada.
  @override
  Future<bool> orcamentoEditavel(String commissionId) async => false;
}
