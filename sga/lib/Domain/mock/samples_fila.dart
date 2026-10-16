import '../models/models.dart';
import 'commission_sample.dart';

/// Commissions de exemplo da coluna Fila.
List<CommissionDetalhadaModel> amostrasNaFila() => [
  commissionSample(
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
  commissionSample(
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
  commissionSample(
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
];
