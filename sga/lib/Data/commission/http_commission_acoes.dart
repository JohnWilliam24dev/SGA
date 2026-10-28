import 'dart:convert' show jsonEncode;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Criar pedido, trocar adicionais e fechar orçamento na API
/// (`POST /commissions/manual`, `PUT :id/adicionais` e
/// `POST :id/orcamento/fechar` e `/reabrir`). O preço é sempre do servidor: o app manda
/// só as escolhas e usa o detalhe devolvido.
mixin HttpCommissionAcoes on ChangeNotifier {
  ApiClient get cliente;

  /// 400 e 409 do servidor viram [CommissionRegraException].
  Future<T> regra<T>(Future<T> Function() acao);

  /// A API exige `descricaoCliente` (1 a 500) em cada adicional; sem texto
  /// do Maker, vai o nome do adicional.
  Map<String, Object> _item(CommissionAdicionalModel a) => {
        'adicionalId': a.adicionalId,
        'quantidade': a.quantidade,
        'descricaoCliente': (a.descricaoCliente?.trim().isNotEmpty ?? false)
            ? a.descricaoCliente!.trim()
            : a.nome,
      };

  Future<CommissionDetalhadaModel> criar(NovaCommission nova) => regra(() async {
        final email = nova.email?.trim() ?? '';
        final form = FormData.fromMap({
          if (nova.tipoProdutoId != null) 'tipoProdutoId': nova.tipoProdutoId,
          'nomeCliente': nova.nomeCliente,
          'contato': nova.contato,
          if (email.isNotEmpty) 'email': email,
          'descricao': nova.descricao,
          if (nova.tipoProdutoId != null)
            'adicionais': jsonEncode([for (final a in nova.adicionais) _item(a)]),
        });
        final criada = detalheDeApi(
          mapaDe(await cliente.post('/commissions/manual', corpo: form)),
        );
        notifyListeners();
        return criada;
      });

  Future<void> salvarAdicionais(
    String commissionId,
    List<CommissionAdicionalModel> adicionais,
  ) => regra(() async {
        await cliente.put(
          '/commissions/$commissionId/adicionais',
          corpo: {'adicionais': [for (final a in adicionais) _item(a)]},
        );
        notifyListeners();
      });

  Future<void> fecharOrcamento(String commissionId, double valor) =>
      regra(() async {
        await cliente.post(
          '/commissions/$commissionId/orcamento/fechar',
          corpo: {'orcamentoFinal': duasCasas(valor)},
        );
        notifyListeners();
      });

  /// Fechado e coluna final, lidos do detalhe (`orcamentoFechado` e
  /// `status.tipo`): a API responde 409 em fechar/editar/reabrir fora das
  /// regras, e a tela usa isto para nem oferecer a ação.
  Future<({bool fechado, bool encerrado})> _situacao(String id) async {
    final j = mapaDe(await cliente.get('/commissions/$id'));
    final tipo = mapaDe(j['status'])['tipo'];
    return (
      fechado: j['orcamentoFechado'] == true,
      encerrado: tipo == 'CONCLUIDO' || tipo == 'CANCELADO',
    );
  }

  /// Editável = orçamento aberto e pedido fora de Concluído/Cancelado.
  Future<bool> orcamentoEditavel(String commissionId) => regra(() async {
        final s = await _situacao(commissionId);
        return !s.fechado && !s.encerrado;
      });

  /// Reabrível = orçamento fechado e pedido fora de Concluído/Cancelado.
  Future<bool> orcamentoReabrivel(String commissionId) => regra(() async {
        final s = await _situacao(commissionId);
        return s.fechado && !s.encerrado;
      });

  /// `POST :id/orcamento/reabrir`: o valor final fica gravado e volta a ser
  /// editável.
  Future<void> reabrirOrcamento(String commissionId) => regra(() async {
        await cliente.post('/commissions/$commissionId/orcamento/reabrir');
        notifyListeners();
      });
}
