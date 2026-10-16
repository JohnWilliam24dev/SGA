import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart'
    show IconButton, Icons, OutlinedButton, Tooltip;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';
import 'detail_body.dart';
import 'detail_data.dart';
import 'detail_header.dart';

/// Detalhe de uma commission, aberto ao tocar no card do quadro.
///
/// No desktop ([compact]) é uma nota de vidro sobre o quadro; no celular, uma
/// página própria que rola. O cabeçalho vem do resumo (já na mão) e o resto é
/// carregado pelo [AsyncView], que refaz a chamada em "Tentar de novo".
class CommissionDetailPage extends StatelessWidget {
  const CommissionDetailPage({
    super.key,
    required this.repository,
    required this.commission,
    required this.statusNome,
    required this.onBack,
    this.compact = false,
    this.catalogo = const FakeCatalogoRepository(),
  });

  final CommissionRepository repository;
  final CommissionResumoModel commission;
  final String statusNome;
  final VoidCallback onBack;
  final bool compact;

  /// Tipos e adicionais que o pedido pode receber.
  final CatalogoRepository catalogo;

  Widget get _cabecalho =>
      DetailHeader(commission: commission, statusNome: statusNome);

  Widget get _corpo => AsyncView<DetailData>(
    load: () => DetailData.carregar(repository, catalogo, commission.id),
    loading: const SizedBox(
      height: 260,
      child: Center(child: Loader(message: 'Carregando detalhes...')),
    ),
    builder: (context, data) => DetailBody(
      data: data,
      compact: compact,
      repository: repository,
      catalogo: catalogo,
    ),
  );

  @override
  Widget build(BuildContext context) => compact ? _nota() : _pagina();

  Widget _nota() {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _cabecalho),
              Tooltip(
                message: 'Fechar detalhes',
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(child: SingleChildScrollView(child: _corpo)),
        ],
      ),
    );
  }

  Widget _pagina() {
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: _voltar()),
                    const SizedBox(height: 16),
                    _cabecalho,
                    const SizedBox(height: 16),
                    _corpo,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _voltar() {
    return OutlinedButton.icon(
      onPressed: onBack,
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('Voltar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF063C68),
        side: const BorderSide(color: Color(0xFF0B79D0)),
        backgroundColor: const Color(0xD9FFFFFF),
      ),
    );
  }
}
