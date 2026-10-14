import 'package:flutter/material.dart' show Icons;

import '../../Shared/shared.dart';

/// Ids das seções da área autenticada.
abstract final class Secao {
  static const orders = 'orders';
  static const reports = 'reports';
  static const products = 'products';
  static const productTypes = 'product-types';
  static const profile = 'profile';
  static const settings = 'settings';
  static const support = 'support';
}

/// Itens do menu lateral (o perfil, as configurações e o suporte moram no
/// menu do usuário, não aqui).
const List<GlassDestination> destinosDoMenu = [
  GlassDestination(Secao.orders, 'Pedidos', Icons.view_kanban_outlined),
  GlassDestination(
    Secao.reports,
    'Relatório de pedidos',
    Icons.pie_chart_outline_rounded,
  ),
  GlassDestination(Secao.products, 'Produtos', Icons.inventory_2_outlined),
  GlassDestination(
    Secao.productTypes,
    'Tipos de produtos',
    Icons.category_outlined,
  ),
];

const _extras = {
  Secao.profile: GlassDestination(Secao.profile, 'Perfil', Icons.person_outline),
  Secao.settings: GlassDestination(
    Secao.settings,
    'Configurações',
    Icons.settings_outlined,
  ),
  Secao.support: GlassDestination(
    Secao.support,
    'Suporte',
    Icons.support_agent_outlined,
  ),
};

/// Destino de qualquer seção, inclusive as que ficam fora do menu.
GlassDestination destinoDe(String id) =>
    _extras[id] ?? destinosDoMenu.firstWhere((d) => d.id == id);

/// Frase que aparece sob o título da seção.
String subtituloDe(String id) => switch (id) {
  Secao.orders => 'Acompanhe cada pedido por etapa, do orçamento até a entrega.',
  Secao.reports => 'Veja como seus pedidos se distribuem por tipo e status.',
  Secao.products =>
    'Cadastre o que você vende e mantenha o catálogo atualizado.',
  Secao.productTypes =>
    'Defina os tipos de produto e os adicionais disponíveis para pedidos.',
  Secao.profile =>
    'Mantenha sua apresentação, regras de trabalho e termos sempre atualizados.',
  Secao.settings => 'Personalize a aparência do seu espaço de trabalho.',
  Secao.support => 'Encontre ajuda sempre que precisar.',
  _ => '',
};
