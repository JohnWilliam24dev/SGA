import 'package:flutter/material.dart'
    show InputDecoration, OutlineInputBorder, TextField;
import 'package:flutter/services.dart' show TextInputType;
import 'package:flutter/widgets.dart';

import '../../Core/theme/sga_theme.dart';

/// Campo de texto com borda dos editores. [decimal] abre o teclado numérico.
class EditorTextField extends StatelessWidget {
  const EditorTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Subtítulo de uma parte do editor ("Regra de preço", ...).
class EditorHeading extends StatelessWidget {
  const EditorHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: SgaColors.of(context).heading,
      ),
    );
  }
}
