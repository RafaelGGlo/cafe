import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../services/pedido_service.dart';
import 'tela_detalhes_pedido.dart';

class TelaPedidosRealizados extends StatelessWidget {
  const TelaPedidosRealizados({super.key});

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
        title: const Text('Pedidos realizados'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: PedidoService.instance,
          builder: (context, _) {
            final pedidos = PedidoService.instance
                .listarPedidos()
                .reversed
                .toList();

            if (pedidos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Nenhum pedido realizado ainda.',
                    style: TextStyle(
                      color: _coffeeBrown.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return _PedidoCard(
                  pedido: pedido,
                  numero: _numeroPedido(pedido),
                  data: _formatarData(pedido.dataCriacao),
                  total: _formatarPreco(pedido.total),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TelaDetalhesPedido(pedido: pedido),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({
    required this.pedido,
    required this.numero,
    required this.data,
    required this.total,
    required this.onTap,
  });

  final Pedido pedido;
  final String numero;
  final String data;
  final String total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: TelaPedidosRealizados._coffeeBrown.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(
          numero,
          style: const TextStyle(
            color: TelaPedidosRealizados._coffeeBrown,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data),
              Text('Cliente/mesa: ${pedido.nomeCliente}'),
              Text('Status: ${pedido.status}'),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              total,
              style: const TextStyle(
                color: TelaPedidosRealizados._softGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
