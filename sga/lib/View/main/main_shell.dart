import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import '../commissions/commissions_page.dart';

/// Área autenticada do SGA: navegação lateral responsiva e a página
/// escolhida. Hoje só existe Commissions; novas páginas entram como novos
/// destinos em [_destinos] e um novo caso em [_pagina].
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.commissionRepository,
    required this.onLogout,
  });

  final CommissionRepository commissionRepository;
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const String _commissions = 'commissions';

  static const List<NavDestination> _destinos = [
    NavDestination(
      id: _commissions,
      label: 'Commissions',
      icon: Icons.view_kanban_outlined,
    ),
  ];

  String _selecionado = _commissions;

  Widget _pagina() {
    switch (_selecionado) {
      case _commissions:
      default:
        return CommissionsPage(repository: widget.commissionRepository);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destino = _destinos.firstWhere((d) => d.id == _selecionado);

    return AdaptiveDrawerScaffold(
      destinations: _destinos,
      selectedId: _selecionado,
      onSelect: (id) => setState(() => _selecionado = id),
      title: destino.label,
      body: _pagina(),
      onLogout: widget.onLogout,
    );
  }
}
