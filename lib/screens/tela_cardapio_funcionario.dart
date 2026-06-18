import 'package:flutter/material.dart';

import '../models/item_pedido.dart';
import '../models/produto.dart';
import '../screens/tela_gerenciar_produtos.dart';
import '../screens/tela_login_funcionario.dart';
import '../screens/tela_novo_pedido.dart';
import '../screens/tela_pedidos_realizados.dart';
import '../screens/tela_ver_pedido.dart';
import '../services/auth_service.dart';
import '../services/produto_service.dart';
import '../widgets/categoria_button.dart';
import '../widgets/produto_card.dart';
import '../widgets/resumo_pedido_bar.dart';

class TelaCardapioFuncionario extends StatefulWidget {
  const TelaCardapioFuncionario({super.key});

  @override
  State<TelaCardapioFuncionario> createState() =>
      _TelaCardapioFuncionarioState();
}

class _TelaCardapioFuncionarioState extends State<TelaCardapioFuncionario> {
  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);
  static const _borderBeige = Color(0xFFE2D3C2);

  final List<String> _categorias = const [
    'Todos',
    'Cafés',
    'Salgados',
    'Doces',
    'Bebidas',
  ];

  String _categoriaSelecionada = 'Todos';
  String _busca = '';
  final List<ItemPedido> _pedidoAtual = [];

  List<Produto> _produtosFiltrados(List<Produto> produtos) {
    final termo = _busca.trim().toLowerCase();

    return produtos.where((produto) {
      final correspondeCategoria =
          _categoriaSelecionada == 'Todos' ||
          produto.categoria == _categoriaSelecionada;
      final correspondeBusca = produto.nome.toLowerCase().contains(termo);

      return correspondeCategoria && correspondeBusca;
    }).toList();
  }

  int get _quantidadeItens {
    return _pedidoAtual.fold(0, (total, item) => total + item.quantidade);
  }

  double get _totalPedido {
    return _pedidoAtual.fold(0, (total, item) => total + item.subtotal);
  }

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _adicionarProduto(Produto produto) {
    final index = _pedidoAtual.indexWhere(
      (item) => item.produto.id == produto.id,
    );

    setState(() {
      if (index == -1) {
        _pedidoAtual.add(ItemPedido(produto: produto, quantidade: 1));
      } else {
        final itemAtual = _pedidoAtual[index];
        _pedidoAtual[index] = itemAtual.copyWith(
          quantidade: itemAtual.quantidade + 1,
        );
      }
    });
  }

  Future<void> _verPedido() async {
    final itensAtualizados = await Navigator.push<List<ItemPedido>>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaVerPedido(itens: _pedidoAtual),
      ),
    );

    if (itensAtualizados == null || !mounted) {
      return;
    }

    setState(() {
      _pedidoAtual
        ..clear()
        ..addAll(itensAtualizados);
    });
  }

  void _abrirNovoPedido() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaNovoPedido()),
    );
  }

  void _abrirGerenciamentoProdutos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaGerenciarProdutos()),
    );
  }

  void _abrirPedidosRealizados() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaPedidosRealizados()),
    );
  }

  void _sair() {
    AuthService.instance.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaLoginFuncionario()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.instance.usuarioAtual?.isAdmin == true;
    final bottomPadding = _quantidadeItens > 0 ? 92.0 : 18.0;

    return Scaffold(
      backgroundColor: _lightBeige,
      bottomNavigationBar: NavigationBar(
        selectedIndex: isAdmin ? 2 : 1,
        onDestinationSelected: (index) {
          if (!isAdmin) {
            if (index == 0) {
              _abrirPedidosRealizados();
            }
            return;
          }

          if (index == 0 && Navigator.canPop(context)) {
            Navigator.pop(context);
            return;
          }

          if (index == 1) {
            _abrirPedidosRealizados();
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: _softGreen.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: isAdmin
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Pedidos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Cardápio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more),
                  label: 'Mais',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Pedidos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Cardápio',
                ),
              ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: AnimatedBuilder(
              animation: ProdutoService.instance,
              builder: (context, _) {
                final produtosFiltrados = _produtosFiltrados(
                  ProdutoService.instance.listarDisponiveis(),
                );

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Header(
                              onGerenciarProdutos: isAdmin
                                  ? _abrirGerenciamentoProdutos
                                  : null,
                              onSair: isAdmin ? null : _sair,
                              onVoltarAdmin:
                                  isAdmin && Navigator.canPop(context)
                                  ? () => Navigator.pop(context)
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _abrirNovoPedido,
                                    icon: const Icon(Icons.add_shopping_cart),
                                    label: const Text('Novo pedido'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _coffeeBrown,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _abrirGerenciamentoProdutos,
                                      icon: const Icon(
                                        Icons.inventory_2_outlined,
                                      ),
                                      label: const Text('Produtos'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _coffeeBrown,
                                        side: const BorderSide(
                                          color: _borderBeige,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            _SearchBar(
                              onChanged: (valor) {
                                setState(() {
                                  _busca = valor;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 48,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _categorias.map((categoria) {
                                  return CategoriaButton(
                                    label: categoria,
                                    selecionada:
                                        categoria == _categoriaSelecionada,
                                    onTap: () {
                                      setState(() {
                                        _categoriaSelecionada = categoria;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Cardápio',
                              style: TextStyle(
                                color: _coffeeBrown,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    if (produtosFiltrados.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Nenhum produto disponível encontrado.',
                            style: TextStyle(
                              color: _coffeeBrown.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                        sliver: SliverList.builder(
                          itemCount: produtosFiltrados.length,
                          itemBuilder: (context, index) {
                            final produto = produtosFiltrados[index];
                            return ProdutoCard(
                              produto: produto,
                              formatarPreco: _formatarPreco,
                              onAdicionar: () => _adicionarProduto(produto),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ResumoPedidoBar(
              quantidadeItens: _quantidadeItens,
              total: _totalPedido,
              formatarPreco: _formatarPreco,
              onVerPedido: _verPedido,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onGerenciarProdutos,
    this.onSair,
    this.onVoltarAdmin,
  });

  final VoidCallback? onGerenciarProdutos;
  final VoidCallback? onSair;
  final VoidCallback? onVoltarAdmin;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onVoltarAdmin != null || onGerenciarProdutos != null) ...[
          _IconAction(
            icon: onVoltarAdmin == null ? Icons.menu : Icons.arrow_back,
            tooltip: onVoltarAdmin == null
                ? 'Gerenciar produtos'
                : 'Voltar para admin',
            onPressed: onVoltarAdmin ?? onGerenciarProdutos!,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${AuthService.instance.nomeExibicao}! 👋',
                style: const TextStyle(
                  color: _TelaCardapioFuncionarioState._coffeeBrown,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Vamos registrar um novo pedido?',
                style: TextStyle(
                  color: Color(0xFF8A725E),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 22,
          backgroundColor: _TelaCardapioFuncionarioState._softGreen,
          child: Text(
            AuthService.instance.nomeExibicao.characters.first.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (onSair != null) ...[
          const SizedBox(width: 8),
          _IconAction(icon: Icons.logout, tooltip: 'Sair', onPressed: onSair!),
        ],
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: _TelaCardapioFuncionarioState._coffeeBrown,
        tooltip: tooltip,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar produtos...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _TelaCardapioFuncionarioState._borderBeige,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _TelaCardapioFuncionarioState._softGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
