import 'package:flutter/material.dart';

import '../models/item_pedido.dart';
import '../models/produto.dart';
import '../services/auth_service.dart';
import '../services/pedido_service.dart';
import '../services/produto_service.dart';
import '../widgets/botao_principal.dart';
import '../widgets/item_pedido_card.dart';

class TelaNovoPedido extends StatefulWidget {
  const TelaNovoPedido({super.key, this.itensIniciais = const []});

  final List<ItemPedido> itensIniciais;

  @override
  State<TelaNovoPedido> createState() => _TelaNovoPedidoState();
}

class _TelaNovoPedidoState extends State<TelaNovoPedido> {
  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);
  static const _borderBeige = Color(0xFFE2D3C2);

  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _observacaoController = TextEditingController();
  late final List<ItemPedido> _itens = List<ItemPedido>.from(
    widget.itensIniciais,
  );

  bool get _veioDoCarrinho => widget.itensIniciais.isNotEmpty;

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double get _total {
    return PedidoService.instance.calcularTotal(_itens);
  }

  void _adicionarProduto(Produto produto) {
    final index = _itens.indexWhere((item) => item.produto.id == produto.id);

    setState(() {
      if (index == -1) {
        _itens.add(ItemPedido(produto: produto, quantidade: 1));
      } else {
        final itemAtual = _itens[index];
        _itens[index] = itemAtual.copyWith(
          quantidade: itemAtual.quantidade + 1,
        );
      }
    });
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

  Future<void> _salvarPedido() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto ao pedido'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await PedidoService.instance.criarPedido(
      nomeCliente: _nomeClienteController.text.trim(),
      criadoPor: AuthService.instance.nomeExibicao,
      itens: _itens,
      observacao: _observacaoController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedido registrado com sucesso'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: Text(_veioDoCarrinho ? 'Finalizar pedido' : 'Novo pedido'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            children: [
              _CampoPedido(
                controller: _nomeClienteController,
                label: 'Nome do cliente',
                validator: (valor) {
                  if ((valor ?? '').trim().isEmpty) {
                    return 'Informe o nome do cliente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _CampoPedido(
                controller: _observacaoController,
                label: 'Observação',
                maxLines: 3,
              ),
              if (!_veioDoCarrinho) ...[
                const SizedBox(height: 22),
                const Text(
                  'Produtos disponíveis',
                  style: TextStyle(
                    color: _coffeeBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: ProdutoService.instance,
                  builder: (context, _) {
                    final produtos = ProdutoService.instance
                        .listarDisponiveis();

                    if (produtos.isEmpty) {
                      return const _MensagemVazia(
                        texto: 'Nenhum produto disponível para pedido.',
                      );
                    }

                    return Column(
                      children: produtos.map((produto) {
                        return _ProdutoPedidoCard(
                          produto: produto,
                          formatarPreco: _formatarPreco,
                          onAdicionar: () => _adicionarProduto(produto),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Itens do pedido',
                      style: TextStyle(
                        color: _coffeeBrown,
                        fontSize: 20,
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
                const _MensagemVazia(texto: 'Nenhum item adicionado.')
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
                child: Row(
                  children: [
                    const Text(
                      'Total do pedido',
                      style: TextStyle(
                        color: _coffeeBrown,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
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
              ),
              const SizedBox(height: 18),
              BotaoPrincipal(
                texto: _veioDoCarrinho ? 'Finalizar pedido' : 'Salvar pedido',
                onPressed: _salvarPedido,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProdutoPedidoCard extends StatelessWidget {
  const _ProdutoPedidoCard({
    required this.produto,
    required this.formatarPreco,
    required this.onAdicionar,
  });

  final Produto produto;
  final String Function(double valor) formatarPreco;
  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(produto.icone, color: _TelaNovoPedidoState._coffeeBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    color: _TelaNovoPedidoState._coffeeBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  formatarPreco(produto.preco),
                  style: const TextStyle(
                    color: _TelaNovoPedidoState._softGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: onAdicionar,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class _CampoPedido extends StatelessWidget {
  const _CampoPedido({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _TelaNovoPedidoState._borderBeige,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _TelaNovoPedidoState._softGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _MensagemVazia extends StatelessWidget {
  const _MensagemVazia({required this.texto});

  final String texto;

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
        texto,
        style: TextStyle(
          color: _TelaNovoPedidoState._coffeeBrown.withValues(alpha: 0.65),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
