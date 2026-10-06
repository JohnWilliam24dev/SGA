import 'commission.dart';
import 'commission_board.dart';
import 'commission_column.dart';

/// De onde vem o quadro de commissions. Hoje é simulado em memória; quando o
/// banco entrar, basta uma nova implementação desta interface.
abstract interface class CommissionRepository {
  /// Colunas do quadro, cada uma com suas commissions, na ordem de exibição.
  Future<List<CommissionColumn>> carregarQuadro();

  /// Registra a nova posição de uma commission. [paraIndice] segue a mesma
  /// regra de [moverCommission].
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  });
}

/// Repositório de teste: dados fixos em memória, com uma latência simulada.
class FakeCommissionRepository implements CommissionRepository {
  FakeCommissionRepository({
    this.latencia = const Duration(milliseconds: 400),
    List<CommissionColumn>? colunas,
  }) : _colunas = colunas ?? dadosDeExemplo();

  final Duration latencia;
  List<CommissionColumn> _colunas;

  @override
  Future<List<CommissionColumn>> carregarQuadro() async {
    await Future<void>.delayed(latencia);
    return List<CommissionColumn>.unmodifiable(_colunas);
  }

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) async {
    await Future<void>.delayed(latencia);
    _colunas = moverCommission(
      _colunas,
      commissionId: commissionId,
      paraColunaId: paraColunaId,
      paraIndice: paraIndice,
    );
  }

  /// Quatro colunas e onze commissions para ver o quadro funcionando.
  static List<CommissionColumn> dadosDeExemplo() {
    return const [
      CommissionColumn(
        id: 'orcamento',
        titulo: 'Orçamento',
        commissions: [
          Commission(
            id: 'c1',
            cliente: 'Marina Costa',
            descricao: 'Ilustração full body da personagem original para campanha '
                'de RPG de mesa, com fundo simples em tons de azul e paleta fria.',
          ),
          Commission(
            id: 'c2',
            cliente: 'Estúdio Aurora',
            descricao: 'Logotipo e identidade visual para estúdio de tatuagem, '
                'com variações em preto e branco e aplicação em cartão de visita.',
          ),
          Commission(
            id: 'c3',
            cliente: 'Rafael Mendes',
            descricao: 'Modelo VTuber 2D com expressões básicas, rigging simples '
                'e três variações de roupa para as lives de jogos.',
          ),
        ],
      ),
      CommissionColumn(
        id: 'producao',
        titulo: 'Em produção',
        commissions: [
          Commission(
            id: 'c4',
            cliente: 'Beatriz Lima',
            descricao: 'Capa de livro de fantasia com título em letras ornamentadas '
                'e a cena do clímax em destaque, formato para impressão.',
          ),
          Commission(
            id: 'c5',
            cliente: 'João Pedro Santos',
            descricao: 'Retrato a óleo de família em tela 60x80, baseado em uma '
                'foto antiga que precisa ser restaurada antes da pintura.',
          ),
          Commission(
            id: 'c6',
            cliente: 'Camila Duarte',
            descricao: 'Pack de 12 emotes para live, estilo chibi, com cores '
                'vibrantes e fundo transparente em três tamanhos.',
          ),
          Commission(
            id: 'c7',
            cliente: 'Loja Entre Linhas',
            descricao: 'Ilustrações para seis marcadores de página com tema '
                'botânico, em aquarela digital e acabamento texturizado.',
          ),
        ],
      ),
      CommissionColumn(
        id: 'revisao',
        titulo: 'Em revisão',
        commissions: [
          Commission(
            id: 'c8',
            cliente: 'Thiago Alves',
            descricao: 'Arte de capa de álbum em estilo synthwave, com tipografia '
                'neon e elementos geométricos; cliente pediu ajuste de cor.',
          ),
          Commission(
            id: 'c9',
            cliente: 'Helena Prado',
            descricao: 'Ilustração infantil para convite de aniversário, tema de '
                'safári com animais amigáveis e espaço para o texto.',
          ),
        ],
      ),
      CommissionColumn(
        id: 'entregue',
        titulo: 'Entregue',
        commissions: [
          Commission(
            id: 'c10',
            cliente: 'Diego Martins',
            descricao: 'Concept de criatura para jogo indie, com folha de '
                'turnaround e três poses de ação. Arquivos finais enviados.',
          ),
          Commission(
            id: 'c11',
            cliente: 'Aline Ferreira',
            descricao: 'Mascote para cafeteria, em versão colorida e versão em '
                'linha para carimbo. Aprovado e pago.',
          ),
        ],
      ),
    ];
  }
}
