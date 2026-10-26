import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import 'scope_editor.dart';

/// Pergunta os dados do perfil. Devolve o [Maker] atualizado, ou `null` se
/// cancelou.
Future<Maker?> editarPerfil(BuildContext context, Maker maker) {
  return Modal.form<Maker>(
    context,
    title: 'Editar perfil',
    saveText: 'Salvar alterações',
    initialValues: {
      'nome': maker.nome,
      'email': maker.email,
      'artista': maker.nomeArtistico,
      'portfolio': maker.portfolio,
    },
    fields: (_) => [
      InputField(
        name: 'nome',
        label: 'Nome completo',
        validation: [isRequired(), maxLength(80)],
      ),
      InputField(
        name: 'email',
        label: 'E-mail',
        type: InputType.email,
        validation: [isRequired(), isEmail()],
      ),
      const InputField(name: 'artista', label: 'Nome artístico'),
      const InputField(name: 'portfolio', label: 'Portfólio / site'),
    ],
    onSubmit: (values) => maker.copyWith(
      nome: values['nome']!.trim(),
      email: values['email']!.trim(),
      nomeArtistico: values['artista']?.trim() ?? '',
      portfolio: values['portfolio']?.trim() ?? '',
    ),
  );
}

/// Abre o editor de uma lista de itens; cada mudança sai por [onChanged].
Future<void> editarLista(
  BuildContext context, {
  required String title,
  required List<String> items,
  required ValueChanged<List<String>> onChanged,
}) {
  return Modal.custom<void>(
    context,
    builder: (dialogContext) => ScopeEditor(
      title: title,
      initial: items,
      onChanged: onChanged,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
  );
}
