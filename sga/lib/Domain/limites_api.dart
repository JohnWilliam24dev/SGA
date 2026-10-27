/// Limites que a API impõe (mapeamento oficial, seção 9). O app confere antes
/// para dar retorno rápido, mas quem decide é o servidor: o 400/409 dele
/// sempre aparece na tela.
const nomeMaximo = 80; // maker, tipo, adicional, produto, status e cliente
const contatoMaximo = 160;
const emailMaximo = 254;
const descricaoPedidoMaximo = 1000;
const descricaoAdicionalPedidoMaximo = 500;
const adicionaisPorPedidoMaximo = 20; // distintos; cada um de 1 a 20 unidades
const statusPorMakerMaximo = 20;
