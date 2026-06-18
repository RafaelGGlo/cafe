import 'package:flutter/material.dart';

import '../models/produto.dart';
import 'botao_principal.dart';

class ProdutoForm extends StatefulWidget {
  const ProdutoForm({
    super.key,
    this.produto,
    required this.textoBotao,
    required this.onSalvar,
  });

  final Produto? produto;
  final String textoBotao;
  final void Function({
    required String nome,
    required String descricao,
    required String categoria,
    required double preco,
    required bool disponivel,
  })
  onSalvar;

  @override
  State<ProdutoForm> createState() => _ProdutoFormState();
}

class _ProdutoFormState extends State<ProdutoForm> {
  static const _coffeeBrown = Color(0xFF5B3924);
  static const _softGreen = Color(0xFF6D8B74);
  static const _borderBeige = Color(0xFFE2D3C2);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _precoController;
  late bool _disponivel;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    _nomeController = TextEditingController(text: produto?.nome ?? '');
    _descricaoController = TextEditingController(
      text: produto?.descricao ?? '',
    );
    _categoriaController = TextEditingController(
      text: produto?.categoria ?? '',
    );
    _precoController = TextEditingController(
      text: produto == null
          ? ''
          : produto.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
    _disponivel = produto?.disponivel ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  String? _validarNome(String? valor) {
    if ((valor ?? '').trim().isEmpty) {
      return 'Informe o nome do produto';
    }
    return null;
  }

  String? _validarCategoria(String? valor) {
    if ((valor ?? '').trim().isEmpty) {
      return 'Informe a categoria';
    }
    return null;
  }

  String? _validarPreco(String? valor) {
    final preco = double.tryParse((valor ?? '').replaceAll(',', '.'));
    if (preco == null || preco <= 0) {
      return 'Informe um preço válido';
    }
    return null;
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSalvar(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaController.text.trim(),
      preco: double.parse(_precoController.text.trim().replaceAll(',', '.')),
      disponivel: _disponivel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampoProduto(
            controller: _nomeController,
            label: 'Nome do produto',
            validator: _validarNome,
          ),
          const SizedBox(height: 14),
          _CampoProduto(
            controller: _descricaoController,
            label: 'Descrição',
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          _CampoProduto(
            controller: _categoriaController,
            label: 'Categoria',
            validator: _validarCategoria,
          ),
          const SizedBox(height: 14),
          _CampoProduto(
            controller: _precoController,
            label: 'Preço',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validarPreco,
          ),
          const SizedBox(height: 18),
          const Text(
            'Disponibilidade',
            style: TextStyle(color: _coffeeBrown, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Disponível'),
                icon: Icon(Icons.check_circle_outline),
              ),
              ButtonSegment(
                value: false,
                label: Text('Indisponível'),
                icon: Icon(Icons.pause_circle_outline),
              ),
            ],
            selected: {_disponivel},
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: _softGreen,
              selectedForegroundColor: Colors.white,
              foregroundColor: _coffeeBrown,
              side: const BorderSide(color: _borderBeige),
            ),
            onSelectionChanged: (selecionado) {
              setState(() {
                _disponivel = selecionado.first;
              });
            },
          ),
          const SizedBox(height: 24),
          BotaoPrincipal(texto: widget.textoBotao, onPressed: _salvar),
        ],
      ),
    );
  }
}

class _CampoProduto extends StatelessWidget {
  const _CampoProduto({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const borderBeige = Color(0xFFE2D3C2);
    const softGreen = Color(0xFF6D8B74);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: coffeeBrown),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: softGreen, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB94A48)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB94A48), width: 1.4),
        ),
      ),
    );
  }
}
