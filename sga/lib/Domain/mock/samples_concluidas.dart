import '../models/models.dart';
import 'commission_sample.dart';

/// Commissions de exemplo da coluna Concluído.
List<CommissionDetalhadaModel> amostrasConcluidas() => [
  commissionSample(
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
  commissionSample(
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
