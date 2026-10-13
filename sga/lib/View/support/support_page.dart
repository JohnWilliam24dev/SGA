import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) => Div(
    align: Alignment.center,
    children: [
      Div(
        maxWidth: 620.px,
        align: Alignment.center,
        children: [
          Card(
            child: Div(
              align: Alignment.center,
              children: [
                const IconBadge(
                  icon: Icons.support_agent_rounded,
                  size: 60,
                ),
                const Label(
                  type: LabelType.title,
                  text: 'Como podemos ajudar?',
                ),
                const Label(
                  type: LabelType.caption,
                  text:
                      'Se você tiver qualquer problema com a plataforma, fale com a gente pelo WhatsApp ou peça ajuda no grupo do Discord. Vamos te orientar por lá.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
