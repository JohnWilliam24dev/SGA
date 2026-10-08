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
  Domain/                Maker, Credenciais, Commission, CommissionColumn,
                         regra de mover (moverCommission) e o repositório
                         (interface + versão simulada em memória)
  Shared/                widgets reutilizáveis: KanbanBoard, AdaptiveDrawerScaffold,
                         SgaLogo, PulseLine, FadeIn, AuthShell
  View/                  telas
    welcome/             tela inicial (Cadastre-se / Login)
    auth/                login e cadastro
    main/                área autenticada (navegação lateral responsiva)
    commissions/         quadro kanban de commissions
test/                    espelha a estrutura de lib/
```

## Telas

- **Inicial:** marca animada e os botões Cadastre-se e Login.
- **Cadastro:** nome, e-mail, senha, confirmar senha e aceite dos termos de
  uso. Ao enviar, gera um `Maker` e abre o app (ainda sem servidor).
- **Login:** e-mail, senha e o link "Esqueci a senha" (ainda sem função).
  Qualquer login válido entra, enquanto não há autenticação.
- **Commissions (página principal):** quadro kanban no estilo Trello/Jira.
  As colunas vêm de uma lista (não são fixas) e os cards são commissions
  (cliente + começo da descrição, em altura padrão).
  - *Mover um card:* apertar e segurar por um instante (mouse ou toque). Um
    clique/toque simples fica livre para abrir os detalhes e deslizar sem
    segurar rola o quadro.
  - *Largura de tablet/desktop:* colunas lado a lado, arrastar e soltar entre
    colunas e reordenando, rolagem automática nas bordas e arrastar o fundo do
    quadro para rolar na horizontal.
  - *Largura de celular (< 600px, inclusive janela estreita de navegador):* uma
    coluna por vez, que sempre encaixa (nunca no meio); um leve deslizar troca
    de coluna. Com o card na mão, levá-lo até a borda da tela troca de coluna
    sozinho.
- **Navegação:** tablet/desktop com barra lateral fixa, recolhida pelo ícone
  de painel no topo dela (vira uma faixa só de ícones; recolhida, a logo do
  sistema vira o ícone de "mostrar a barra" ao passar o mouse); celular com
  drawer (fundo escurece ao abrir).

Os dados de commissions são simulados em
`lib/Domain/commission_repository.dart` (`FakeCommissionRepository`); a
integração com o banco entra trocando essa implementação.

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
