import 'package:flutter/material.dart';

import '../models/item_pedido.dart';
import '../services/pedido_service.dart';
import '../widgets/item_pedido_card.dart';
import 'tela_novo_pedido.dart';

class TelaVerPedido extends StatefulWidget {
  const TelaVerPedido({super.key, required this.itens});

  final List<ItemPedido> itens;

  @override
  State<TelaVerPedido> createState() => _TelaVerPedidoState();
}

class _TelaVerPedidoState extends State<TelaVerPedido> {
  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);

  late final List<ItemPedido> _itens = List<ItemPedido>.from(widget.itens);

  double get _total => PedidoService.instance.calcularTotal(_itens);

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _voltar() {
    Navigator.pop(context, List<ItemPedido>.from(_itens));
  }

  void _alterarQuantidade(ItemPedido item, int novaQuantidade) {
    final index = _itens.indexWhere(
      (itemPedido) => itemPedido.produto.id == item.produto.id,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      if (novaQuantidade <= 0) {
        _itens.removeAt(index);
      } else {
        _itens[index] = item.copyWith(quantidade: novaQuantidade);
      }
    });
  }

  void _removerItem(ItemPedido item) {
    setState(() {
      _itens.removeWhere(
        (itemPedido) => itemPedido.produto.id == item.produto.id,
      );
    });
  }

  Future<void> _finalizarPedido() async {
    if (_itens.isEmpty) {
      return;
    }

    final pedidoSalvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaNovoPedido(itensIniciais: _itens),
      ),
    );

    if (!mounted) {
      return;
    }

    if (pedidoSalvo ?? false) {
      Navigator.pop(context, <ItemPedido>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _voltar();
        }
      },
      child: Scaffold(
        backgroundColor: _lightBeige,
        appBar: AppBar(
          title: const Text('Ver pedido'),
          leading: IconButton(
            onPressed: _voltar,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Itens do pedido',
                      style: TextStyle(
                        color: _coffeeBrown,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    _formatarPreco(_total),
                    style: const TextStyle(
                      color: _softGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_itens.isEmpty)
                const _MensagemVazia()
              else
                ..._itens.map((item) {
                  return ItemPedidoCard(
                    item: item,
                    formatarPreco: _formatarPreco,
                    onAumentar: () =>
                        _alterarQuantidade(item, item.quantidade + 1),
                    onDiminuir: () =>
                        _alterarQuantidade(item, item.quantidade - 1),
                    onRemover: () => _removerItem(item),
                  );
                }),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _LinhaResumo(
                      label: 'Total',
                      valor: _formatarPreco(_total),
                      destaque: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _itens.isEmpty ? null : _finalizarPedido,
                  style: FilledButton.styleFrom(
                    backgroundColor: _coffeeBrown,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _coffeeBrown.withValues(
                      alpha: 0.32,
                    ),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.72,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Finalizar pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaResumo extends StatelessWidget {
  const _LinhaResumo({
    required this.label,
    required this.valor,
    this.destaque = false,
  });

  final String label;
  final String valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: _TelaVerPedidoState._coffeeBrown,
            fontWeight: destaque ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          valor,
          style: TextStyle(
            color: destaque
                ? _TelaVerPedidoState._softGreen
                : _TelaVerPedidoState._coffeeBrown,
            fontSize: destaque ? 18 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MensagemVazia extends StatelessWidget {
  const _MensagemVazia();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Nenhum item adicionado.',
        style: TextStyle(
          color: _TelaVerPedidoState._coffeeBrown.withValues(alpha: 0.65),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
