import 'produto.dart';

class ItemPedido {
  ItemPedido({required this.produto, required this.quantidade});

  final Produto produto;
  final int quantidade;

  double get subtotal => produto.preco * quantidade;

  ItemPedido copyWith({Produto? produto, int? quantidade}) {
    return ItemPedido(
      produto: produto ?? this.produto,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}
