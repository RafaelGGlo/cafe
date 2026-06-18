import 'package:flutter/material.dart';

import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import 'tela_detalhes_pedido.dart';

class TelaRelatorioDia extends StatelessWidget {
  const TelaRelatorioDia({super.key});

  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _numeroPedido(Pedido pedido) {
    return 'Pedido #${pedido.numero.toString().padLeft(3, '0')}';
  }

  Map<String, int> _produtosMaisVendidos(List<Pedido> pedidos) {
    final totais = <String, int>{};
    for (final pedido in pedidos) {
      for (final ItemPedido item in pedido.itens) {
        totais[item.produto.nome] =
            (totais[item.produto.nome] ?? 0) + item.quantidade;
      }
    }
    final entradas = totais.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entradas.take(5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Relatório do dia'),
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
            final pedidosHoje = PedidoService.instance.listarPedidosDeHoje();
            final receita = pedidosHoje.fold<double>(
              0,
              (total, pedido) => total + pedido.total,
            );
            final emPreparo = pedidosHoje
                .where((pedido) => pedido.status == 'Em preparo')
                .length;
            final concluidos = pedidosHoje
                .where((pedido) => pedido.status == 'Concluído')
                .length;
            final cancelados = pedidosHoje
                .where((pedido) => pedido.status == 'Cancelado')
                .length;
            final produtos = _produtosMaisVendidos(pedidosHoje);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ResumoCard(
                      label: 'Pedidos hoje',
                      valor: '${pedidosHoje.length}',
                    ),
                    _ResumoCard(
                      label: 'Receita hoje',
                      valor: _formatarPreco(receita),
                    ),
                    _ResumoCard(label: 'Em preparo', valor: '$emPreparo'),
                    _ResumoCard(label: 'Concluídos', valor: '$concluidos'),
                    _ResumoCard(label: 'Cancelados', valor: '$cancelados'),
                  ],
                ),
                const SizedBox(height: 22),
                const _TituloSecao('Produtos mais vendidos'),
                const SizedBox(height: 12),
                if (produtos.isEmpty)
                  const _MensagemVazia('Nenhum produto vendido hoje.')
                else
                  ...produtos.entries.map(
                    (produto) => _LinhaProduto(
                      nome: produto.key,
                      quantidade: produto.value,
                    ),
                  ),
                const SizedBox(height: 22),
                const _TituloSecao('Pedidos recentes'),
                const SizedBox(height: 12),
                if (pedidosHoje.isEmpty)
                  const _MensagemVazia('Nenhum pedido realizado hoje.')
                else
                  ...pedidosHoje.reversed.take(5).map((pedido) {
                    return _PedidoRecente(
                      pedido: pedido,
                      numero: _numeroPedido(pedido),
                      total: _formatarPreco(pedido.total),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: TelaRelatorioDia._coffeeBrown.withValues(alpha: 0.65),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                color: TelaRelatorioDia._softGreen,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: TelaRelatorioDia._coffeeBrown,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _MensagemVazia extends StatelessWidget {
  const _MensagemVazia(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto),
    );
  }
}

class _LinhaProduto extends StatelessWidget {
  const _LinhaProduto({required this.nome, required this.quantidade});

  final String nome;
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(nome)),
          Text(
            '$quantidade vendidos',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PedidoRecente extends StatelessWidget {
  const _PedidoRecente({
    required this.pedido,
    required this.numero,
    required this.total,
  });

  final Pedido pedido;
  final String numero;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhesPedido(pedido: pedido),
            ),
          );
        },
        title: Text(numero),
        subtitle: Text('${pedido.nomeCliente} • ${pedido.status}'),
        trailing: Text(total),
      ),
    );
  }
}
