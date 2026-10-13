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
              if (idx >= 0) {
                _types[idx] = m;
              } else {
                _types.add(m);
              }
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
              if (idx >= 0) {
                _additionals[idx] = m;
              } else {
                _additionals.add(m);
              }
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
        Field<TipoProdutoModel>('Nome', (t) => t.nome),
        Field<TipoProdutoModel>('Preço base', (t) => formatMoney(t.precoBase)),
        Field<TipoProdutoModel>(
          'Situação',
          (t) => t.habilitado ? 'Ativo' : 'Pausado',
        ),
      ],
      editor: (item) => [
        InputField(
          name: 'nome',
          hint: 'Nome do tipo',
          validation: [isRequired()],
        ),
        InputField(
          name: 'preco',
          hint: 'Preço base',
          type: InputType.currency,
          validation: [isRequired()],
        ),
        Toggle(
          name: 'habilitado',
          label: 'Habilitado para novos pedidos',
          value: true,
          onChanged: (_) {},
        ),
      ],
      initialValuesFor: (t) => {
        'nome': t.nome,
        'preco': formatMoney(t.precoBase, symbol: ''),
        'habilitado': t.habilitado,
      },
      onSave: (values, original) {
        onSave(
          TipoProdutoModel(
            id: original?.id ?? DateTime.now().toString(),
            nome: values['nome']!.trim(),
            precoBase: parseDecimal(values['preco'] ?? '') ?? 0,
            habilitado: values.boolean('habilitado') ?? true,
          ),
        );
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
        Field<AdicionalModel>('Nome', (a) => a.nome),
        Field<AdicionalModel>(
          'Valor',
          (a) => a.porcentagem != null
              ? '+${formatPercent(a.porcentagem!)}'
              : formatMoney(a.precoFixo ?? 0),
        ),
        Field<AdicionalModel>(
          'Situação',
          (a) => a.habilitado ? 'Ativo' : 'Pausado',
        ),
      ],
      editor: (item) => [
        InputField(name: 'nome', hint: 'Nome', validation: [isRequired()]),
        InputField(name: 'descricao', hint: 'Descrição (opcional)'),
        InputField(
          name: 'preco',
          hint: 'Valor ou porcentagem',
          type: InputType.decimal,
          validation: [isRequired()],
        ),
        Toggle(
          name: 'is_percent',
          label: 'Usar porcentagem em vez de valor fixo',
          value: false,
          onChanged: (_) {},
        ),
        Toggle(
          name: 'habilitado',
          label: 'Habilitado',
          value: true,
          onChanged: (_) {},
        ),
      ],
      initialValuesFor: (a) => {
        'nome': a.nome,
        'descricao': a.descricao ?? '',
        'preco': formatMoney(
          a.porcentagem ?? a.precoFixo ?? 0,
          symbol: '',
        ),
        'is_percent': a.porcentagem != null,
        'habilitado': a.habilitado,
      },
      onSave: (values, original) {
        final valor = parseDecimal(values['preco'] ?? '') ?? 0;
        final isPercent = values.boolean('is_percent') ?? false;
        final descricao = values['descricao']?.trim() ?? '';
        onSave(
          AdicionalModel(
            id: original?.id ?? DateTime.now().toString(),
            nome: values['nome']!.trim(),
            descricao: descricao.isEmpty ? null : descricao,
            precoFixo: isPercent ? null : valor,
            porcentagem: isPercent ? valor : null,
            habilitado: values.boolean('habilitado') ?? true,
          ),
        );
      },
      onDelete: onDelete,
    );
  }
}
