import 'package:dio/dio.dart';

/// O que deu errado numa chamada à API, já traduzido para o app.
enum ApiErroTipo {
  validacao, // 400
  sessaoExpirada, // 401
  doisFatorObrigatorio, // 403 com código 2FA_OBRIGATORIO
  proibido, // 403
  naoEncontrado, // 404
  conflito, // 409
  arquivoGrande, // 413
  limite, // 429
  conexao, // sem rede, tempo esgotado
  servidor, // 5xx
  inesperado,
}

/// Erro de uma chamada à API. A [mensagem] vem do campo `error` do servidor
/// (ou de um texto padrão) e já pode ser mostrada ao usuário.
class ApiException implements Exception {
  const ApiException({
    required this.tipo,
    required this.mensagem,
    this.status,
    this.codigo,
    this.retryAfter,
    this.campos = const [],
  });

  /// Monta o erro a partir de uma resposta HTTP com falha.
  factory ApiException.deResposta(
    int status,
    Object? corpo, {
    String? retryAfter,
  }) {
    final mapa = corpo is Map ? corpo : const <dynamic, dynamic>{};
    final bruto = mapa['codigo'];
    final codigo = bruto is String ? bruto : null;
    final tipo = _tipoDe(status, codigo);
    return ApiException(
      tipo: tipo,
      status: status,
      codigo: codigo,
      retryAfter: _segundos(retryAfter),
      mensagem: _texto(mapa['error']) ?? _padrao[tipo]!,
      campos: _campos(mapa['campos']),
    );
  }

  factory ApiException.deDio(DioException e) {
    final interno = e.error;
    if (interno is ApiException) return interno;
    final status = e.response?.statusCode;
    if (status == null) return ApiException.conexao();
    return ApiException.deResposta(
      status,
      e.response!.data,
      retryAfter: e.response!.headers.value('retry-after'),
    );
  }

  factory ApiException.conexao() => ApiException(
        tipo: ApiErroTipo.conexao,
        mensagem: _padrao[ApiErroTipo.conexao]!,
      );

  factory ApiException.sessaoExpirada() => ApiException(
        tipo: ApiErroTipo.sessaoExpirada,
        status: 401,
        mensagem: _padrao[ApiErroTipo.sessaoExpirada]!,
      );

  static const codigo2faObrigatorio = '2FA_OBRIGATORIO';

  final ApiErroTipo tipo;
  final int? status;
  final String mensagem;
  final String? codigo;

  /// Campos recusados no 400 (`adicionais.1.quantidade` em itens de lista).
  final List<({String campo, String mensagem})> campos;
  /// Quanto esperar (header `Retry-After`) quando [tipo] é `limite`.
  final Duration? retryAfter;

  /// 400 e 409: regra de negócio recusada pelo servidor. Os repositórios
  /// convertem em `CommissionRegraException`/`StatusRegraException`.
  bool get ehRegra =>
      tipo == ApiErroTipo.validacao || tipo == ApiErroTipo.conflito;

  /// Texto final para a tela; no limite de requisições informa a espera.
  String get mensagemParaUsuario {
    final s = retryAfter?.inSeconds;
    if (tipo != ApiErroTipo.limite || s == null) return mensagem;
    return '$mensagem Tente de novo em ${s}s.';
  }

  @override
  String toString() => mensagem;

  static ApiErroTipo _tipoDe(int status, String? codigo) => switch (status) {
        400 => ApiErroTipo.validacao,
        401 => ApiErroTipo.sessaoExpirada,
        403 => codigo == codigo2faObrigatorio
            ? ApiErroTipo.doisFatorObrigatorio
            : ApiErroTipo.proibido,
        404 => ApiErroTipo.naoEncontrado,
        409 => ApiErroTipo.conflito,
        413 => ApiErroTipo.arquivoGrande,
        429 => ApiErroTipo.limite,
        >= 500 => ApiErroTipo.servidor,
        _ => ApiErroTipo.inesperado,
      };

  /// `error` pode ser texto ou lista de mensagens (validação).
  static String? _texto(Object? valor) {
    final t = switch (valor) {
      final String s => s,
      final List l => l.join(' '),
      _ => null,
    };
    return t == null || t.trim().isEmpty ? null : t.trim();
  }

  static List<({String campo, String mensagem})> _campos(Object? v) => [
        for (final c in v is List ? v : const [])
          if (c is Map && c['campo'] is String && c['mensagem'] is String)
            (campo: c['campo'] as String, mensagem: c['mensagem'] as String),
      ];

  static Duration? _segundos(String? valor) {
    final n = int.tryParse(valor ?? '');
    return n == null ? null : Duration(seconds: n);
  }

  static const _padrao = {
    ApiErroTipo.validacao: 'Dados inválidos.',
    ApiErroTipo.sessaoExpirada: 'Sessão expirada. Entre novamente.',
    ApiErroTipo.doisFatorObrigatorio:
        'Ative a verificação em duas etapas para continuar.',
    ApiErroTipo.proibido: 'Você não tem permissão para isso.',
    ApiErroTipo.naoEncontrado: 'Não encontrado.',
    ApiErroTipo.conflito: 'Essa ação conflita com o estado atual.',
    ApiErroTipo.arquivoGrande: 'Arquivo grande demais. O limite é 4 MB.',
    ApiErroTipo.limite: 'Muitas requisições. Aguarde um instante e tente de novo.',
    ApiErroTipo.conexao:
        'Sem conexão com o servidor. Verifique a internet e tente de novo.',
    ApiErroTipo.servidor: 'Erro no servidor. Tente de novo em instantes.',
    ApiErroTipo.inesperado: 'Algo deu errado. Tente de novo.',
  };
}
