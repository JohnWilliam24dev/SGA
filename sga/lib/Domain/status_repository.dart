import 'models/status_model.dart';
import 'status_rules.dart';

/// De onde vêm as colunas do kanban. Hoje é simulado em memória; quando a API
/// entrar, basta uma nova implementação desta interface.
///
/// Toda operação que quebra uma regra do quadro falha com
/// [StatusRegraException].
abstract interface class StatusRepository {
  /// Os status do Maker, ordenados por `ordem`.
  Future<List<StatusModel>> listar();

  /// Cria uma coluna no fim do quadro, do tipo `EM_ANDAMENTO`.
  Future<StatusModel> criar(String nome);

  Future<void> renomear(String id, String nome);

  Future<void> trocarTipo(String id, StatusTipo tipo);

  /// Falha se a coluna tem commissions ou é a última de um tipo obrigatório.
  Future<void> excluir(String id);

  /// [idsNaNovaOrdem] traz todas as colunas, na ordem desejada.
  Future<void> reordenar(List<String> idsNaNovaOrdem);
}

/// Repositório de teste: status em memória, com uma latência simulada.
///
/// Para saber se uma coluna tem commissions (regra de exclusão), consulta
/// [contarCommissions]; sem ele, nenhuma coluna tem.
class FakeStatusRepository implements StatusRepository {
  FakeStatusRepository({
    this.latencia = const Duration(milliseconds: 150),
    List<StatusModel>? status,
    Future<int> Function(String statusId)? contarCommissions,
  })  : _status = ordenarPorOrdem(status ?? statusPadrao()),
        _contarCommissions = contarCommissions ?? ((_) async => 0);

  final Duration latencia;
  List<StatusModel> _status;
  final Future<int> Function(String statusId) _contarCommissions;
  int _proximoId = 1;

  @override
  Future<List<StatusModel>> listar() async {
    await Future<void>.delayed(latencia);
    return List<StatusModel>.unmodifiable(_status);
  }

  @override
  Future<StatusModel> criar(String nome) async {
    await Future<void>.delayed(latencia);
    var id = 'status-${_proximoId++}';
    while (_status.any((s) => s.id == id)) {
      id = 'status-${_proximoId++}';
    }
    _status = criarStatus(_status, id: id, nome: nome);
    return _status.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> renomear(String id, String nome) async {
    await Future<void>.delayed(latencia);
    _status = renomearStatus(_status, id, nome);
  }

  @override
  Future<void> trocarTipo(String id, StatusTipo tipo) async {
    await Future<void>.delayed(latencia);
    _status = trocarTipoDoStatus(_status, id, tipo);
  }

  @override
  Future<void> excluir(String id) async {
    await Future<void>.delayed(latencia);
    final quantidade = await _contarCommissions(id);
    _status = excluirStatus(_status, id, commissionsNoStatus: quantidade);
  }

  @override
  Future<void> reordenar(List<String> idsNaNovaOrdem) async {
    await Future<void>.delayed(latencia);
    _status = reordenarStatus(_status, idsNaNovaOrdem);
  }
}
