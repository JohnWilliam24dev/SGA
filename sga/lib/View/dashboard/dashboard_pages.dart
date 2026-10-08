import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' show Breakpoints, ScreenSize;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:image_picker/image_picker.dart';

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';

/// Páginas de visão operacional. Elas recebem o mesmo contrato de pedidos da
/// tela Kanban: trocar o fake por uma implementação HTTP atualiza todas sem
/// acoplamento com widgets ou dados estáticos de interface.
class FinanceiroPage extends StatelessWidget {
  const FinanceiroPage({super.key, required this.repository});
  final CommissionRepository repository;

  @override
  Widget build(BuildContext context) => _BoardLoader(
    repository: repository,
    builder: (orders) {
      final paid = orders.where((o) => o.orcamentoFinal != null).toList();
      final income = paid.fold<double>(0, (sum, o) => sum + o.orcamentoFinal!);
      return _PageScroll(
        children: [
          _MetricGrid(
            items: [
              _Metric(
                'Receita do mês',
                formatarMoeda(income),
                Icons.account_balance_wallet_outlined,
              ),
              _Metric(
                'A receber',
                formatarMoeda(
                  orders
                      .where((o) => o.orcamentoFinal == null)
                      .fold<double>(0, (sum, o) => sum + o.precoSimulado),
                ),
                Icons.payments_outlined,
              ),
              _Metric(
                'Pedidos pagos',
                '${paid.length}',
                Icons.task_alt_rounded,
              ),
              _Metric(
                'Ticket médio',
                formatarMoeda(paid.isEmpty ? 0 : income / paid.length),
                Icons.bar_chart_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 780;
              final chart = _RevenueChart(total: income);
              final movements = _MovementList(orders: paid.take(5).toList());
              return stacked
                  ? Column(
                      children: [chart, const SizedBox(height: 14), movements],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: chart),
                        const SizedBox(width: 14),
                        Expanded(flex: 2, child: movements),
                      ],
                    );
            },
          ),
        ],
      );
    },
  );
}

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key, required this.repository});
  final CommissionRepository repository;
  @override
  Widget build(BuildContext context) => _BoardLoader(
    repository: repository,
    builder: (orders) {
      final done = orders.where((o) => o.orcamentoFinal != null).length;
      return _PageScroll(
        children: [
          _MetricGrid(
            items: [
              _Metric(
                'Pedidos no mês',
                '${orders.length}',
                Icons.receipt_long_outlined,
              ),
              const _Metric(
                'Prazo médio de entrega',
                '6 dias',
                Icons.schedule_outlined,
              ),
              _Metric(
                'Taxa de conclusão',
                '${((done / orders.length) * 100).round()}%',
                Icons.trending_up_rounded,
              ),
              const _Metric(
                'Clientes recorrentes',
                '12',
                Icons.people_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final charts = [const _TypeChart(), _StatusChart(orders: orders)];
              return constraints.maxWidth < 780
                  ? Column(
                      children: [
                        charts[0],
                        const SizedBox(height: 14),
                        charts[1],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: charts[0]),
                        const SizedBox(width: 14),
                        Expanded(child: charts[1]),
                      ],
                    );
            },
          ),
        ],
      );
    },
  );
}

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});
  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  _MobileProductsView _mobileView = _MobileProductsView.menu;

  final _types = const <TipoProdutoModel>[
    TipoProdutoModel(
      id: 'tipo-3d',
      nome: 'Modelo 3D',
      precoBase: 450,
      habilitado: true,
    ),
    TipoProdutoModel(
      id: 'tipo-ilustracao',
      nome: 'Ilustração 2D',
      precoBase: 120,
      habilitado: true,
    ),
    TipoProdutoModel(
      id: 'tipo-emote',
      nome: 'Emotes',
      precoBase: 150,
      habilitado: true,
    ),
  ];
  final _products = <ProdutoModel>[
    const ProdutoModel(
      id: 'produto-1',
      nome: 'Modelo 3D Vroid completo',
      imagemUrl: '',
      tipoProdutoId: 'tipo-3d',
      descricao: 'Modelo para portfólio',
    ),
    const ProdutoModel(
      id: 'produto-2',
      nome: 'Ilustração 2D (busto)',
      imagemUrl: '',
      tipoProdutoId: 'tipo-ilustracao',
    ),
    const ProdutoModel(
      id: 'produto-3',
      nome: 'Pack de emotes',
      imagemUrl: '',
      tipoProdutoId: 'tipo-emote',
    ),
  ];
  final _name = TextEditingController();
  final _description = TextEditingController();
  String? _selectedTypeId = 'tipo-3d';
  Uint8List? _selectedImage;
  final Map<String, Uint8List> _imagePreviews = {};
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty ||
        _selectedTypeId == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome, tipo e imagem do produto.'),
        ),
      );
      return;
    }
    final productId = 'produto-mock-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _products.insert(
        0,
        ProdutoModel(
          id: productId,
          nome: _name.text.trim(),
          descricao: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          imagemUrl: '',
          tipoProdutoId: _selectedTypeId!,
        ),
      );
      final image = _selectedImage;
      if (image != null) _imagePreviews[productId] = image;
      _selectedImage = null;
      if (Breakpoints.standard.sizeFor(MediaQuery.sizeOf(context).width) ==
          ScreenSize.mobile) {
        _mobileView = _MobileProductsView.catalog;
      }
    });
    _name.clear();
    _description.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto salvo no catálogo simulado.')),
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _selectedImage = bytes);
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reinicie o aplicativo por completo para ativar a seleção de imagens.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível selecionar a imagem. Tente novamente.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final mobile =
          Breakpoints.standard.sizeFor(constraints.maxWidth) ==
          ScreenSize.mobile;
      final form = _ProductForm(
        name: _name,
        description: _description,
        types: _types,
        selectedTypeId: _selectedTypeId,
        onTypeChanged: (id) => setState(() => _selectedTypeId = id),
        imageBytes: _selectedImage,
        onPickImage: _pickImage,
        onSave: _save,
      );
      final catalog = _ProductCatalog(
        products: _products,
        types: _types,
        imagePreviews: _imagePreviews,
      );

      if (mobile) {
        return _PageScroll(
          children: [
            switch (_mobileView) {
              _MobileProductsView.menu => _MobileProductsMenu(
                onAddProduct: () =>
                    setState(() => _mobileView = _MobileProductsView.form),
                onMyProducts: () =>
                    setState(() => _mobileView = _MobileProductsView.catalog),
              ),
              _MobileProductsView.form => _MobileProductsSection(
                title: 'Adicionar produto',
                onBack: () =>
                    setState(() => _mobileView = _MobileProductsView.menu),
                child: form,
              ),
              _MobileProductsView.catalog => _MobileProductsSection(
                title: 'Meus produtos',
                onBack: () =>
                    setState(() => _mobileView = _MobileProductsView.menu),
                child: catalog,
              ),
            },
          ],
        );
      }

      final stack = constraints.maxWidth < 880;
      return _PageScroll(
        children: [
          stack
              ? Column(children: [form, const SizedBox(height: 14), catalog])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: form),
                    const SizedBox(width: 14),
                    Expanded(flex: 6, child: catalog),
                  ],
                ),
        ],
      );
    },
  );
}

