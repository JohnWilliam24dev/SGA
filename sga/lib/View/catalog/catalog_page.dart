import 'package:flutter/material.dart';
import 'package:easy_ui/easy_ui.dart' show Breakpoints, ScreenSize;

import '../../Domain/models/adicional_model.dart';
import '../../Domain/models/tipo_produto_model.dart';
import '../../Core/theme/sga_theme.dart';
import '../../Shared/formatters.dart';
import '../../Shared/widgets/glass_app_shell.dart';

/// Catálogo independente do portfólio. Por enquanto os registros vivem em
/// memória para que todos os fluxos possam ser exercitados antes da API.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final List<_CatalogType> _types = [
    _CatalogType(
      model: const TipoProdutoModel(
        id: 'type-ilustracao',
        nome: 'Ilustração',
        precoBase: 120,
        habilitado: true,
      ),
      additionalIds: {'add-fundo', 'add-express'},
    ),
    _CatalogType(
      model: const TipoProdutoModel(
        id: 'type-emote',
        nome: 'Emote',
        precoBase: 35,
        habilitado: true,
      ),
      additionalIds: {'add-fundo'},
    ),
    _CatalogType(
      model: const TipoProdutoModel(
        id: 'type-modelo',
        nome: 'Modelo 3D',
        precoBase: 450,
        habilitado: false,
      ),
      additionalIds: {'add-fundo', 'add-rig'},
      protected: true,
    ),
  ];
  final List<_CatalogAdditional> _additionals = [
    _CatalogAdditional(
      model: const AdicionalModel(
        id: 'add-fundo',
        nome: 'Fundo detalhado',
        descricao: 'Cenário e elementos de composição.',
        precoFixo: 40,
        habilitado: true,
      ),
    ),
    _CatalogAdditional(
      model: const AdicionalModel(
        id: 'add-express',
        nome: 'Entrega expressa',
        descricao: 'Prioriza o pedido na fila de produção.',
        porcentagem: 20,
        habilitado: true,
      ),
    ),
    _CatalogAdditional(
      model: const AdicionalModel(
        id: 'add-rig',
        nome: 'Rig básico',
        precoFixo: 95,
        habilitado: false,
      ),
      protected: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _notice(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFF9B2C2C) : null,
          content: Text(message),
        ),
      );
  }

  Future<void> _editType([_CatalogType? entry]) async {
    final result = await showModalBottomSheet<_TypeDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TypeEditor(
        initial: entry,
        additionals: _additionals.map((e) => e.model).toList(),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      final model = TipoProdutoModel(
        id: entry?.model.id ?? 'type-${DateTime.now().microsecondsSinceEpoch}',
        nome: result.name,
        precoBase: result.basePrice,
        habilitado: result.enabled,
      );
      if (entry == null) {
        _types.insert(
          0,
          _CatalogType(model: model, additionalIds: result.additionalIds),
        );
      } else {
        final index = _types.indexOf(entry);
        _types[index] = _CatalogType(
          model: model,
          additionalIds: result.additionalIds,
          protected: entry.protected,
        );
      }
    });
    _notice(
      entry == null ? 'Tipo de produto criado.' : 'Tipo de produto atualizado.',
    );
  }

  Future<void> _editAdditional([_CatalogAdditional? entry]) async {
    final result = await showModalBottomSheet<_AdditionalDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AdditionalEditor(initial: entry?.model),
    );
    if (result == null || !mounted) return;
    setState(() {
      final model = AdicionalModel(
        id: entry?.model.id ?? 'add-${DateTime.now().microsecondsSinceEpoch}',
        nome: result.name,
        descricao: result.description.isEmpty ? null : result.description,
        precoFixo: result.rule == _PriceRule.fixed ? result.value : null,
        porcentagem: result.rule == _PriceRule.percent ? result.value : null,
        habilitado: result.enabled,
      );
      if (entry == null) {
        _additionals.insert(0, _CatalogAdditional(model: model));
      } else {
        final index = _additionals.indexOf(entry);
        _additionals[index] = _CatalogAdditional(
          model: model,
          protected: entry.protected,
        );
      }
    });
    _notice(entry == null ? 'Adicional criado.' : 'Adicional atualizado.');
  }

  Future<void> _removeType(_CatalogType entry) async {
    final confirmed = await _confirm(
      'Excluir tipo de produto',
      'Esta ação não pode ser desfeita.',
    );
    if (confirmed != true || !mounted) return;
    if (entry.protected) {
      _notice(
        'Este tipo já foi usado em pedidos ou no portfólio. Desabilite-o para mantê-lo fora de novos pedidos.',
        error: true,
      );
      return;
    }
    setState(() => _types.remove(entry));
    _notice('Tipo de produto excluído.');
  }

  Future<void> _removeAdditional(_CatalogAdditional entry) async {
    final confirmed = await _confirm(
      'Excluir adicional',
      'Esta ação não pode ser desfeita.',
    );
    if (confirmed != true || !mounted) return;
    if (entry.protected) {
      _notice(
        'Este adicional já foi usado em um pedido. Desabilite-o para não exibi-lo em novos formulários.',
        error: true,
      );
      return;
    }
    setState(() {
      _additionals.remove(entry);
      for (final type in _types) {
        type.additionalIds.remove(entry.model.id);
      }
    });
    _notice('Adicional excluído.');
  }

  Future<bool?> _confirm(String title, String content) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            labelColor: colors.text,
            unselectedLabelColor: colors.muted,
            indicatorColor: colors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Tipos de produtos'),
              Tab(text: 'Adicionais'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _CatalogList<_CatalogType>(
                title: 'Tipos de produtos',
                description: 'Defina o preço base e os adicionais que cada tipo pode oferecer.',
                addLabel: 'Novo tipo',
                items: _types,
                emptyTitle: 'Nenhum tipo de produto cadastrado',
                emptyDescription:
                    'Comece criando o primeiro tipo que você oferece.',
                onAdd: () => _editType(),
                onEdit: _editType,
                onRemove: _removeType,
                rowBuilder: (item) => _TypeRow(
                  item: item,
                  onEnabled: (value) => setState(
                    () => item.model = _typeWithEnabled(item.model, value),
                  ),
                ),
              ),
              _CatalogList<_CatalogAdditional>(
                title: 'Adicionais',
                description: 'Crie extras cobrados por valor fixo ou porcentagem do preço base.',
                addLabel: 'Novo adicional',
                items: _additionals,
                emptyTitle: 'Nenhum adicional cadastrado',
                emptyDescription:
                    'Cadastre extras para vinculá-los aos tipos de produto.',
                onAdd: () => _editAdditional(),
                onEdit: _editAdditional,
                onRemove: _removeAdditional,
                rowBuilder: (item) => _AdditionalRow(
                  item: item,
                  onEnabled: (value) => setState(
                    () =>
                        item.model = _additionalWithEnabled(item.model, value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

TipoProdutoModel _typeWithEnabled(TipoProdutoModel model, bool value) =>
    TipoProdutoModel(
      id: model.id,
      nome: model.nome,
      precoBase: model.precoBase,
      habilitado: value,
    );
AdicionalModel _additionalWithEnabled(AdicionalModel model, bool value) =>
    AdicionalModel(
      id: model.id,
      nome: model.nome,
      descricao: model.descricao,
      precoFixo: model.precoFixo,
      porcentagem: model.porcentagem,
      habilitado: value,
    );

class _CatalogType {
  _CatalogType({
    required this.model,
    required this.additionalIds,
    this.protected = false,
  });
  TipoProdutoModel model;
  final Set<String> additionalIds;
  final bool protected;
}

class _CatalogAdditional {
  _CatalogAdditional({required this.model, this.protected = false});
  AdicionalModel model;
  final bool protected;
}

class _CatalogList<T> extends StatelessWidget {
  const _CatalogList({
    required this.title,
    required this.description,
    required this.addLabel,
    required this.items,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.rowBuilder,
  });
  final String title, description, addLabel, emptyTitle, emptyDescription;
  final List<T> items;
  final VoidCallback onAdd;
  final void Function(T) onEdit, onRemove;
  final Widget Function(T) rowBuilder;
  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile =
                    Breakpoints.standard.sizeFor(constraints.maxWidth) ==
                    ScreenSize.mobile;
                final action = FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(addLabel),
                );
                final info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.heading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: colors.muted),
                    ),
                  ],
                );
                return mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [info, const SizedBox(height: 14), action],
                      )
                    : Row(
                        children: [
                          Expanded(child: info),
                          action,
                        ],
                      );
              },
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              _EmptyCatalog(
                title: emptyTitle,
                description: emptyDescription,
                onCreate: onAdd,
              )
            else
              ...items.map(
                (item) => _CatalogItem(
                  content: rowBuilder(item),
                  onEdit: () => onEdit(item),
                  onRemove: () => onRemove(item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CatalogItem extends StatelessWidget {
  const _CatalogItem({
    required this.content,
    required this.onEdit,
    required this.onRemove,
  });
  final Widget content;
  final VoidCallback onEdit, onRemove;
  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.input,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile =
              Breakpoints.standard.sizeFor(constraints.maxWidth) ==
              ScreenSize.mobile;
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: onRemove,
                color: colors.error,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          );
          return mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: content),
                    actions,
                  ],
                );
        },
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({required this.item, required this.onEnabled});
  final _CatalogType item;
  final ValueChanged<bool> onEnabled;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 28,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      _RowField('Nome', item.model.nome),
      _RowField('Preço base', formatarMoeda(item.model.precoBase)),
      _RowField(
        'Adicionais',
        '${item.additionalIds.length} vinculado${item.additionalIds.length == 1 ? '' : 's'}',
      ),
      _StatusSwitch(value: item.model.habilitado, onChanged: onEnabled),
    ],
  );
}

