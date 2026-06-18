import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/pedido_service.dart';
import '../services/produto_service.dart';
import 'tela_cardapio_funcionario.dart';
import 'tela_gerenciar_produtos.dart';
import 'tela_login_funcionario.dart';
import 'tela_pedidos_realizados.dart';
import 'tela_relatorio_dia.dart';
import 'tela_usuarios.dart';

class TelaAdminDashboard extends StatelessWidget {
  const TelaAdminDashboard({super.key});

  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);
  static const _borderBeige = Color(0xFFE2D3C2);

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _sair(BuildContext context) {
    AuthService.instance.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaLoginFuncionario()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            PedidoService.instance,
            ProdutoService.instance,
            AuthService.instance,
          ]),
          builder: (context, _) {
            final pedidosHoje = PedidoService.instance.listarPedidosDeHoje();
            final totalVendido = pedidosHoje.fold<double>(
              0,
              (total, pedido) => total + pedido.total,
            );
            final emPreparo = pedidosHoje
                .where((pedido) => pedido.status == 'Em preparo')
                .length;
            final produtosAtivos = ProdutoService.instance
                .listarDisponiveis()
                .length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Olá, ${AuthService.instance.nomeExibicao}! 👋',
                        style: const TextStyle(
                          color: _coffeeBrown,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _sair(context),
                      icon: const Icon(Icons.logout),
                      color: _coffeeBrown,
                      tooltip: 'Sair',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Resumo da cafeteria hoje',
                  style: TextStyle(
                    color: Color(0xFF8A725E),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      label: 'Total vendido',
                      value: _formatarPreco(totalVendido),
                    ),
                    _MetricCard(
                      label: 'Pedidos do dia',
                      value: '${pedidosHoje.length}',
                    ),
                    _MetricCard(label: 'Em preparo', value: '$emPreparo'),
                    _MetricCard(
                      label: 'Produtos ativos',
                      value: '$produtosAtivos',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Acesso rápido',
                  style: TextStyle(
                    color: _coffeeBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickAction(
                  icon: Icons.insights,
                  label: 'Relatório do dia',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaRelatorioDia(),
                      ),
                    );
                  },
                ),
                _QuickAction(
                  icon: Icons.receipt_long,
                  label: 'Pedidos realizados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaPedidosRealizados(),
                      ),
                    );
                  },
                ),
                _QuickAction(
                  icon: Icons.inventory_2_outlined,
                  label: 'Cardápio/Produtos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaGerenciarProdutos(),
                      ),
                    );
                  },
                ),
                _QuickAction(
                  icon: Icons.restaurant_menu,
                  label: 'Fluxo de pedidos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaCardapioFuncionario(),
                      ),
                    );
                  },
                ),
                _QuickAction(
                  icon: Icons.group_outlined,
                  label: 'Usuários',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaUsuarios(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TelaAdminDashboard._borderBeige),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: TelaAdminDashboard._coffeeBrown.withValues(alpha: 0.65),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: TelaAdminDashboard._softGreen,
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: TelaAdminDashboard._coffeeBrown),
        title: Text(
          label,
          style: const TextStyle(
            color: TelaAdminDashboard._coffeeBrown,
            fontWeight: FontWeight.w900,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
