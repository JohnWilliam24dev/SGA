import '../models/models.dart';
import 'commission_sample.dart';

/// Commissions de exemplo da coluna Em andamento.
List<CommissionDetalhadaModel> amostrasEmAndamento() => [
  commissionSample(
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
  commissionSample(
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
  commissionSample(
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
  commissionSample(
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
  commissionSample(
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
  commissionSample(
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
];
