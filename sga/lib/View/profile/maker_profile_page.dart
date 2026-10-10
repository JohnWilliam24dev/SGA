import 'package:flutter/material.dart';

import '../../Domain/maker.dart';
import '../../Core/theme/sga_theme.dart';
import '../../Shared/widgets/glass_app_shell.dart';

class MakerProfilePage extends StatefulWidget {
  const MakerProfilePage({
    super.key,
    required this.maker,
    required this.onMakerChanged,
  });

  final Maker maker;
  final ValueChanged<Maker> onMakerChanged;

  @override
  State<MakerProfilePage> createState() => _MakerProfilePageState();
}

class _MakerProfilePageState extends State<MakerProfilePage> {
  late Maker _maker;
  late List<String> _faco;
  late List<String> _naoFaco;
  late TextEditingController _termosController;

  static const _defaultFaco = [
    'Ilustração digital',
    'Capas de álbum',
    'Personagens originais',
  ];
  static const _defaultNaoFaco = [
    'Imitação de estilo de outro artista',
    'Conteúdo ofensivo ou discriminatório',
  ];

  @override
  void initState() {
    super.initState();
    _maker = widget.maker;
    _faco = List.of(_maker.faz.isEmpty ? _defaultFaco : _maker.faz);
    _naoFaco = List.of(_maker.naoFaz.isEmpty ? _defaultNaoFaco : _maker.naoFaz);
    _termosController = TextEditingController(text: _maker.termosServico);
  }

  @override
  void didUpdateWidget(covariant MakerProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maker != widget.maker) _maker = widget.maker;
  }

  @override
  void dispose() {
    _termosController.dispose();
    super.dispose();
  }

  void _saveMaker(Maker maker) {
    setState(() => _maker = maker);
    widget.onMakerChanged(maker);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
  }

  void _persistRules() {
    _maker = _maker.copyWith(faz: List.of(_faco), naoFaz: List.of(_naoFaco));
    widget.onMakerChanged(_maker);
  }

  void _saveTerms(String value) {
    _maker = _maker.copyWith(termosServico: value);
    widget.onMakerChanged(_maker);
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _maker.nome);
    final email = TextEditingController(text: _maker.email);
    final artist = TextEditingController(text: _maker.nomeArtistico);
    final portfolio = TextEditingController(text: _maker.portfolio);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(name, 'Nome completo'),
              _field(email, 'E-mail'),
              _field(artist, 'Nome artístico'),
              _field(portfolio, 'Portfólio / site'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              _saveMaker(
                _maker.copyWith(
                  nome: name.text.trim(),
                  email: email.text.trim(),
                  nomeArtistico: artist.text.trim(),
                  portfolio: portfolio.text.trim(),
                ),
              );
              Navigator.pop(context, true);
            },
            child: const Text('Salvar alterações'),
          ),
        ],
      ),
    );
    name.dispose();
    email.dispose();
    artist.dispose();
    portfolio.dispose();
    if (saved == true && mounted) setState(() {});
  }

  Widget _field(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Future<void> _editScope({required bool does}) async {
    final controller = TextEditingController();
    final list = does ? _faco : _naoFaco;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(does ? 'O que eu faço' : 'O que eu não faço'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...list.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item),
                  trailing: IconButton(
                    tooltip: 'Remover',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      list.remove(item);
                      _persistRules();
                    }),
                  ),
                ),
              ),
              const Divider(),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Novo item',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addScopeItem(controller, list),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => _addScopeItem(controller, list),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _addScopeItem(TextEditingController controller, List<String> list) {
    final value = controller.text.trim();
    if (value.isEmpty || list.contains(value)) return;
    setState(() {
      list.add(value);
      _persistRules();
    });
    controller.clear();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 780;
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassPanel(child: narrow ? _profileColumn() : _profileRow()),
            const SizedBox(height: 16),
            _sectionTitle(context, 'Como você trabalha'),
            const SizedBox(height: 8),
            if (narrow)
              Column(
                children: [
                  _scopePanel(true),
                  const SizedBox(height: 12),
                  _scopePanel(false),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _scopePanel(true)),
                  const SizedBox(width: 14),
                  Expanded(child: _scopePanel(false)),
                ],
              ),
            const SizedBox(height: 18),
            _sectionTitle(context, 'Termos de serviço'),
            const SizedBox(height: 8),
            GlassPanel(
              child: TextField(
                controller: _termosController,
                minLines: 9,
                maxLines: 14,
                onChanged: _saveTerms,
                decoration: const InputDecoration(
                  hintText: 'Escreva aqui os seus termos de serviço...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleLarge
        ?.copyWith(fontWeight: FontWeight.w800, color: sgaHeading),
  );

  Widget _profileRow() => Row(
    children: [
      _largeAvatar(context),
      const SizedBox(width: 18),
      Expanded(child: _profileInfo()),
      FilledButton.icon(
        onPressed: _editProfile,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar perfil'),
      ),
    ],
  );

  Widget _profileColumn() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _largeAvatar(context),
          const SizedBox(width: 14),
          Expanded(child: _profileInfo()),
        ],
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _editProfile,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar perfil'),
      ),
    ],
  );

  Widget _largeAvatar(BuildContext context) => CircleAvatar(
    radius: 34,
    backgroundColor: SgaColors.of(context).avatar,
    child: Text(
      _maker.inicial,
      style: TextStyle(
        color: SgaColors.of(context).onPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _profileInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _maker.nomeExibicao,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: sgaHeading,
        ),
      ),
      if (_maker.nomeArtistico.isNotEmpty)
        Text(_maker.nome, style: TextStyle(color: sgaMuted)),
      const SizedBox(height: 8),
      _contact(Icons.email_outlined, _maker.email),
      if (_maker.portfolio.isNotEmpty) ...[
        const SizedBox(height: 5),
        _contact(Icons.language_rounded, _maker.portfolio),
      ],
    ],
  );

  Widget _contact(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: SgaColors.of(context).avatar),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: sgaMuted)),
    ],
  );

  Widget _scopePanel(bool does) {
    final items = does ? _faco : _naoFaco;
    final color = does
        ? SgaColors.of(context).success
        : SgaColors.of(context).negative;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                does ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                color: color,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  does ? 'Eu faço' : 'Eu não faço',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: sgaOnSurface,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar lista',
                onPressed: () => _editScope(does: does),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('Nenhum item informado.', style: TextStyle(color: sgaMuted))
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: items
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      backgroundColor: color.withValues(alpha: .10),
                      side: BorderSide(color: color.withValues(alpha: .25)),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
