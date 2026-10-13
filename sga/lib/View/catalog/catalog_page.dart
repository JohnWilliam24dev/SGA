import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/models/adicional_model.dart';
import '../../Domain/models/tipo_produto_model.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final List<TipoProdutoModel> _types = [
    const TipoProdutoModel(
      id: 'type-ilustracao',
      nome: 'Ilustração',
      precoBase: 120,
      habilitado: true,
    ),
    const TipoProdutoModel(
      id: 'type-emote',
      nome: 'Emote',
      precoBase: 35,
      habilitado: true,
    ),
    const TipoProdutoModel(
      id: 'type-modelo',
      nome: 'Modelo 3D',
      precoBase: 450,
      habilitado: false,
    ),
  ];

  final List<AdicionalModel> _additionals = [
    const AdicionalModel(
      id: 'add-fundo',
      nome: 'Fundo detalhado',
      descricao: 'Cenário e elementos de composição.',
      precoFixo: 40,
      habilitado: true,
    ),
    const AdicionalModel(
      id: 'add-express',
      nome: 'Entrega expressa',
      descricao: 'Prioriza o pedido na fila de produção.',
      porcentagem: 20,
      habilitado: true,
    ),
    const AdicionalModel(
      id: 'add-rig',
      nome: 'Rig básico',
      precoFixo: 95,
      habilitado: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Tabs(
      items: [
        TabItem(
          label: 'Tipos de Trabalho',
          child: _TypesList(
            items: _types,
            onSave: (m) => setState(() {
              final idx = _types.indexWhere((t) => t.id == m.id);
              if (idx >= 0) _types[idx] = m; else _types.add(m);
            }),
            onDelete: (m) => setState(() => _types.remove(m)),
          ),
        ),
        TabItem(
          label: 'Adicionais',
          child: _AdditionalsList(
            items: _additionals,
            onSave: (m) => setState(() {
              final idx = _additionals.indexWhere((a) => a.id == m.id);
              if (idx >= 0) _additionals[idx] = m; else _additionals.add(m);
            }),
            onDelete: (m) => setState(() => _additionals.remove(m)),
          ),
        ),
      ],
    );
  }
}

class _TypesList extends StatelessWidget {
  const _TypesList({
    required this.items,
    required this.onSave,
    required this.onDelete,
  });

  final List<TipoProdutoModel> items;
  final ValueChanged<TipoProdutoModel> onSave;
  final ValueChanged<TipoProdutoModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return ResourceList<TipoProdutoModel>(
      title: 'Tipos',
      items: items,
      fields: [
        (t) => Label(text: t.nome),
        (t) => Label(text: formatMoney(t.precoBase)),
        (t) => t.habilitado
            ? const Badge(text: 'Ativo', variant: BadgeVariant.soft)
            : const Badge(text: 'Pausado'),
      ],
      editor: (context) => [
        const InputField(name: 'nome', hint: 'Nome do tipo', validation: [isRequired()]),
        const InputField(
          name: 'preco',
          hint: 'Preço base',
          type: InputType.currency,
          validation: [isRequired()],
        ),
        Toggle(
          name: 'habilitado',
          label: 'Habilitado para novos pedidos',
          value: true,
          onChanged: (v) {},
        ),
      ],
      initialValuesFor: (t) => {
        'nome': t?.nome ?? '',
        'preco': t?.precoBase.toString() ?? '0',
        'habilitado': t?.habilitado ?? true,
      },
      onSave: (values, original) {
        onSave(TipoProdutoModel(
          id: original?.id ?? DateTime.now().toString(),
          nome: values['nome'],
          precoBase: parseDecimal(values['preco']),
          habilitado: values['habilitado'],
        ));
      },
      onDelete: onDelete,
    );
  }
}

class _AdditionalsList extends StatelessWidget {
  const _AdditionalsList({
    required this.items,
    required this.onSave,
    required this.onDelete,
  });

  final List<AdicionalModel> items;
  final ValueChanged<AdicionalModel> onSave;
  final ValueChanged<AdicionalModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return ResourceList<AdicionalModel>(
      title: 'Adicionais',
      items: items,
      fields: [
        (a) => Div(
              gap: 2.px,
              children: [
                Label(text: a.nome),
                Label(type: LabelType.caption, text: a.descricao),
              ],
            ),
        (a) => Label(
              text: a.porcentagem != null
                  ? '+${a.porcentagem}%'
                  : formatMoney(a.precoFixo ?? 0),
            ),
      ],
      editor: (context) => [
        const InputField(name: 'nome', hint: 'Nome', validation: [isRequired()]),
        const InputField(name: 'descricao', hint: 'Descrição', validation: [isRequired()]),
        const InputField(
          name: 'preco',
          hint: 'Preço ou Porcentagem',
          type: InputType.currency,
          validation: [isRequired()],
        ),
        Toggle(
          name: 'is_percent',
          label: 'Usar porcentagem em vez de valor fixo',
          value: false,
          onChanged: (v) {},
        ),
        Toggle(
          name: 'habilitado',
          label: 'Habilitado',
          value: true,
          onChanged: (v) {},
        ),
      ],
      initialValuesFor: (a) => {
        'nome': a?.nome ?? '',
        'descricao': a?.descricao ?? '',
        'preco': a?.porcentagem?.toString() ?? a?.precoFixo?.toString() ?? '0',
        'is_percent': a?.porcentagem != null,
        'habilitado': a?.habilitado ?? true,
      },
      onSave: (values, original) {
        final val = parseDecimal(values['preco']);
        final isPercent = values['is_percent'] as bool;
        onSave(AdicionalModel(
          id: original?.id ?? DateTime.now().toString(),
          nome: values['nome'],
          descricao: values['descricao'],
          precoFixo: isPercent ? null : val,
          porcentagem: isPercent ? val.toInt() : null,
          habilitado: values['habilitado'],
        ));
      },
      onDelete: onDelete,
    );
  }
}
