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
  Domain/                Maker, Credenciais, CommissionColumn, regra de mover
                         commission (commission_board) e o repositório
                         (interface + versão simulada em memória)
    models/              modelos da API (fromJson/toJson): Status, TipoProduto,
                         Adicional, Produto, CommissionAdicional,
                         CommissionResumo e CommissionDetalhada
  Shared/                widgets reutilizáveis (KanbanBoard, AdaptiveDrawerScaffold,
                         GlassAppShell, SidebarToggleIcon, SgaLogo, PulseLine,
                         FadeIn, AuthShell) e formatadores (moeda e data)
  View/                  telas
    welcome/             tela inicial (Cadastre-se / Login)
    auth/                login e cadastro
    main/                área autenticada (navegação lateral responsiva)
    commissions/         quadro kanban e detalhe da commission
    dashboard/           Financeiro, Relatório de pedidos e Produtos
    catalog/             tipos de produtos e adicionais
    profile/             perfil do artista
    settings/            configurações
    support/             suporte
test/                    espelha a estrutura de lib/
```

## Telas

- **Inicial:** marca animada e os botões Cadastre-se e Login.
- **Cadastro:** nome, e-mail, senha, confirmar senha e aceite dos termos de
  uso. Ao enviar, gera um `Maker` e abre o app (ainda sem servidor).
- **Login:** e-mail, senha e o link "Esqueci a senha" (ainda sem função).
  Qualquer login válido entra, enquanto não há autenticação.
- **Commissions (página principal):** quadro kanban no estilo Trello/Jira.
  As colunas vêm de uma lista (não são fixas) e os cards são o resumo da
  commission (cliente, tipo de produto e valor: o orçamento final, ou o
  simulado enquanto não fechou), em altura padrão.
  - *Abrir o detalhe:* um clique/toque simples no card.
  - *Mover um card:* apertar e segurar por um instante (mouse ou toque).
    Deslizar sem segurar rola o quadro.
  - *Largura de tablet/desktop:* colunas lado a lado, arrastar e soltar entre
    colunas e reordenando, rolagem automática nas bordas e arrastar o fundo do
    quadro para rolar na horizontal.
  - *Largura de celular (< 600px, inclusive janela estreita de navegador):* uma
    coluna por vez, que sempre encaixa (nunca no meio); um leve deslizar troca
    de coluna. Com o card na mão, levá-lo até a borda da tela troca de coluna
    sozinho.
- **Detalhe da commission:** abre ao tocar no card. O cabeçalho aparece na
  hora (vem do resumo) e o restante é buscado no repositório: orçamento
  (simulado e final), descrição e imagem de referência, adicionais (quantidade,
  valor unitário e subtotal), contato, e-mail (quando houver), código de
  acompanhamento e data de criação.
- **Seções da área autenticada** (menu lateral): *Pedidos* (o kanban de
  commissions), *Financeiro*, *Relatório de pedidos*, *Produtos* e *Tipos de
  produtos* (catálogo de tipos e adicionais, editável em memória). *Perfil*,
  *Configurações* e *Suporte* ficam à parte das cinco principais. Todas leem
  os dados por repositório (nunca direto dos mocks), então a troca pela API
  não mexe nas telas.
- **Navegação:** tablet/desktop com barra lateral fixa, recolhida pelo ícone
  de painel no topo dela (vira uma faixa só de ícones; recolhida, a logo do
  sistema vira o ícone de "mostrar a barra" ao passar o mouse); celular com
  drawer (fundo escurece ao abrir).

Os dados de commissions são simulados em
`lib/Domain/commission_repository.dart` (`FakeCommissionRepository`): o quadro
usa `CommissionResumoModel` e o detalhe usa `CommissionDetalhadaModel`, os
mesmos modelos que a API vai devolver. A integração com o servidor entra
trocando essa implementação.

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
