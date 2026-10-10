import 'commission_board.dart';
import 'commission_column.dart';
import 'models/models.dart';
import 'status_repository.dart';

/// De onde vem o quadro de commissions. Hoje é simulado em memória; quando o
/// banco entrar, basta uma nova implementação desta interface.
abstract interface class CommissionRepository {
  /// Colunas do quadro, cada uma com seus resumos, na ordem de exibição.
  Future<List<CommissionColumn>> carregarQuadro();

  /// Dados completos de uma commission, para a tela de detalhe. Falha se o
  /// [commissionId] não existir.
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId);

  /// Registra a nova posição de uma commission. [paraIndice] segue a mesma
  /// regra de [moverCommission].
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  });

  /// Quantas commissions estão no status [statusId]. Serve à regra de que uma
  /// coluna com commissions não pode ser excluída.
  Future<int> contarPorStatus(String statusId);
}

/// Repositório de teste: dados fixos em memória, com uma latência simulada.
///
/// As colunas do quadro vêm do [StatusRepository] (os status do Maker); aqui
/// ficam só as commissions de cada status. O quadro e o detalhe vêm da mesma
/// fonte: o detalhe de uma commission sempre reflete a coluna e a posição em
/// que ela está no quadro.
class FakeCommissionRepository implements CommissionRepository {
  FakeCommissionRepository({
    this.latencia = const Duration(milliseconds: 400),
    StatusRepository? statusRepository,
    Map<String, CommissionDetalhadaModel>? detalhes,
  }) : _detalhes = detalhes ?? {for (final d in detalhesDeExemplo()) d.id: d} {
    _status = statusRepository ??
        FakeStatusRepository(
          latencia: latencia,
          contarCommissions: contarPorStatus,
        );
    _porStatus = _agrupar(_detalhes.values);
  }

  final Duration latencia;
  final Map<String, CommissionDetalhadaModel> _detalhes;
  late final StatusRepository _status;
  late Map<String, List<CommissionResumoModel>> _porStatus;

  /// Os status que montam as colunas deste quadro.
  StatusRepository get statusRepository => _status;

  @override
  Future<List<CommissionColumn>> carregarQuadro() async {
    await Future<void>.delayed(latencia);
    return List<CommissionColumn>.unmodifiable(
      _montarQuadro(await _status.listar()),
    );
  }

