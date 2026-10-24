import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'commission_regra_exception.dart';
import 'models/models.dart';
import 'nova_commission.dart';
import 'pagina.dart';
import 'preco.dart';
import 'status_repository.dart';

/// Criar pedido, trocar adicionais e fechar orçamento do repositório
/// simulado. Quem usa o mixin entrega o acesso aos dados do quadro.
mixin CommissionEdicoes on ChangeNotifier {
  Duration get latencia;
  Map<String, CommissionDetalhadaModel> get detalhes;
  StatusRepository get statusRepository;

  /// Id da coluna em que a commission está agora (null se não existe).
  String? statusIdDe(String commissionId);

  /// Coloca o pedido novo no fim da coluna dele.
  void registrar(CommissionDetalhadaModel novo);

  /// Troca o pedido (mesma coluna e posição) por uma versão editada.
  void atualizar(CommissionDetalhadaModel novo);

  /// O simulado entrega o quadro inteiro de uma vez: nunca sobra página.
  Future<Pagina<CommissionResumoModel>> carregarMais(
    String statusId, {
    required int offset,
  }) async => Pagina(itens: const [], total: offset, temMais: false);

  Future<CommissionDetalhadaModel> criar(NovaCommission nova) async {
    await Future<void>.delayed(latencia);
    final status = await statusRepository.listar();
    final inicial = status.where((s) => s.tipo == StatusTipo.inicial);
    if (inicial.isEmpty) {
      throw const CommissionRegraException('Não há coluna inicial no quadro.');
    }
    _validarAdicionais(nova.adicionais);
    final agora = DateTime.now().toUtc();
    final id = 'c-${agora.microsecondsSinceEpoch}';
    final posicao = detalhes.values
        .where((d) => statusIdDe(d.id) == inicial.first.id)
        .length;
    final criada = CommissionDetalhadaModel(
      id: id,
      token: id.substring(id.length - 5).toUpperCase(),
      nomeCliente: nova.nomeCliente,
      tipoProdutoNome: nova.tipoProdutoNome,
      precoSimulado: nova.precoSimulado,
      posicao: posicao,
      criadoEm: agora,
      statusId: inicial.first.id,
      tipoProdutoId: nova.tipoProdutoId,
      contato: nova.contato,
      descricao: nova.descricao,
      imagemRefUrl: '',
      email: nova.email,
      adicionais: List.unmodifiable(nova.adicionais),
    );
    registrar(criada);
    notifyListeners();
    return criada;
  }

  Future<void> salvarAdicionais(
    String commissionId,
    List<CommissionAdicionalModel> adicionais,
  ) async {
    await Future<void>.delayed(latencia);
    final base = _buscar(commissionId);
    await _exigirEditavel(commissionId);
    _validarAdicionais(adicionais);
    final preco = base.precoSimulado -
        somaDosAdicionais(base.adicionais) +
        somaDosAdicionais(adicionais);
    atualizar(
      base.copyWith(
        precoSimulado: arredondarCentavos(preco < 0 ? 0 : preco),
        adicionais: List.unmodifiable(adicionais),
      ),
    );
    notifyListeners();
  }

  Future<void> fecharOrcamento(String commissionId, double valor) async {
    await Future<void>.delayed(latencia);
    final base = _buscar(commissionId);
    if (valor < 0) {
      throw const CommissionRegraException('Informe um valor maior ou igual a zero.');
    }
    await _exigirEditavel(commissionId);
    atualizar(base.copyWith(orcamentoFinal: arredondarCentavos(valor)));
    notifyListeners();
  }

  Future<bool> orcamentoEditavel(String commissionId) async {
    if (_buscar(commissionId).orcamentoFinal != null) return false;
    final statusId = statusIdDe(commissionId);
    for (final s in await statusRepository.listar()) {
      if (s.id != statusId) continue;
      return s.tipo != StatusTipo.concluido && s.tipo != StatusTipo.cancelado;
    }
    return true;
  }

  CommissionDetalhadaModel _buscar(String id) {
    final base = detalhes[id];
    if (base == null) throw StateError('Commission $id não encontrada');
    return base;
  }

  Future<void> _exigirEditavel(String id) async {
    if (await orcamentoEditavel(id)) return;
    throw const CommissionRegraException(
      'O orçamento deste pedido já foi fechado ou o pedido foi encerrado.',
    );
  }

  void _validarAdicionais(List<CommissionAdicionalModel> lista) {
    final ids = <String>{};
    for (final a in lista) {
      if (a.quantidade < 1 || a.quantidade > quantidadeMaximaDeAdicional) {
        throw const CommissionRegraException(
          'A quantidade de cada adicional vai de 1 a $quantidadeMaximaDeAdicional.',
        );
      }
      if (!ids.add(a.adicionalId)) {
        throw const CommissionRegraException('Adicional repetido no pedido.');
      }
    }
  }
}
