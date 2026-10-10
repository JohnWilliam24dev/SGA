import 'package:easy_ui/easy_ui.dart' show Toast, ToastType;
import 'package:flutter/material.dart';

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass_app_shell.dart';

enum _Acao { renomear, tipo, subir, descer, excluir }

/// Configuração das colunas do quadro de pedidos: criar, renomear, reordenar,
/// trocar o tipo e excluir.
///
/// As regras (uma coluna Inicial, ao menos uma Concluído e uma Cancelado, não
/// excluir coluna com pedidos) vivem em `status_rules.dart`; aqui a tela só
/// chama o [repository] e mostra o motivo quando ele recusa.
class StatusSettingsPanel extends StatefulWidget {
  const StatusSettingsPanel({super.key, required this.repository});

  final StatusRepository repository;

  @override
  State<StatusSettingsPanel> createState() => _StatusSettingsPanelState();
}

class _StatusSettingsPanelState extends State<StatusSettingsPanel> {
  List<StatusModel>? _status;
  bool _falhou = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _falhou = false);
    try {
      final status = await widget.repository.listar();
      if (!mounted) return;
      setState(() => _status = status);
    } catch (_) {
      if (!mounted) return;
      setState(() => _falhou = true);
    }
  }

  /// Roda uma alteração; se o repositório recusar, mostra o motivo. Em
  /// qualquer caso recarrega a lista, para a tela espelhar o que ficou salvo.
  Future<void> _executar(Future<void> Function() acao) async {
    String? erro;
    try {
      await acao();
    } on StatusRegraException catch (e) {
      erro = e.mensagem;
    } catch (_) {
      erro = 'Não foi possível salvar a alteração.';
    }
    if (!mounted) return;
    if (erro != null) {
      Toast.show(context, text: erro, type: ToastType.error);
    }
    await _carregar();
  }

  Future<void> _nova() async {
    final nome = await showDialog<String>(
      context: context,
      builder: (_) =>
          const _NomeDialog(titulo: 'Nova coluna', confirmar: 'Criar'),
    );
    if (nome == null || !mounted) return;
    await _executar(() => widget.repository.criar(nome));
  }

  void _aoReordenar(int de, int para) {
    final atual = _status;
    if (atual == null) return;
    if (para > de) para -= 1;
    if (de == para) return;
    final novos = [...atual];
    novos.insert(para, novos.removeAt(de));
    // Mostra a nova ordem já; _executar recarrega com o que o repositório salvou.
    setState(() => _status = novos);
    _executar(() => widget.repository.reordenar([for (final s in novos) s.id]));
  }

  Future<void> _aoEscolher(_Acao acao, StatusModel status, int indice) async {
    final atual = _status;
    if (atual == null) return;
    switch (acao) {
      case _Acao.renomear:
        final nome = await showDialog<String>(
          context: context,
          builder: (_) => _NomeDialog(
            titulo: 'Renomear coluna',
            confirmar: 'Salvar',
            inicial: status.nome,
          ),
        );
        if (nome == null || !mounted) return;
        await _executar(() => widget.repository.renomear(status.id, nome));
      case _Acao.tipo:
        final tipo = await showDialog<StatusTipo>(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Tipo da coluna'),
            children: [
              for (final opcao in StatusTipo.values)
                SimpleDialogOption(
                  key: ValueKey('tipo-${opcao.name}'),
                  onPressed: () => Navigator.of(dialogContext).pop(opcao),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opcao == status.tipo
                            ? '${opcao.rotulo} (atual)'
                            : opcao.rotulo,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(opcao.descricao),
                    ],
                  ),
                ),
            ],
          ),
        );
        if (tipo == null || tipo == status.tipo || !mounted) return;
        await _executar(() => widget.repository.trocarTipo(status.id, tipo));
      case _Acao.subir:
        await _moverUma(atual, indice, -1);
      case _Acao.descer:
        await _moverUma(atual, indice, 1);
      case _Acao.excluir:
        final confirmou = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Excluir coluna'),
            content: Text('A coluna "${status.nome}" será removida do quadro.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
        if (confirmou != true || !mounted) return;
        await _executar(() => widget.repository.excluir(status.id));
    }
  }

  Future<void> _moverUma(List<StatusModel> atual, int indice, int delta) {
    final ids = [for (final s in atual) s.id];
    ids.insert(indice + delta, ids.removeAt(indice));
    return _executar(() => widget.repository.reordenar(ids));
  }

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    final pronto = _status != null && !_falhou;

    return GlassPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colunas do quadro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Defina as etapas dos pedidos. O nome é livre; o tipo diz ao '
            'sistema o que a coluna significa.',
            style: TextStyle(color: colors.muted),
          ),
          const SizedBox(height: 12),
          _conteudo(colors),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('status-nova'),
            onPressed: pronto ? _nova : null,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova coluna'),
          ),
        ],
      ),
    );
  }

  Widget _conteudo(SgaColors colors) {
    final status = _status;
    if (_falhou) {
      return Row(
        children: [
          Text(
            'Não foi possível carregar as colunas.',
            style: TextStyle(color: colors.error),
          ),
          TextButton(onPressed: _carregar, child: const Text('Tentar de novo')),
        ],
      );
    }
    if (status == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: status.length,
      onReorder: _aoReordenar,
      itemBuilder: (context, indice) =>
          _linha(status[indice], indice, status.length, colors),
    );
  }

  Widget _linha(StatusModel status, int indice, int total, SgaColors colors) {
    return ListTile(
      key: ValueKey('status-linha-${status.id}'),
      contentPadding: EdgeInsets.zero,
      leading: ReorderableDragStartListener(
        index: indice,
        child: Icon(Icons.drag_indicator_rounded, color: colors.muted),
      ),
      title: Text(
        status.nome,
        key: ValueKey('status-nome-${status.id}'),
        style: TextStyle(fontWeight: FontWeight.w700, color: colors.text),
      ),
      subtitle: Text(status.tipo.rotulo, style: TextStyle(color: colors.muted)),
      trailing: PopupMenuButton<_Acao>(
        key: ValueKey('status-menu-${status.id}'),
        tooltip: 'Ações da coluna',
        onSelected: (acao) => _aoEscolher(acao, status, indice),
        itemBuilder: (_) => [
          const PopupMenuItem(value: _Acao.renomear, child: Text('Renomear')),
          const PopupMenuItem(value: _Acao.tipo, child: Text('Alterar tipo')),
          PopupMenuItem(
            value: _Acao.subir,
            enabled: indice > 0,
            child: const Text('Mover para cima'),
          ),
          PopupMenuItem(
            value: _Acao.descer,
            enabled: indice < total - 1,
            child: const Text('Mover para baixo'),
          ),
          const PopupMenuItem(value: _Acao.excluir, child: Text('Excluir')),
        ],
      ),
    );
  }
}

class _NomeDialog extends StatefulWidget {
  const _NomeDialog({
    required this.titulo,
    required this.confirmar,
    this.inicial = '',
  });

  final String titulo;
  final String confirmar;
  final String inicial;

  @override
  State<_NomeDialog> createState() => _NomeDialogState();
}

class _NomeDialogState extends State<_NomeDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.inicial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        key: const ValueKey('status-nome-campo'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nome da coluna'),
        onSubmitted: (valor) => Navigator.of(context).pop(valor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmar),
        ),
      ],
    );
  }
}
