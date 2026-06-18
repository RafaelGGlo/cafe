import 'item_pedido.dart';

class Pedido {
  const Pedido({
    required this.id,
    required this.numero,
    required this.nomeCliente,
    required this.criadoPor,
    required this.itens,
    required this.observacao,
    required this.total,
    required this.status,
    required this.dataCriacao,
  });

  final String id;
  final int numero;
  final String nomeCliente;
  final String criadoPor;
  final List<ItemPedido> itens;
  final String observacao;
  final double total;
  final String status;
  final DateTime dataCriacao;
}
