import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// ID público do Maker: é o `makerPublicId` que o formulário do site manda
/// ao criar um pedido (e o que vai nas URLs da vitrine). Dá para copiar.
class PublicIdTile extends StatelessWidget {
  const PublicIdTile({super.key, required this.publicId});

  final String publicId;

  Future<void> _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: publicId));
    if (context.mounted) {
      Toast.show(context, text: 'ID público copiado.', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return GlassPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID público (formulário do site)',
                  style: TextStyle(fontWeight: FontWeight.w700, color: colors.heading),
                ),
                const SizedBox(height: 4),
                Text(publicId, style: TextStyle(fontSize: 12, color: colors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Button(
            text: 'Copiar',
            variant: ButtonVariant.outline,
            onPressed: () => _copiar(context),
          ),
        ],
      ),
    );
  }
}
