import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

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
  String _termosServico = '';

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
    _termosServico = _maker.termosServico;
  }

  @override
  void didUpdateWidget(covariant MakerProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maker != widget.maker) {
      _maker = widget.maker;
      _termosServico = _maker.termosServico;
    }
  }

  void _saveMaker(Maker maker) {
    setState(() => _maker = maker);
    widget.onMakerChanged(maker);
    Toast.show(text: 'Perfil atualizado.');
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
    await Modal.form(
      title: 'Editar perfil',
      initialValues: {
        'nome': _maker.nome,
        'email': _maker.email,
        'artista': _maker.nomeArtistico,
        'portfolio': _maker.portfolio,
      },
      fields: (context) => [
        const InputField(name: 'nome', hint: 'Nome completo', validation: [isRequired()]),
        const InputField(name: 'email', hint: 'E-mail', type: InputType.email, validation: [isRequired(), isEmail()]),
        const InputField(name: 'artista', hint: 'Nome artístico'),
        const InputField(name: 'portfolio', hint: 'Portfólio / site'),
      ],
      onSubmit: (values) {
        _saveMaker(
          _maker.copyWith(
            nome: values['nome']!.trim(),
            email: values['email']!.trim(),
            nomeArtistico: values['artista']?.trim() ?? '',
            portfolio: values['portfolio']?.trim() ?? '',
          ),
        );
      },
    );
  }

  Future<void> _addItem(List<String> list, VoidCallback onChanged) async {
    final text = await Modal.prompt(
      'Adicionar regra',
      hint: 'Ex: Retratos a óleo',
      validation: [isRequired(), minLength(3)],
    );
    if (text != null) {
      setState(() {
        list.add(text.trim());
        onChanged();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Div(
      fill: true,
      scrollable: true,
      children: [
        Div(
          maxWidth: 820.px,
          children: [
            Card(
              child: Div(
                direction: LayoutDirection.horizontal,
                align: Alignment.centerLeft,
                children: [
                  Avatar(initials: _maker.inicial, diameter: 64),
                  LayoutItem(
                    size: 1.fr,
                    child: Div(
                      gap: 4.px,
                      children: [
                        Label(type: LabelType.title, text: _maker.nomeExibicao),
                        Label(type: LabelType.caption, text: _maker.email),
                        if (_maker.portfolio.isNotEmpty)
                          Label(type: LabelType.caption, text: _maker.portfolio),
                      ],
                    ),
                  ),
                  Button(
                    text: 'Editar perfil',
                    icon: Icons.edit_rounded,
                    onPressed: _editProfile,
                  ),
                ],
              ),
            ),
            Section(
              title: 'O que eu faço',
              child: Div(
                children: [
                  Div(
                    direction: LayoutDirection.horizontal,
                    children: [
                      const LayoutItem(
                        size: 1.fr,
                        child: Label(
                          type: LabelType.caption,
                          text: 'Especialidades e tipos de projeto aceitos.',
                        ),
                      ),
                      Button(
                        text: 'Adicionar',
                        icon: Icons.add_rounded,
                        onPressed: () => _addItem(_faco, _persistRules),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Div(
                    direction: LayoutDirection.horizontal,
                    gap: 8.px,
                    children: _faco
                        .map(
                          (item) => Badge(
                            text: item,
                            variant: BadgeVariant.soft,
                            onRemove: () {
                              setState(() {
                                _faco.remove(item);
                                _persistRules();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Section(
              title: 'O que eu NÃO faço',
              child: Div(
                children: [
                  Div(
                    direction: LayoutDirection.horizontal,
                    children: [
                      const LayoutItem(
                        size: 1.fr,
                        child: Label(
                          type: LabelType.caption,
                          text: 'Limites e proibições no seu atendimento.',
                        ),
                      ),
                      Button(
                        text: 'Adicionar',
                        icon: Icons.add_rounded,
                        onPressed: () => _addItem(_naoFaco, _persistRules),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Div(
                    direction: LayoutDirection.horizontal,
                    gap: 8.px,
                    children: _naoFaco
                        .map(
                          (item) => Badge(
                            text: item,
                            variant: BadgeVariant.soft,
                            onRemove: () {
                              setState(() {
                                _naoFaco.remove(item);
                                _persistRules();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Section(
              title: 'Termos e Condições para Clientes',
              child: Div(
                children: [
                  const Label(
                    type: LabelType.caption,
                    text: 'Estas regras aparecem ao cliente antes de confirmar o pedido.',
                  ),
                  const SizedBox(height: 12),
                  FormGroup(
                    width: 100.pct,
                    children: [
                      InputField(
                        name: 'termos',
                        hint: 'Escreva aqui seus termos...',
                        initialValue: _termosServico,
                        minLines: 9,
                        maxLines: 14,
                        onChanged: (val) {
                          _termosServico = val;
                          _saveTerms(val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
