import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';

/// Segurança: situação do 2FA e geração de um novo lote de códigos de
/// recuperação (pede o código do autenticador e a senha).
class TwoFactorSection extends StatefulWidget {
  const TwoFactorSection({super.key, required this.repository});

  final DoisFatorRepository repository;

  @override
  State<TwoFactorSection> createState() => _TwoFactorSectionState();
}

class _TwoFactorSectionState extends State<TwoFactorSection> {
  bool _formulario = false;
  List<String>? _codigos;
  int _versao = 0;

  Future<void> _gerar(FormValues v) async {
    try {
      final novos = await widget.repository.regenerarCodigos(
        codigo: v['codigo']!.trim(),
        senha: v['senha'],
      );
      if (mounted) {
        setState(() {
          _codigos = novos;
          _formulario = false;
          _versao++;
        });
      }
    } catch (e) {
      if (mounted) {
        Toast.error(
          context,
          text: mensagemDeErro(e, 'Não foi possível gerar os códigos.'),
        );
      }
    }
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _codigos!.join('\n')));
    if (mounted) {
      Toast.show(context, text: 'Códigos copiados.', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Div(
      width: 100.pct,
      children: [
        const Label(type: LabelType.title, text: 'Segurança'),
        KeyedSubtree(
          key: ValueKey(_versao),
          child: AsyncView<DoisFatorEstado>(
            load: widget.repository.estado,
            builder: (context, e) => Label(
              type: LabelType.caption,
              text: e.ativo
                  ? 'Verificação em duas etapas ativada. Códigos de recuperação '
                      'restantes: ${e.codigosRecuperacaoRestantes}.'
                  : 'Verificação em duas etapas desativada.',
            ),
          ),
        ),
        if (_codigos != null) ...[
          const Label(
            type: LabelType.caption,
            text: 'Novos códigos (os anteriores deixaram de valer). Cada um vale '
                'uma vez e só aparece agora: guarde-os antes de sair.',
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final c in _codigos!) SizedBox(width: 130, child: Label(text: c)),
            ],
          ),
          Button(text: 'Copiar códigos', variant: ButtonVariant.outline, onPressed: _copiar),
        ],
        if (!_formulario)
          Button(
            text: 'Gerar novos códigos de recuperação',
            variant: ButtonVariant.outline,
            onPressed: () => setState(() {
              _formulario = true;
              _codigos = null;
            }),
          )
        else
          FormGroup(
            width: 100.pct,
            children: [
              InputField(
                name: 'codigo',
                hint: 'Código de 6 dígitos do autenticador',
                validation: [
                  isRequired(),
                  matches(RegExp(r'^\s*\d{6}\s*$'), message: 'Digite os 6 dígitos'),
                ],
              ),
              InputField(
                name: 'senha',
                hint: 'Senha da conta',
                type: InputType.password,
                validation: [isRequired()],
              ),
              Button(text: 'Gerar códigos', expanded: true, onSubmit: _gerar),
              Button(
                text: 'Cancelar',
                variant: ButtonVariant.link,
                onPressed: () => setState(() => _formulario = false),
              ),
            ],
          ),
      ],
    );
  }
}
