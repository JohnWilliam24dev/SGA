import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';

void main() {
  group('ApiException.deResposta', () {
    test('usa a mensagem do campo error', () {
      final e = ApiException.deResposta(409, {'error': 'Coluna em uso'});
      expect(e.tipo, ApiErroTipo.conflito);
      expect(e.mensagem, 'Coluna em uso');
      expect(e.ehRegra, isTrue);
    });

    test('junta a lista de mensagens da validação', () {
      final e = ApiException.deResposta(400, {
        'error': ['nome muito longo', 'senha curta'],
      });
      expect(e.tipo, ApiErroTipo.validacao);
      expect(e.mensagem, 'nome muito longo senha curta');
      expect(e.ehRegra, isTrue);
    });

    test('403 com 2FA_OBRIGATORIO pede a ativação do 2FA', () {
      final e = ApiException.deResposta(403, {
        'error': 'Ative o 2FA',
        'codigo': '2FA_OBRIGATORIO',
      });
      expect(e.tipo, ApiErroTipo.doisFatorObrigatorio);
      expect(e.codigo, ApiException.codigo2faObrigatorio);
    });

    test('403 sem código é proibido', () {
      expect(
        ApiException.deResposta(403, {'error': 'x'}).tipo,
        ApiErroTipo.proibido,
      );
    });

    test('429 lê o Retry-After e informa a espera', () {
      final e = ApiException.deResposta(429, null, retryAfter: '30');
      expect(e.tipo, ApiErroTipo.limite);
      expect(e.retryAfter, const Duration(seconds: 30));
      expect(e.mensagemParaUsuario, contains('30s'));
    });

    test('corpo vazio cai no texto padrão de cada status', () {
      expect(ApiException.deResposta(404, null).tipo,
          ApiErroTipo.naoEncontrado);
      expect(ApiException.deResposta(413, '').tipo, ApiErroTipo.arquivoGrande);
      expect(ApiException.deResposta(502, null).tipo, ApiErroTipo.servidor);
      expect(ApiException.deResposta(418, null).tipo, ApiErroTipo.inesperado);
      expect(ApiException.deResposta(404, null).mensagem, 'Não encontrado.');
    });

    test('404 e 5xx não são regra de negócio', () {
      expect(ApiException.deResposta(404, null).ehRegra, isFalse);
      expect(ApiException.deResposta(500, null).ehRegra, isFalse);
    });
  });
}
