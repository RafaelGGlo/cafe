import 'package:flutter/material.dart';

import '../models/pedido.dart';

class TelaDetalhesPedido extends StatelessWidget {
  const TelaDetalhesPedido({super.key, required this.pedido});

  final Pedido pedido;

  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} $hora:$minuto';
  }

  String _numeroPedido(Pedido pedido) {
    return 'Pedido #${pedido.numero.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: Text(_numeroPedido(pedido)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          children: [
            _InfoCard(
              children: [
                _LinhaInfo(
                  label: 'Data/hora',
                  valor: _formatarData(pedido.dataCriacao),
                ),
                _LinhaInfo(label: 'Criado por', valor: pedido.criadoPor),
                _LinhaInfo(label: 'Cliente/mesa', valor: pedido.nomeCliente),
                _LinhaInfo(label: 'Status', valor: pedido.status),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Itens',
              style: TextStyle(
                color: _coffeeBrown,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ...pedido.itens.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _coffeeBrown.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.produto.nome,
                      style: const TextStyle(
                        color: _coffeeBrown,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LinhaInfo(
                      label: 'Quantidade',
                      valor: '${item.quantidade}',
                    ),
                    _LinhaInfo(
                      label: 'Preço unitário',
                      valor: _formatarPreco(item.produto.preco),
                    ),
                    _LinhaInfo(
                      label: 'Subtotal',
                      valor: _formatarPreco(item.subtotal),
                    ),
                  ],
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _LinhaInfo(
                label: 'Total',
                valor: _formatarPreco(pedido.total),
                destaque: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({
    required this.label,
    required this.valor,
    this.destaque = false,
  });

  final String label;
  final String valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: TelaDetalhesPedido._coffeeBrown.withValues(alpha: 0.70),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: destaque
                    ? TelaDetalhesPedido._softGreen
                    : TelaDetalhesPedido._coffeeBrown,
                fontSize: destaque ? 18 : 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
