import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

void main() {
  const maker = Maker(
    nome: 'Maria',
    email: 'maria@exemplo.com',
    aceitouTermos: true,
  );

  test('igualdade por valor', () {
    expect(
      maker,
      const Maker(
        nome: 'Maria',
        email: 'maria@exemplo.com',
            aceitouTermos: true,
      ),
    );
    expect(maker.hashCode, maker.hashCode);
  });

  test('toString não expõe a senha', () {
    expect(
      const Credenciais(email: 'a@b.com', senha: 'segredo').toString(),
      isNot(contains('segredo')),
    );
    expect(
      const Cadastro(nome: 'A', email: 'a@b.com', senha: 'segredo').toString(),
      isNot(contains('segredo')),
    );
  });
}
