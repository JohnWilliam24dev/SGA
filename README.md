# SGA — Sistema de Gerenciamento Artístico

ERP para artistas, desenvolvido em Flutter sobre o framework de UI
[Easy UI](https://github.com/JohnWilliam24dev/Easy_UI_Framework). O app fica
na pasta [`sga/`](sga).

## Identidade

Visual limpo, de sistema de saúde, com azul `#1E90FF` como cor da marca
(definida em `sga/lib/Core/theme/sga_theme.dart`).

## Estrutura (`sga/`)

```
lib/
  main.dart              ponto de entrada
  Core/                  tema (tokens + StylePack), rotas e a raiz SgaApp
  Domain/                entidades: Maker, Credenciais
  Shared/                widgets reutilizáveis: SgaLogo, PulseLine, FadeIn, AuthShell
  View/                  telas
    welcome/             tela inicial (Cadastre-se / Login)
    auth/                login e cadastro
test/                    espelha a estrutura de lib/
```

## Telas

- **Inicial:** marca animada e os botões Cadastre-se e Login.
- **Cadastro:** nome, e-mail, senha, confirmar senha e aceite dos termos de
  uso. Ao enviar, gera um `Maker` (ainda sem envio a servidor).
- **Login:** e-mail, senha e o link "Esqueci a senha" (ainda sem função).

## Rodando

```bash
cd sga
flutter pub get
flutter test
flutter run
```

## Branches

- `develop`: desenvolvimento e testes locais
- `main`: versão revisada (recebe PR de `develop`)
