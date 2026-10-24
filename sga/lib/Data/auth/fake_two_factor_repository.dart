import '../../Core/network/network.dart';
import '../../Domain/domain.dart';

/// 2FA simulado (testes e desenvolvimento sem servidor): o código certo é
/// sempre `123456`.
class FakeDoisFatorRepository implements DoisFatorRepository {
  FakeDoisFatorRepository(this._sessao);

  static const codigoCerto = '123456';
  static const codigosRecuperacao = [
    'AAAAAAAAAA01', 'AAAAAAAAAA02', 'AAAAAAAAAA03', 'AAAAAAAAAA04',
    'AAAAAAAAAA05', 'AAAAAAAAAA06', 'AAAAAAAAAA07', 'AAAAAAAAAA08',
  ];

  final SessaoStore _sessao;

  @override
  Future<DoisFatorInicio?> iniciar() async => const DoisFatorInicio(
        segredo: 'JBSWY3DPEHPK3PXP',
        uri: 'otpauth://totp/A-BR:fake?secret=JBSWY3DPEHPK3PXP&issuer=A-BR',
      );

  @override
  Future<List<String>> confirmar(String codigo) async {
    if (codigo != codigoCerto) {
      throw const ApiException(
        tipo: ApiErroTipo.validacao,
        mensagem: 'Código inválido',
      );
    }
    return codigosRecuperacao;
  }

  @override
  Future<void> concluirAtivacao() => _sessao.iniciar(
        const SessaoTokens(
          accessToken: 'fake',
          refreshToken: 'fake',
          makerId: 'fake',
          escopo: 'completo',
        ),
        nome: _sessao.nome,
        email: _sessao.email,
      );
}
