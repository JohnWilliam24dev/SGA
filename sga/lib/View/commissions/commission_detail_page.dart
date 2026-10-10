import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart'
    show IconButton, Icons, OutlinedButton, Tooltip;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';

/// Detalhe de uma commission, aberto ao tocar no card do quadro.
///
/// Recebe o [commission] (resumo) que o card já tem, para mostrar o
/// cabeçalho na hora, e busca os dados completos ([CommissionDetalhadaModel])
/// no [repository]. [statusNome] é o título da coluna onde o card estava.
class CommissionDetailPage extends StatefulWidget {
  const CommissionDetailPage({
    super.key,
    required this.repository,
    required this.commission,
    required this.statusNome,
    required this.onBack,
    this.compact = false,
  });

  final CommissionRepository repository;
  final CommissionResumoModel commission;
  final String statusNome;
  final VoidCallback onBack;

  /// Quando aberto sobre o quadro no desktop, usa o desenho de nota.
  final bool compact;

  @override
  State<CommissionDetailPage> createState() => _CommissionDetailPageState();
}

class _CommissionDetailPageState extends State<CommissionDetailPage> {
  static const double _maxWidth = 720;
  static const double _margin = 24;

  CommissionDetalhadaModel? _detalhe;
  bool _falhou = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _falhou = false);
    try {
      final detalhe = await widget.repository.carregarDetalhe(
        widget.commission.id,
      );
      if (!mounted) return;
      setState(() => _detalhe = detalhe);
    } catch (_) {
      if (!mounted) return;
      setState(() => _falhou = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _nota();
    return Tela(
      padding: 0.px,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF159AFF), Color(0xFF74C8FF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(_margin),
                child: Div(
                  width: 100.pct,
                  gap: 16.px,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Voltar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF063C68),
                          side: const BorderSide(color: Color(0xFF0B79D0)),
                          backgroundColor: const Color(0xD9FFFFFF),
                        ),
                      ),
                    ),
                    _cabecalho(),
                    ..._corpo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nota() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Div(
          width: 100.pct,
          gap: 12.px,
          children: [
            Div(
              direction: LayoutDirection.horizontal,
              align: Alignment.centerLeft,
              children: [
                LayoutItem(size: 1.fr, child: _cabecalho()),
                Tooltip(
                  message: 'Fechar detalhes',
                  child: IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
            ..._corpoCompacto(),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    final resumo = widget.commission;
    return Div(
      direction: LayoutDirection.horizontal,
      align: Alignment.centerLeft,
      gap: 12.px,
      children: [
        Avatar(name: resumo.nomeCliente, size: AvatarSize.md),
        LayoutItem(
          size: 1.fr,
          child: Div(
            gap: 2.px,
            children: [
              Label(type: LabelType.title, text: resumo.nomeCliente),
              Label(
                type: LabelType.caption,
                text: '${resumo.tipoProdutoNome} · ${widget.statusNome}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _corpo() {
    if (_falhou) {
      return [
        Div(
          width: 100.pct,
          align: Alignment.center,
          children: [
            const Label(
              type: LabelType.error,
              text: 'Não foi possível carregar os detalhes',
            ),
            Button(
              text: 'Tentar de novo',
              variant: ButtonVariant.outline,
              onPressed: _carregar,
            ),
          ],
        ),
      ];
    }
    final detalhe = _detalhe;
    if (detalhe == null) {
      return const [Loader(message: 'Carregando detalhes...')];
    }
    return [
      _secao('Orçamento', [
        _campo('Valor simulado', formatarMoeda(detalhe.precoSimulado)),
        _campo(
          'Orçamento final',
          detalhe.orcamentoFinal == null
              ? 'Ainda não fechado'
              : formatarMoeda(detalhe.orcamentoFinal!),
        ),
      ]),
      _secao('Pedido', [
        _campo('Descrição', detalhe.descricao),
        _referencia(detalhe.imagemRefUrl),
      ]),
      _secao('Adicionais', _adicionais(detalhe.adicionais)),
      _secao('Contato', [
        _campo('Contato', detalhe.contato),
        if (detalhe.email != null) _campo('E-mail', detalhe.email!),
      ]),
      _secao('Acompanhamento', [
        _campo('Código', detalhe.token),
        _campo('Criada em', formatarDataHora(detalhe.criadoEm)),
      ]),
    ];
  }

  List<Widget> _corpoCompacto() {
    if (_falhou) return _corpo();
    final detalhe = _detalhe;
    if (detalhe == null) {
      return const [
        SizedBox(
          height: 260,
          child: Center(child: Loader(message: 'Carregando detalhes...')),
        ),
      ];
    }

    return [
      Div(
        direction: LayoutDirection.horizontal,
        gap: 12.px,
        children: [
          LayoutItem(
            size: 1.fr,
            child: _secaoCompacta('Orçamento', [
              _campo('Valor simulado', formatarMoeda(detalhe.precoSimulado)),
              _campo(
                'Orçamento final',
                detalhe.orcamentoFinal == null
                    ? 'Ainda não fechado'
                    : formatarMoeda(detalhe.orcamentoFinal!),
              ),
            ]),
          ),
          LayoutItem(
            size: 1.fr,
            child: _secaoCompacta('Contato', [
              _campo('Contato', detalhe.contato),
              if (detalhe.email != null) _campo('E-mail', detalhe.email!),
            ]),
          ),
        ],
      ),
      _secaoCompacta('Pedido', [
        _campo('Descrição', detalhe.descricao),
        const SizedBox(height: 4),
        _referenciaCompacta(detalhe.imagemRefUrl),
      ]),
      Div(
        direction: LayoutDirection.horizontal,
        gap: 12.px,
        children: [
          LayoutItem(
            size: 1.fr,
            child: _secaoCompacta(
              'Adicionais',
              _adicionais(detalhe.adicionais),
            ),
          ),
          LayoutItem(
            size: 1.fr,
            child: _secaoCompacta('Acompanhamento', [
              _campo('Código', detalhe.token),
              _campo('Criada em', formatarDataHora(detalhe.criadoEm)),
            ]),
          ),
        ],
      ),
    ];
  }

  List<Widget> _adicionais(List<CommissionAdicionalModel> adicionais) {
    if (adicionais.isEmpty) {
      return const [
        Label(type: LabelType.caption, text: 'Nenhum adicional neste pedido.'),
      ];
    }
    return [
      for (final adicional in adicionais)
        Div(
          width: 100.pct,
          gap: 2.px,
          children: [
            Label(
              type: LabelType.subtitle,
              text: '${adicional.quantidade}x ${adicional.nome}',
            ),
            Label(
              type: LabelType.caption,
              text:
                  '${formatarMoeda(adicional.valorUnitario)} cada · '
                  'subtotal ${formatarMoeda(adicional.subtotal)}',
            ),
            if (adicional.descricaoCliente != null)
              Label(type: LabelType.caption, text: adicional.descricaoCliente!),
          ],
        ),
    ];
  }

  Widget _secao(String titulo, List<Widget> filhos) {
    return GlassPanel(
      padding: const EdgeInsets.all(18),
      child: Div(
        width: 100.pct,
        gap: 10.px,
        children: [
          Label(type: LabelType.subtitle, text: titulo),
          ...filhos,
        ],
      ),
    );
  }

  Widget _secaoCompacta(String titulo, List<Widget> filhos) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x14336E99),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Div(
          width: 100.pct,
          gap: 6.px,
          children: [
            Label(type: LabelType.subtitle, text: titulo),
            ...filhos,
          ],
        ),
      ),
    );
  }

  Widget _campo(String rotulo, String valor) {
    return Div(
      width: 100.pct,
      gap: 0.px,
      children: [
        Label(type: LabelType.caption, text: rotulo),
        Label(text: valor),
      ],
    );
  }

  Widget _referencia(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 80,
            width: double.infinity,
            child: Center(
              child: Label(
                type: LabelType.caption,
                text: 'Imagem de referência indisponível',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _referenciaCompacta(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: double.infinity,
        // Mantém a nota inteira em telas desktop mais baixas, sem transformar
        // o detalhe em uma página rolável.
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 56,
          child: Center(
            child: Label(
              type: LabelType.caption,
              text: 'Imagem de referência indisponível',
            ),
          ),
        ),
      ),
    );
  }
}
