import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Interruptor "Li e aceito os Termos de Uso", com o erro embaixo quando o
/// envio foi tentado sem aceitar ([pending]).
class TermsToggle extends StatelessWidget {
  const TermsToggle({
    super.key,
    required this.accepted,
    required this.pending,
    required this.onChanged,
  });

  final bool accepted;
  final bool pending;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Div(
      gap: 0.px,
      children: [
        Div(
          direction: LayoutDirection.horizontal,
          align: Alignment.centerLeft,
          gap: 4.px,
          children: [
            Toggle(value: accepted, onChanged: onChanged),
            LayoutItem(
              size: 1.fr,
              child: const Label(
                type: LabelType.caption,
                text: 'Li e aceito os Termos de Uso',
              ),
            ),
          ],
        ),
        if (pending)
          const Label(
            type: LabelType.error,
            text: 'Você precisa aceitar os termos de uso.',
          ),
      ],
    );
  }
}