enum _MobileProductsView { menu, form, catalog }

class _MobileProductsMenu extends StatelessWidget {
  const _MobileProductsMenu({
    required this.onAddProduct,
    required this.onMyProducts,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onMyProducts;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'O que você gostaria de fazer?',
          style: TextStyle(fontSize: 13, color: Color(0xFF456078)),
        ),
        const SizedBox(height: 16),
        _MobileProductsActionCard(
          title: 'Adicionar Produto',
          description: 'Cadastre um novo item para o seu portfólio.',
          icon: Icons.add_box_outlined,
          onTap: onAddProduct,
        ),
        const SizedBox(height: 12),
        _MobileProductsActionCard(
          title: 'Meus produtos',
          description: 'Veja e gerencie os produtos já cadastrados.',
          icon: Icons.inventory_2_outlined,
          onTap: onMyProducts,
        ),
      ],
    ),
  );
}

class _MobileProductsActionCard extends StatelessWidget {
  const _MobileProductsActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: GlassPanel(
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0x1A168BF1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: const Color(0xFF168BF1)),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16354C),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF456078),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF168BF1)),
          ],
        ),
      ),
    ),
  );
}

class _MobileProductsSection extends StatelessWidget {
  const _MobileProductsSection({
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Voltar para produtos',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF16354C),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      child,
    ],
  );
}

