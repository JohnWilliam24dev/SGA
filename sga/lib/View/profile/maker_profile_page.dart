import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import 'profile_edit.dart';
import 'profile_header.dart';
import 'profile_persistencia.dart';
import 'profile_terms.dart';
import 'scope_pair.dart';

/// Perfil do Maker: cartão de identidade, o que ele faz e não faz, e os
/// termos de serviço. Tudo é guardado por [onMakerChanged].
class MakerProfilePage extends StatefulWidget {
  const MakerProfilePage({
    super.key,
    required this.maker,
    required this.onMakerChanged,
    this.repository,
    this.makerId,
  });

  final Maker maker;
  final ValueChanged<Maker> onMakerChanged;

  /// Grava o perfil no servidor (com o [makerId] da sessão). Sem ele, as
  /// alterações ficam só na tela.
  final MakerRepository? repository;
  final String? makerId;

  @override
  State<MakerProfilePage> createState() => _MakerProfilePageState();
}

class _MakerProfilePageState extends State<MakerProfilePage>
    with ProfilePersistencia<MakerProfilePage> {
  late Maker _maker = widget.maker;

  @override
  MakerRepository? get repositorio => widget.repository;
  @override
  String? get makerId => widget.makerId;
  @override
  Maker get makerAtual => _maker;
  late List<String> _faz = itensOuPadrao(_maker.faz, faz: true);
  late List<String> _naoFaz = itensOuPadrao(_maker.naoFaz, faz: false);

  @override
  void didUpdateWidget(covariant MakerProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mudou de fora (o perfil chegou do servidor): vale o que veio de lá.
    if (widget.maker == _maker) return;
    _maker = widget.maker;
    marcarSalvo(_maker);
    _faz = itensOuPadrao(_maker.faz, faz: true);
    _naoFaz = itensOuPadrao(_maker.naoFaz, faz: false);
  }

  void _guardar(
    Maker maker, {
    Duration depois = Duration.zero,
    bool silencioso = false,
  }) {
    _maker = maker;
    widget.onMakerChanged(maker);
    persistirMaker(depois: depois, silencioso: silencioso);
  }

  Future<void> _editarPerfil() async {
    final novo = await editarPerfil(context, _maker);
    if (novo == null || !mounted) return;
    setState(() => _guardar(novo));
    if (widget.repository == null) {
      Toast.show(context, text: 'Perfil atualizado.', type: ToastType.success);
    }
  }

  Future<void> _editarLista({required bool faz}) {
    return editarLista(
      context,
      title: faz ? 'O que eu faço' : 'O que eu não faço',
      items: faz ? _faz : _naoFaz,
      onChanged: (itens) {
        final novoFaz = faz ? itens : _faz;
        final novoNaoFaz = faz ? _naoFaz : itens;
        if (codificarEscopo(novoFaz, novoNaoFaz).length > limiteEscopoTexto) {
          Toast.show(
            context,
            text: 'Faço e não faço passam juntos de 2.000 caracteres. Remova '
                'ou encurte itens.',
            type: ToastType.warning,
          );
          return;
        }
        setState(() {
          _faz = novoFaz;
          _naoFaz = novoNaoFaz;
          _guardar(_maker.copyWith(faz: _faz, naoFaz: _naoFaz));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 780;
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
              ScopePair(
                faz: _faz,
                naoFaz: _naoFaz,
                narrow: narrow,
                onEdit: ({required bool faz}) => _editarLista(faz: faz),
              ),
              const SizedBox(height: 18),
              const ProfileSectionTitle('Termos de serviço'),
              const SizedBox(height: 8),
              ProfileTerms(
                initial: _maker.termosServico,
                onChanged: (texto) => _guardar(
                  _maker.copyWith(termosServico: texto),
                  depois: const Duration(seconds: 1),
                  silencioso: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
