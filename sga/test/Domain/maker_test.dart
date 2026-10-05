import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

void main() {
  const maker = Maker(
    nome: 'Maria',
    email: 'maria@exemplo.com',
    senha: 'Senha1234',
    aceitouTermos: true,
  );

  test('igualdade por valor', () {
    expect(
      maker,
      const Maker(
        nome: 'Maria',
        email: 'maria@exemplo.com',
        senha: 'Senha1234',
        aceitouTermos: true,
      ),
    );
    expect(maker.hashCode, maker.hashCode);
  });

  test('toString não expõe a senha', () {
    expect(maker.toString(), isNot(contains('Senha1234')));
    expect(
      const Credenciais(email: 'a@b.com', senha: 'segredo').toString(),
      isNot(contains('segredo')),
    );
  });
}
