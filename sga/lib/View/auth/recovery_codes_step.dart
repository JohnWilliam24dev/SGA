import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart' hide Icon;

/// Passo 2 da ativação: os códigos de recuperação, que só aparecem agora.
/// O usuário precisa marcar que os guardou antes de continuar.
class RecoveryCodesStep extends StatefulWidget {
  const RecoveryCodesStep({super.key, required this.codigos, required this.onConcluir});

  final List<String> codigos;

  /// Pode lançar `UserFacingException`: a mensagem vai para um toast.
  final Future<void> Function() onConcluir;

  @override
  State<RecoveryCodesStep> createState() => _RecoveryCodesStepState();
}

class _RecoveryCodesStepState extends State<RecoveryCodesStep> {
  bool _guardou = false;
  bool _pendente = false;
  bool _enviando = false;

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: widget.codigos.join('\n')));
    if (mounted) {
      Toast.show(context, text: 'Códigos copiados.', type: ToastType.success);
    }
  }

  Future<void> _continuar() async {
    if (!_guardou) {
      setState(() => _pendente = true);
      return;
    }
    setState(() => _enviando = true);
    try {
      await widget.onConcluir();
    } on UserFacingException catch (e) {
      if (mounted) Toast.error(context, text: e.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Div(
      width: 100.pct,
      children: [
        const Label(type: LabelType.title, text: 'Guarde seus códigos de recuperação'),
        const Label(
          type: LabelType.caption,
          text: 'Cada código vale uma única vez e só aparece agora. Se você perder '
              'o celular, eles são a única forma de entrar. Salve-os antes de continuar '
              'e não recarregue esta página.',
        ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final codigo in widget.codigos)
              SizedBox(width: 130, child: Label(text: codigo)),
          ],
        ),
        Button(text: 'Copiar códigos', variant: ButtonVariant.outline, onPressed: _copiar),
        Div(
          direction: LayoutDirection.horizontal,
          align: Alignment.centerLeft,
          gap: 4.px,
          children: [
            Toggle(
              value: _guardou,
              onChanged: (v) => setState(() {
                _guardou = v;
                if (v) _pendente = false;
              }),
            ),
            LayoutItem(
              size: 1.fr,
              child: const Label(
                type: LabelType.caption,
                text: 'Guardei meus códigos em um lugar seguro',
              ),
            ),
          ],
        ),
        if (_pendente)
          const Label(type: LabelType.error, text: 'Confirme que guardou os códigos.'),
        Button(text: 'Continuar', expanded: true, loading: _enviando, onPressed: _continuar),
      ],
    );
  }
}