  @override
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId) async {
    await Future<void>.delayed(latencia);
    final base = _detalhes[commissionId];
    if (base == null) {
      throw StateError('Commission $commissionId não encontrada');
    }
    for (final coluna in _montarQuadro(await _status.listar())) {
      final indice = coluna.commissions.indexWhere((c) => c.id == commissionId);
      if (indice != -1) {
        return base.copyWith(statusId: coluna.id, posicao: indice);
      }
    }
    return base;
  }

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) async {
    await Future<void>.delayed(latencia);
    final colunas = moverCommission(
      _montarQuadro(await _status.listar()),
      commissionId: commissionId,
      paraColunaId: paraColunaId,
      paraIndice: paraIndice,
    );
    _porStatus = {
      for (final coluna in colunas) coluna.id: [...coluna.commissions],
    };
  }

  @override
  Future<int> contarPorStatus(String statusId) async {
    return _porStatus[statusId]?.length ?? 0;
  }

  List<CommissionColumn> _montarQuadro(List<StatusModel> status) {
    return [
      for (final s in status)
        CommissionColumn(
          id: s.id,
          titulo: s.nome,
          tipo: s.tipo,
          ordem: s.ordem,
          commissions: [...?_porStatus[s.id]],
        ),
    ];
  }

  /// Agrupa por status e ordena cada grupo por `posicao`; `criadoEm` e o id
  /// desempatam (a posição pode repetir).
  static Map<String, List<CommissionResumoModel>> _agrupar(
    Iterable<CommissionDetalhadaModel> detalhes,
  ) {
    final ordenados = detalhes.toList()
      ..sort((a, b) {
        final porPosicao = a.posicao.compareTo(b.posicao);
        if (porPosicao != 0) return porPosicao;
        final porData = a.criadoEm.compareTo(b.criadoEm);
        return porData != 0 ? porData : a.id.compareTo(b.id);
      });
    final mapa = <String, List<CommissionResumoModel>>{};
    for (final d in ordenados) {
      mapa.putIfAbsent(d.statusId, () => <CommissionResumoModel>[]).add(d.resumo);
    }
    return mapa;
  }

  /// Os dados completos das onze commissions de exemplo, nos status padrão
  /// (Fila, Em andamento e Concluído; Cancelado começa vazio).
  static List<CommissionDetalhadaModel> detalhesDeExemplo() {
    return [
      _exemplo(
        id: 'c1',
        status: 'fila',
        posicao: 0,
        cliente: 'Marina Costa',
        tipo: 'Ilustração',
        precoSimulado: 280,
        contato: '@marinacosta',
        email: 'marina.costa@exemplo.com',
        dia: 1,
        descricao: 'Ilustração full body da personagem original para campanha '
            'de RPG de mesa, com fundo simples em tons de azul e paleta fria.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-fundo',
            nome: 'Fundo simples',
            quantidade: 1,
            descricaoCliente: 'Gradiente azul, sem cenário.',
            valorUnitario: 40,
          ),
        ],
      ),
      _exemplo(
        id: 'c2',
        status: 'fila',
        posicao: 1,
        cliente: 'Estúdio Aurora',
        tipo: 'Identidade visual',
        precoSimulado: 650,
        contato: '(71) 99999-0002',
        email: 'contato@estudioaurora.exemplo.com',
        dia: 2,
        descricao: 'Logotipo e identidade visual para estúdio de tatuagem, '
            'com variações em preto e branco e aplicação em cartão de visita.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-variacao',
            nome: 'Variação de cor',
            quantidade: 2,
            descricaoCliente: 'Versão P&B e versão monocromática.',
            valorUnitario: 60,
          ),
        ],
      ),
      _exemplo(
        id: 'c3',
        status: 'fila',
        posicao: 2,
        cliente: 'Rafael Mendes',
        tipo: 'Modelo VTuber',
        precoSimulado: 1200,
        contato: '@rafamendes',
        dia: 3,
        descricao: 'Modelo VTuber 2D com expressões básicas, rigging simples '
            'e três variações de roupa para as lives de jogos.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-roupa',
            nome: 'Roupa extra',
            quantidade: 3,
            descricaoCliente: null,
            valorUnitario: 150,
          ),
        ],
      ),
      _exemplo(
        id: 'c4',
        status: 'em-andamento',
        posicao: 0,
        cliente: 'Beatriz Lima',
        tipo: 'Capa de livro',
        precoSimulado: 520,
        orcamentoFinal: 560,
        contato: '@bialima.escreve',
        email: 'beatriz.lima@exemplo.com',
        dia: 4,
        descricao: 'Capa de livro de fantasia com título em letras ornamentadas '
            'e a cena do clímax em destaque, formato para impressão.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-impressao',
            nome: 'Arquivo para impressão',
            quantidade: 1,
            descricaoCliente: 'CMYK com sangria de 3 mm.',
            valorUnitario: 40,
          ),
        ],
      ),
      _exemplo(
        id: 'c5',
        status: 'em-andamento',
        posicao: 1,
        cliente: 'João Pedro Santos',
        tipo: 'Pintura a óleo',
        precoSimulado: 900,
        orcamentoFinal: 980,
        contato: '(75) 98888-0005',
        dia: 5,
        descricao: 'Retrato a óleo de família em tela 60x80, baseado em uma '
            'foto antiga que precisa ser restaurada antes da pintura.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-restauro',
            nome: 'Restauro de foto',
            quantidade: 1,
            descricaoCliente: 'Foto de 1978, com rasgos no canto.',
            valorUnitario: 80,
          ),
        ],
      ),
      _exemplo(
        id: 'c6',
        status: 'em-andamento',
        posicao: 2,
        cliente: 'Camila Duarte',
        tipo: 'Emotes',
        precoSimulado: 360,
        orcamentoFinal: 360,
        contato: '@camiladuarte.live',
        email: 'camila.duarte@exemplo.com',
        dia: 6,
        descricao: 'Pack de 12 emotes para live, estilo chibi, com cores '
            'vibrantes e fundo transparente em três tamanhos.',
        adicionais: const [],
      ),
      _exemplo(
        id: 'c7',
        status: 'em-andamento',
        posicao: 3,
        cliente: 'Loja Entre Linhas',
        tipo: 'Ilustração',
        precoSimulado: 480,
        contato: '(71) 97777-0007',
        email: 'loja@entrelinhas.exemplo.com',
        dia: 7,
        descricao: 'Ilustrações para seis marcadores de página com tema '
            'botânico, em aquarela digital e acabamento texturizado.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-textura',
            nome: 'Acabamento texturizado',
            quantidade: 6,
            descricaoCliente: 'Textura de papel de algodão.',
            valorUnitario: 15,
          ),
        ],
      ),
      _exemplo(
        id: 'c8',
        status: 'em-andamento',
        posicao: 4,
        cliente: 'Thiago Alves',
        tipo: 'Capa de álbum',
        precoSimulado: 420,
        orcamentoFinal: 450,
        contato: '@thiagoalves.beats',
        email: 'thiago.alves@exemplo.com',
        dia: 8,
        descricao: 'Arte de capa de álbum em estilo synthwave, com tipografia '
            'neon e elementos geométricos; cliente pediu ajuste de cor.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-revisao',
            nome: 'Revisão extra',
            quantidade: 1,
            descricaoCliente: 'Ajuste de cor depois da primeira entrega.',
            valorUnitario: 30,
          ),
        ],
      ),
      _exemplo(
        id: 'c9',
        status: 'em-andamento',
        posicao: 5,
        cliente: 'Helena Prado',
        tipo: 'Ilustração',
        precoSimulado: 250,
        contato: '(71) 96666-0009',
        dia: 9,
        descricao: 'Ilustração infantil para convite de aniversário, tema de '
            'safári com animais amigáveis e espaço para o texto.',
        adicionais: const [],
      ),
      _exemplo(
        id: 'c10',
        status: 'concluido',
        posicao: 0,
        cliente: 'Diego Martins',
        tipo: 'Concept art',
        precoSimulado: 700,
        orcamentoFinal: 760,
        contato: '@diegomartins.dev',
        email: 'diego.martins@exemplo.com',
        dia: 10,
        descricao: 'Concept de criatura para jogo indie, com folha de '
            'turnaround e três poses de ação. Arquivos finais enviados.',
        adicionais: const [
          CommissionAdicionalModel(
            adicionalId: 'a-pose',
            nome: 'Pose extra',
            quantidade: 3,
            descricaoCliente: 'Ataque, defesa e idle.',
            valorUnitario: 20,
          ),
        ],
      ),
      _exemplo(
        id: 'c11',
        status: 'concluido',
        posicao: 1,
        cliente: 'Aline Ferreira',
        tipo: 'Mascote',
        precoSimulado: 390,
        orcamentoFinal: 390,
        contato: '(71) 95555-0011',
        email: 'aline@cafeteria.exemplo.com',
        dia: 11,
        descricao: 'Mascote para cafeteria, em versão colorida e versão em '
            'linha para carimbo. Aprovado e pago.',
        adicionais: const [],
      ),
    ];
  }

  static CommissionDetalhadaModel _exemplo({
    required String id,
    required String status,
    required int posicao,
    required String cliente,
    required String tipo,
    required double precoSimulado,
    double? orcamentoFinal,
    required String contato,
    String? email,
    required int dia,
    required String descricao,
    required List<CommissionAdicionalModel> adicionais,
  }) {
    return CommissionDetalhadaModel(
      id: id,
      token: 'tok-$id',
      nomeCliente: cliente,
      tipoProdutoNome: tipo,
      precoSimulado: precoSimulado,
      orcamentoFinal: orcamentoFinal,
      posicao: posicao,
      criadoEm: DateTime.utc(2026, 9, dia, 14, 30),
      statusId: status,
      tipoProdutoId: 'tp-${tipo.toLowerCase().replaceAll(' ', '-')}',
      contato: contato,
      descricao: descricao,
      imagemRefUrl: 'https://exemplo.com/referencias/$id.png',
      email: email,
      adicionais: adicionais,
    );
  }
}
