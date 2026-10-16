import 'models/models.dart';

/// Um tipo de produto habilitado com os adicionais que ele oferece.
class OpcaoDeTipo {
  const OpcaoDeTipo({required this.tipo, required this.adicionais});

  final TipoProdutoModel tipo;
  final List<AdicionalModel> adicionais;
}

/// De onde vêm os tipos e adicionais usados para montar um pedido.
abstract interface class CatalogoRepository {
  /// Só os tipos habilitados, cada um com seus adicionais habilitados.
  Future<List<OpcaoDeTipo>> carregarOpcoes();
}

/// Catálogo de exemplo em memória, com os tipos das commissions de teste.
class FakeCatalogoRepository implements CatalogoRepository {
  const FakeCatalogoRepository();

  static const _tipos = <(String, double)>[
    ('Ilustração', 120),
    ('Emotes', 35),
    ('Identidade visual', 400),
    ('Modelo VTuber', 900),
    ('Capa de livro', 300),
    ('Capa de álbum', 280),
    ('Concept art', 250),
    ('Mascote', 220),
    ('Pintura a óleo', 600),
  ];

  static const _adicionais = <AdicionalModel>[
    AdicionalModel(id: 'a-fundo', nome: 'Fundo simples', precoFixo: 40, habilitado: true),
    AdicionalModel(id: 'a-roupa', nome: 'Roupa extra', precoFixo: 80, habilitado: true),
    AdicionalModel(id: 'a-pose', nome: 'Pose extra', precoFixo: 60, habilitado: true),
    AdicionalModel(id: 'a-variacao', nome: 'Variação de cor', precoFixo: 60, habilitado: true),
    AdicionalModel(id: 'a-revisao', nome: 'Revisão extra', precoFixo: 30, habilitado: true),
    AdicionalModel(id: 'a-impressao', nome: 'Arquivo para impressão', precoFixo: 50, habilitado: true),
    AdicionalModel(id: 'a-textura', nome: 'Acabamento texturizado', porcentagem: 15, habilitado: true),
    AdicionalModel(id: 'a-express', nome: 'Entrega expressa', porcentagem: 20, habilitado: true),
  ];

  /// Mesma regra de id das commissions de exemplo (`tp-nome-do-tipo`).
  static String idDoTipo(String nome) =>
      'tp-${nome.toLowerCase().replaceAll(' ', '-')}';

  @override
  Future<List<OpcaoDeTipo>> carregarOpcoes() async => [
    for (final (nome, base) in _tipos)
      OpcaoDeTipo(
        tipo: TipoProdutoModel(
          id: idDoTipo(nome),
          nome: nome,
          precoBase: base,
          habilitado: true,
        ),
        adicionais: _adicionais,
      ),
  ];
}