class _BoardLoader extends StatelessWidget {
  const _BoardLoader({required this.repository, required this.builder});
  final CommissionRepository repository;
  final Widget Function(List<CommissionResumoModel>) builder;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<CommissionColumn>>(
    future: repository.carregarQuadro(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Não foi possível carregar os dados.'));
      }
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      return builder(
        snapshot.data!.expand((column) => column.commissions).toList(),
      );
    },
  );
}

class _PageScroll extends StatelessWidget {
  const _PageScroll({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});
  final List<_Metric> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final mobile =
          Breakpoints.standard.sizeFor(constraints.maxWidth) ==
          ScreenSize.mobile;
      final columns = mobile ? 2 : 4;
      final itemWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final item in items)
            SizedBox(
              width: itemWidth,
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, size: 17, color: const Color(0xFF17659A)),
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF31526B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF09243A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.total});
  final double total;
  @override
  Widget build(BuildContext context) => GlassPanel(
    child: SizedBox(
      height: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receita dos últimos 6 meses (R\$)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16354C),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _BarsPainter(total: total),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.total});
  final double total;
  @override
  void paint(Canvas canvas, Size s) {
    const months = ['Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out'];
    const values = [.52, .64, .58, .76, .81, 1.0];
    final width = s.width / 6;
    for (var i = 0; i < 6; i++) {
      final h = s.height * .68 * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * width + width * .25,
          s.height - h - 24,
          width * .5,
          h,
        ),
        const Radius.circular(7),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF8DCCFF),
            const Color(0xFF168BF1),
            values[i],
          )!,
      );
      final label = TextPainter(
        text: TextSpan(
          text: months[i],
          style: const TextStyle(fontSize: 10, color: Color(0xFF16354C)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
        canvas,
        Offset(i * width + (width - label.width) / 2, s.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) => old.total != total;
}

class _MovementList extends StatelessWidget {
  const _MovementList({required this.orders});
  final List<CommissionResumoModel> orders;
  @override
  Widget build(BuildContext context) => GlassPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimas movimentações',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16354C),
          ),
        ),
        const SizedBox(height: 7),
        for (final order in orders) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.nomeCliente,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      order.token,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF456078),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatarMoeda(order.orcamentoFinal ?? order.precoSimulado),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
        ],
        OutlinedButton(onPressed: () {}, child: const Text('Ver tudo')),
      ],
    ),
  );
}

