import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/material.dart' as m show Icon;
import 'package:flutter/material.dart'
    show IconButton, Icons, InputDecoration, OutlineInputBorder, TextField;
import 'package:flutter/widgets.dart' hide Icon;

/// Conteúdo do diálogo que edita uma lista ("Eu faço" / "Eu não faço"):
/// os itens com um X para remover e um campo para acrescentar. Cada mudança
/// sai por [onChanged] com a lista inteira.
class ScopeEditor extends StatefulWidget {
  const ScopeEditor({
    super.key,
    required this.title,
    required this.initial,
    required this.onChanged,
    required this.onClose,
  });

  final String title;
  final List<String> initial;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onClose;

  @override
  State<ScopeEditor> createState() => _ScopeEditorState();
}

class _ScopeEditorState extends State<ScopeEditor> {
  late final List<String> _items = List.of(widget.initial);
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mudou() {
    setState(() {});
    widget.onChanged(List.of(_items));
  }

  void _adicionar() {
    final valor = _controller.text.trim();
    if (valor.isEmpty || _items.contains(valor)) return;
    _items.add(valor);
    _controller.clear();
    _mudou();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(type: LabelType.subtitle, text: widget.title),
          const SizedBox(height: 12),
          if (_items.isEmpty)
            const Label(type: LabelType.caption, text: 'Nenhum item informado.'),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final item in _items)
                    Row(
                      children: [
                        Expanded(child: Text(item)),
                        IconButton(
                          tooltip: 'Remover',
                          icon: const m.Icon(Icons.close_rounded),
                          onPressed: () {
                            _items.remove(item);
                            _mudou();
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Novo item',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _adicionar(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                Button(
                  text: 'Voltar',
                  variant: ButtonVariant.ghost,
                  onPressed: widget.onClose,
                ),
                Button(text: 'Adicionar', onPressed: _adicionar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
