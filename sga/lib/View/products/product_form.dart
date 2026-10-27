import 'dart:async';
import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// Painel "Adicionar produto" (ou "Editar produto", quando recebe [initial]):
/// nome, tipo, descrição, imagem e o botão Salvar. Trocar a `key` deste
/// widget reinicia todos os campos.
class ProductForm extends StatelessWidget {
  const ProductForm({
    super.key,
    required this.types,
    required this.onPickImage,
    required this.onSave,
    this.initial,
    this.onCancel,
  });

  final List<TipoProdutoModel> types;
  final Future<Uint8List?> Function() onPickImage;
  final FutureOr<void> Function(FormValues values) onSave;

  /// Produto em edição (null = adicionando um novo).
  final ProdutoModel? initial;

  /// Sai do modo de edição sem salvar; só aparece ao editar.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final editando = initial != null;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            editando ? 'Editar produto' : 'Adicionar produto',
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
                initialValue: initial?.nome,
                label: 'Nome do produto',
                hint: 'Ex.: Modelo 3D Vroid',
                validation: [isRequired(), maxLength(nomeMaximo)],
              ),
              Select<String>.single(
                name: 'tipo',
                hint: 'Tipo do produto',
                value: initial?.tipoProdutoId,
                // Ao editar, o tipo atual aparece mesmo se foi desabilitado.
                options: [
                  for (final t in types)
                    if (t.habilitado || t.id == initial?.tipoProdutoId)
                      SelectOption(t.id, t.nome),
                ],
                onChanged: (_) {},
                validation: [isRequired()],
              ),
              InputField(
                name: 'descricao',
                initialValue: initial?.descricao,
                label: 'Descrição',
                hint: 'Descrição opcional para o portfólio',
                minLines: 3,
                maxLines: 3,
                validation: [maxLength(1000)],
              ),
              // A API não troca a imagem de um produto já cadastrado: ao
              // editar, o campo some (para trocar, exclua e cadastre de novo).
              if (!editando)
                ImageField(
                  name: 'imagem',
                  label: 'Imagem do produto',
                  hint: 'Selecionar imagem · PNG, JPG ou WebP · até 4 MB',
                  onPick: onPickImage,
                  validation: [isRequired(message: 'Selecione uma imagem')],
                ),
              Button(
                text: editando ? 'Salvar alterações' : 'Salvar Produto',
                expanded: true,
              ),
              if (onCancel != null)
                Button(
                  text: 'Cancelar edição',
                  variant: ButtonVariant.ghost,
                  expanded: true,
                  onPressed: onCancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
