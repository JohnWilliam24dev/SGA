import 'package:flutter/material.dart'
    show InputDecoration, OutlineInputBorder, TextField;
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';

import '../../Shared/widgets/glass/glass_panel.dart';

/// Painel com a caixa de texto dos termos de serviço. Cada alteração sai
/// por [onChanged].
class ProfileTerms extends StatefulWidget {
  const ProfileTerms({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<ProfileTerms> createState() => _ProfileTermsState();
}

class _ProfileTermsState extends State<ProfileTerms> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: TextField(
        controller: _controller,
        minLines: 9,
        maxLines: 14,
        onChanged: widget.onChanged,
        // Limite da API para os termos de serviço.
        inputFormatters: [LengthLimitingTextInputFormatter(5000)],
        decoration: const InputDecoration(
          hintText: 'Escreva aqui os seus termos de serviço...',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
