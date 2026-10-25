import 'catalogo_admin_repository.dart';
import 'mock/catalogo_seed.dart';
import 'models/models.dart';

/// Catálogo simulado em memória, com os mesmos exemplos de sempre. Tipos e
/// adicionais "em uso" recusam a exclusão, como faz a API.
class FakeCatalogoAdminRepository implements CatalogoAdminRepository {
  FakeCatalogoAdminRepository({
    this.latencia = Duration.zero,
    List<TipoCatalogado>? tipos,
    List<AdicionalModel>? adicionais,
    this.tiposEmUso = tiposEmUsoDeExemplo,
    this.adicionaisEmUso = adicionaisEmUsoDeExemplo,
  })  : _tipos = [...tipos ?? tiposDeExemplo()],
        _adicionais = [...adicionais ?? adicionaisDeExemplo()];

  final Duration latencia;
  final Set<String> tiposEmUso;
  final Set<String> adicionaisEmUso;
  final List<TipoCatalogado> _tipos;
  final List<AdicionalModel> _adicionais;
  int _proximoId = 1;

  Future<void> _esperar() => Future<void>.delayed(latencia);

  @override
  Future<List<TipoCatalogado>> listarTipos() async {
    await _esperar();
    return List.unmodifiable(_tipos);
  }

  @override
  Future<List<AdicionalModel>> listarAdicionais() async {
    await _esperar();
    return List.unmodifiable(_adicionais);
  }

  @override
  Future<TipoCatalogado> salvarTipo({
    String? id,
    required String nome,
    required double precoBase,
    required bool habilitado,
    required Set<String> adicionalIds,
  }) async {
    await _esperar();
    final novo = TipoCatalogado(
      tipo: TipoProdutoModel(
        id: id ?? 'type-${_proximoId++}',
        nome: nome,
        precoBase: precoBase,
        habilitado: habilitado,
      ),
      adicionalIds: {...adicionalIds},
    );
    final i = _tipos.indexWhere((t) => t.tipo.id == id);
    if (i == -1) {
      _tipos.insert(0, novo);
    } else {
      _tipos[i] = novo;
    }
    return novo;
  }

  @override
  Future<void> definirTipoHabilitado(String id, bool habilitado) async {
    await _esperar();
    final i = _tipos.indexWhere((t) => t.tipo.id == id);
    if (i == -1) return;
    final t = _tipos[i];
    _tipos[i] = TipoCatalogado(
      tipo: TipoProdutoModel(id: id, nome: t.tipo.nome, precoBase: t.tipo.precoBase, habilitado: habilitado),
      adicionalIds: t.adicionalIds,
    );
  }

  @override
  Future<void> excluirTipo(String id) async {
    await _esperar();
    if (tiposEmUso.contains(id)) {
      throw const CatalogoRegraException(
        'Este tipo já foi usado em pedidos ou no portfólio. Desabilite-o '
        'para mantê-lo fora de novos pedidos.',
      );
    }
    _tipos.removeWhere((t) => t.tipo.id == id);
  }

  @override
  Future<AdicionalModel> salvarAdicional({
    String? id,
    required String nome,
    String? descricao,
    double? precoFixo,
    double? porcentagem,
    required bool habilitado,
  }) async {
    await _esperar();
    final novo = AdicionalModel(
      id: id ?? 'add-${_proximoId++}',
      nome: nome,
      descricao: (descricao ?? '').isEmpty ? null : descricao,
      precoFixo: precoFixo,
      porcentagem: porcentagem,
      habilitado: habilitado,
    );
    final i = _adicionais.indexWhere((a) => a.id == id);
    if (i == -1) {
      _adicionais.insert(0, novo);
    } else {
      _adicionais[i] = novo;
    }
    return novo;
  }

  @override
  Future<void> definirAdicionalHabilitado(String id, bool habilitado) async {
    await _esperar();
    final i = _adicionais.indexWhere((a) => a.id == id);
    if (i == -1) return;
    final a = _adicionais[i];
    _adicionais[i] = AdicionalModel(
      id: id, nome: a.nome, descricao: a.descricao,
      precoFixo: a.precoFixo, porcentagem: a.porcentagem, habilitado: habilitado,
    );
  }

  @override
  Future<void> excluirAdicional(String id) async {
    await _esperar();
    if (adicionaisEmUso.contains(id)) {
      throw const CatalogoRegraException(
        'Este adicional já foi usado em um pedido. Desabilite-o para não '
        'exibi-lo em novos formulários.',
      );
    }
    _adicionais.removeWhere((a) => a.id == id);
    for (var i = 0; i < _tipos.length; i++) {
      _tipos[i] = TipoCatalogado(
        tipo: _tipos[i].tipo,
        adicionalIds: {..._tipos[i].adicionalIds}..remove(id),
      );
    }
  }
}