class _AdditionalRow extends StatelessWidget {
  const _AdditionalRow({required this.item, required this.onEnabled});
  final _CatalogAdditional item;
  final ValueChanged<bool> onEnabled;
  @override
  Widget build(BuildContext context) {
    final model = item.model;
    final rule = model.precoFixo != null
        ? formatarMoeda(model.precoFixo!)
        : '${model.porcentagem!.toStringAsFixed(model.porcentagem! % 1 == 0 ? 0 : 2)}% do preço base';
    return Wrap(
      spacing: 28,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _RowField('Nome', model.nome),
        _RowField('Descrição', model.descricao ?? '—'),
        _RowField('Preço/regra', rule),
        _StatusSwitch(value: model.habilitado, onChanged: onEnabled),
      ],
    );
  }
}

class _RowField extends StatelessWidget {
  const _RowField(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.disabled,
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 135,
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  const _StatusSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Switch(value: value, onChanged: onChanged),
      Text(
        value ? 'Habilitado' : 'Desabilitado',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: value
              ? SgaColors.of(context).success
              : SgaColors.of(context).disabled,
        ),
      ),
    ],
  );
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({
    required this.title,
    required this.description,
    required this.onCreate,
  });
  final String title, description;
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 42, color: colors.icon),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w800, color: colors.text),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.muted),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar agora'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeDraft {
  const _TypeDraft({
    required this.name,
    required this.basePrice,
    required this.enabled,
    required this.additionalIds,
  });
  final String name;
  final double basePrice;
  final bool enabled;
  final Set<String> additionalIds;
}

