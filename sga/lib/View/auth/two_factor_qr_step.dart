import 'dart:async';

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart' hide Icon;
import 'package:qr_flutter/qr_flutter.dart';

import '../../Domain/domain.dart';

/// Passo 1 da ativação: escanear o QR (ou digitar a chave) e confirmar com
/// o código de 6 dígitos que o aplicativo mostra.
class TwoFactorQrStep extends StatelessWidget {
  const TwoFactorQrStep({super.key, required this.inicio, required this.onConfirmar});

  final DoisFatorInicio inicio;

  /// Pode lançar `UserFacingException`: o botão mostra a mensagem.
  final FutureOr<void> Function(String codigo) onConfirmar;

  /// Chave em grupos de 4 letras, mais fácil de ler e digitar.
  static String agrupar(String segredo) => RegExp('.{1,4}')
      .allMatches(segredo)
      .map((m) => m[0])
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Div(
      width: 100.pct,
      children: [
        const Label(type: LabelType.title, text: 'Ative a verificação em duas etapas'),
        const Label(
          type: LabelType.caption,
          text: 'Escaneie o QR code com um aplicativo autenticador (Google '
              'Authenticator, Authy, 1Password...) e digite o código que ele mostrar.',
        ),
        Center(
          child: DecoratedBox(
            // QR sempre preto no branco, nos dois temas: senão não escaneia.
            decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QrImageView(data: inicio.uri, size: 176),
            ),
          ),
        ),
        const Label(type: LabelType.caption, text: 'Sem câmera? Digite esta chave no aplicativo:'),
        Div(
          direction: LayoutDirection.horizontal,
          align: Alignment.centerLeft,
          gap: 8.px,
          children: [
            LayoutItem(size: 1.fr, child: Label(text: agrupar(inicio.segredo))),
            Button(
              text: 'Copiar',
              variant: ButtonVariant.outline,
              onPressed: () => _copiar(context),
            ),
          ],
        ),
        FormGroup(
          width: 100.pct,
          children: [
            InputField(
              name: 'codigo',
              hint: 'Código de 6 dígitos',
              validation: [
                isRequired(),
                matches(RegExp(r'^\s*\d{6}\s*$'), message: 'Digite os 6 dígitos'),
              ],
            ),
            Button(
              text: 'Ativar',
              expanded: true,
              onSubmit: (values) => onConfirmar(values['codigo']!.trim()),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inicio.segredo));
    if (context.mounted) {
      Toast.show(context, text: 'Chave copiada.', type: ToastType.success);
    }
  }
}
