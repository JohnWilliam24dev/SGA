import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import 'profile_edit.dart';
import 'profile_header.dart';
import 'profile_terms.dart';
import 'scope_panel.dart';

/// Perfil do Maker: cartão de identidade, o que ele faz e não faz, e os
/// termos de serviço. Tudo é guardado por [onMakerChanged].
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
  static const _fazPadrao = [
    'Ilustração digital',
    'Capas de álbum',
    'Personagens originais',
  ];
  static const _naoFazPadrao = [
    'Imitação de estilo de outro artista',
    'Conteúdo ofensivo ou discriminatório',
  ];

  late Maker _maker = widget.maker;
  late List<String> _faz = List.of(
    _maker.faz.isEmpty ? _fazPadrao : _maker.faz,
  );
  late List<String> _naoFaz = List.of(
    _maker.naoFaz.isEmpty ? _naoFazPadrao : _maker.naoFaz,
  );

  @override
  void didUpdateWidget(covariant MakerProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maker != widget.maker) _maker = widget.maker;
  }

  void _guardar(Maker maker) {
    _maker = maker;
    widget.onMakerChanged(maker);
  }

  Future<void> _editarPerfil() async {
    final novo = await editarPerfil(context, _maker);
    if (novo == null || !mounted) return;
    setState(() => _guardar(novo));
    Toast.show(context, text: 'Perfil atualizado.', type: ToastType.success);
  }

  Future<void> _editarLista({required bool faz}) {
    return editarLista(
      context,
      title: faz ? 'O que eu faço' : 'O que eu não faço',
      items: faz ? _faz : _naoFaz,
      onChanged: (itens) => setState(() {
        if (faz) {
          _faz = itens;
        } else {
          _naoFaz = itens;
        }
        _guardar(_maker.copyWith(faz: _faz, naoFaz: _naoFaz));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 780;
        final faz = ScopePanel(
          does: true,
          items: _faz,
          onEdit: () => _editarLista(faz: true),
        );
        final naoFaz = ScopePanel(
          does: false,
          items: _naoFaz,
          onEdit: () => _editarLista(faz: false),
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                maker: _maker,
                narrow: narrow,
                onEdit: _editarPerfil,
              ),
              const SizedBox(height: 16),
              const ProfileSectionTitle('Como você trabalha'),
              const SizedBox(height: 8),
              if (narrow)
                Column(children: [faz, const SizedBox(height: 12), naoFaz])
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: faz),
                    const SizedBox(width: 14),
                    Expanded(child: naoFaz),
                  ],
                ),
              const SizedBox(height: 18),
              const ProfileSectionTitle('Termos de serviço'),
              const SizedBox(height: 8),
              ProfileTerms(
                initial: _maker.termosServico,
                onChanged: (texto) =>
                    _guardar(_maker.copyWith(termosServico: texto)),
              ),
            ],
          ),
        );
      },
    );
  }
}