class _TypeEditor extends StatefulWidget {
  const _TypeEditor({required this.initial, required this.additionals});
  final _CatalogType? initial;
  final List<AdicionalModel> additionals;
  @override
  State<_TypeEditor> createState() => _TypeEditorState();
}

class _TypeEditorState extends State<_TypeEditor> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late bool _enabled;
  late Set<String> _selected;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.model.nome ?? '');
    _price = TextEditingController(
      text: widget.initial?.model.precoBase.toStringAsFixed(2) ?? '',
    );
    _enabled = widget.initial?.model.habilitado ?? true;
    _selected = {...?widget.initial?.additionalIds};
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EditorSheet(
    title: widget.initial == null
        ? 'Novo tipo de produto'
        : 'Editar tipo de produto',
    onSave: () {
      final value = double.tryParse(_price.text.replaceAll(',', '.'));
      if (_name.text.trim().isEmpty || value == null || value < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe um nome e um preço base válido.'),
          ),
        );
        return;
      }
      Navigator.pop(
        context,
        _TypeDraft(
          name: _name.text.trim(),
          basePrice: value,
          enabled: _enabled,
          additionalIds: _selected,
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Preço base (R\$)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        _EnabledField(
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
        const Divider(height: 28),
        const Text(
          'Adicionais vinculados',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16354C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Marque os adicionais que poderão ser escolhidos neste tipo.',
          style: TextStyle(fontSize: 12, color: Color(0xFF456078)),
        ),
        const SizedBox(height: 8),
        if (widget.additionals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Nenhum adicional cadastrado ainda.'),
          )
        else
          ...widget.additionals.map(
            (add) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _selected.contains(add.id),
              onChanged: (value) => setState(() {
                if (value ?? false) {
                  _selected.add(add.id);
                } else {
                  _selected.remove(add.id);
                }
              }),
              title: Text(add.nome),
              subtitle: Text(add.habilitado ? 'Habilitado' : 'Desabilitado'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
      ],
    ),
  );
}

enum _PriceRule { fixed, percent }

class _AdditionalDraft {
  const _AdditionalDraft({
    required this.name,
    required this.description,
    required this.rule,
    required this.value,
    required this.enabled,
  });
  final String name, description;
  final _PriceRule rule;
  final double value;
  final bool enabled;
}

class _AdditionalEditor extends StatefulWidget {
  const _AdditionalEditor({required this.initial});
  final AdicionalModel? initial;
  @override
  State<_AdditionalEditor> createState() => _AdditionalEditorState();
}

class _AdditionalEditorState extends State<_AdditionalEditor> {
  late final TextEditingController _name, _description, _value;
  late bool _enabled;
  late _PriceRule _rule;
  @override
  void initState() {
    super.initState();
    final value = widget.initial;
    _name = TextEditingController(text: value?.nome ?? '');
    _description = TextEditingController(text: value?.descricao ?? '');
    _rule = value?.porcentagem != null ? _PriceRule.percent : _PriceRule.fixed;
    _value = TextEditingController(
      text: (value?.porcentagem ?? value?.precoFixo)?.toStringAsFixed(2) ?? '',
    );
    _enabled = value?.habilitado ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _EditorSheet(
    title: widget.initial == null ? 'Novo adicional' : 'Editar adicional',
    onSave: () {
      final value = double.tryParse(_value.text.replaceAll(',', '.'));
      if (_name.text.trim().isEmpty || value == null || value < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe nome e valor válido.')),
        );
        return;
      }
      Navigator.pop(
        context,
        _AdditionalDraft(
          name: _name.text.trim(),
          description: _description.text.trim(),
          rule: _rule,
          value: value,
          enabled: _enabled,
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _description,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Descrição (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Regra de preço',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF16354C),
          ),
        ),
        const SizedBox(height: 4),
        RadioGroup<_PriceRule>(
          groupValue: _rule,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _rule = value;
              _value.clear();
            });
          },
          child: const Column(
            children: [
              RadioListTile<_PriceRule>(
                contentPadding: EdgeInsets.zero,
                value: _PriceRule.fixed,
                title: Text('Preço fixo'),
                subtitle: Text('Ex.: R\$ 15,00'),
              ),
              RadioListTile<_PriceRule>(
                contentPadding: EdgeInsets.zero,
                value: _PriceRule.percent,
                title: Text('Porcentagem'),
                subtitle: Text('Aplicada sobre o preço base do produto.'),
              ),
            ],
          ),
        ),
        TextField(
          controller: _value,
          key: ValueKey(_rule),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _rule == _PriceRule.fixed
                ? 'Valor fixo (R\$)'
                : 'Porcentagem (%)',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        _EnabledField(
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
      ],
    ),
  );
}

class _EnabledField extends StatelessWidget {
  const _EnabledField({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    value: value,
    onChanged: onChanged,
    title: const Text('Habilitado'),
    subtitle: Text(
      value ? 'Disponível em novos pedidos.' : 'Oculto dos novos pedidos.',
    ),
  );
}

class _EditorSheet extends StatelessWidget {
  const _EditorSheet({
    required this.title,
    required this.child,
    required this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16354C),
                ),
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: onSave, child: const Text('Salvar')),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