class _TypeChart extends StatelessWidget {
  const _TypeChart();
  @override
  Widget build(BuildContext context) => GlassPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pedidos por tipo de arte',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16354C),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 340;
            final legend = const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Legend('Modelos 3D · 45%', Color(0xFF168BF1)),
                _Legend('Ilustrações 2D · 30%', Color(0xFF55B6FA)),
                _Legend('Emotes · 15%', Color(0xFF8BCBFA)),
                _Legend('Outros · 10%', Color(0xFFCEECFF)),
              ],
            );
            return narrow
                ? Column(
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: _DonutPainter(),
                      ),
                      const SizedBox(height: 8),
                      legend,
                    ],
                  )
                : Row(
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: _DonutPainter(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: legend),
                    ],
                  );
          },
        ),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: Color(0xFF16354C)),
          ),
        ),
      ],
    ),
  );
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 55);
    const slices = <(double, Color)>[
      (.45, Color(0xFF168BF1)),
      (.30, Color(0xFF55B6FA)),
      (.15, Color(0xFF8BCBFA)),
      (.10, Color(0xFFCEECFF)),
    ];
    var start = -1.57;
    for (final slice in slices) {
      final sweep = slice.$1 * 6.283;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = slice.$2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 23,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _StatusChart extends StatelessWidget {
  const _StatusChart({required this.orders});
  final List<CommissionResumoModel> orders;
  @override
  Widget build(BuildContext context) {
    const data = <(String, double)>[
      ('Novos', .30),
      ('Em andamento', .55),
      ('Aguardando pagamento', .20),
      ('Concluídos', .95),
    ];
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pedidos por status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16354C),
            ),
          ),
          const SizedBox(height: 13),
          ...data.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF16354C),
                    ),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: item.$2,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: const Color(0x66FFFFFF),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF168BF1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Escolher período'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    required this.name,
    required this.description,
    required this.types,
    required this.selectedTypeId,
    required this.onTypeChanged,
    required this.imageBytes,
    required this.onPickImage,
    required this.onSave,
  });
  final TextEditingController name;
  final TextEditingController description;
  final List<TipoProdutoModel> types;
  final String? selectedTypeId;
  final ValueChanged<String?> onTypeChanged;
  final Uint8List? imageBytes;
  final Future<void> Function() onPickImage;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => GlassPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adicionar produto',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16354C),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'Nome do produto',
          style: TextStyle(fontSize: 11, color: Color(0xFF16354C)),
        ),
        const SizedBox(height: 4),
        TextField(controller: name, decoration: _input('Ex.: Modelo 3D Vroid')),
        const SizedBox(height: 10),
        const Text(
          'Tipo do produto',
          style: TextStyle(fontSize: 11, color: Color(0xFF16354C)),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selectedTypeId,
          items: [
            for (final type in types.where((type) => type.habilitado))
              DropdownMenuItem(value: type.id, child: Text(type.nome)),
          ],
          onChanged: onTypeChanged,
          decoration: _input('Escolha um tipo'),
        ),
        const SizedBox(height: 10),
        const Text(
          'Descrição',
          style: TextStyle(fontSize: 11, color: Color(0xFF16354C)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: description,
          maxLines: 3,
          decoration: _input('Descrição opcional para o portfólio'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Imagem do produto',
          style: TextStyle(fontSize: 11, color: Color(0xFF16354C)),
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPickImage,
          child: Container(
            height: 105,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF168BF1),
                style: BorderStyle.solid,
              ),
            ),
            child: imageBytes == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF168BF1),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Selecionar imagem',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF075A9F),
                        ),
                      ),
                      Text(
                        'PNG, JPG ou WebP · até 5 MB',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF456078),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(imageBytes!, fit: BoxFit.cover),
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: ColoredBox(
                            color: Color(0x99063C68),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Toque para trocar a imagem',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF168BF1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar produto'),
          ),
        ),
      ],
    ),
  );
}

InputDecoration _input(String hint) => InputDecoration(
  hintText: hint,
  isDense: true,
  filled: true,
  fillColor: Colors.white,
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(9)),
    borderSide: BorderSide.none,
  ),
);

class _ProductCatalog extends StatelessWidget {
  const _ProductCatalog({
    required this.products,
    required this.types,
    required this.imagePreviews,
  });
  final List<ProdutoModel> products;
  final List<TipoProdutoModel> types;
  final Map<String, Uint8List> imagePreviews;
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meus produtos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16354C),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 210,
              mainAxisExtent: 180,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, index) {
              final product = products[index];
              final type = types.firstWhere(
                (type) => type.id == product.tipoProdutoId,
                orElse: () => const TipoProdutoModel(
                  id: '',
                  nome: 'Tipo indisponível',
                  precoBase: 0,
                  habilitado: false,
                ),
              );
              final image = imagePreviews[product.id];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .82),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: SizedBox(
                        height: 72,
                        width: double.infinity,
                        child: image == null
                            ? DecoratedBox(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFBEE6FF),
                                      Color(0xFF5DBAFF),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xFF16354C),
                                  ),
                                ),
                              )
                            : Image.memory(image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16354C),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF075A9F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 28,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Editar',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
