import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// Painel "Adicionar produto": nome, tipo, descrição, imagem e o botão
/// Salvar. Trocar a `key` deste widget limpa todos os campos.
class ProductForm extends StatelessWidget {
  const ProductForm({
    super.key,
    required this.types,
    required this.onPickImage,
    required this.onSave,
  });

  final List<TipoProdutoModel> types;
  final Future<Uint8List?> Function() onPickImage;
  final ValueChanged<FormValues> onSave;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adicionar produto',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: SgaColors.of(context).text,
            ),
          ),
          const SizedBox(height: 13),
          FormGroup(
            onSubmit: onSave,
            children: [
              InputField(
                name: 'nome',
                label: 'Nome do produto',
                hint: 'Ex.: Modelo 3D Vroid',
                validation: [isRequired()],
              ),
              Select<String>.single(
                name: 'tipo',
                hint: 'Tipo do produto',
                options: [
                  for (final t in types.where((t) => t.habilitado))
                    SelectOption(t.id, t.nome),
                ],
                onChanged: (_) {},
                validation: [isRequired()],
              ),
              const InputField(
                name: 'descricao',
                label: 'Descrição',
                hint: 'Descrição opcional para o portfólio',
                minLines: 3,
                maxLines: 3,
              ),
              ImageField(
                name: 'imagem',
                label: 'Imagem do produto',
                hint: 'Selecionar imagem · PNG, JPG ou WebP · até 5 MB',
                onPick: onPickImage,
                validation: [isRequired(message: 'Selecione uma imagem')],
              ),
              const Button(text: 'Salvar Produto', expanded: true),
            ],
          ),
        ],
      ),
    );
  }
}
