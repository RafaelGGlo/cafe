import 'package:flutter/material.dart';

import '../models/produto.dart';

final List<Produto> produtosMock = [
  Produto(
    id: 'produto-1',
    nome: 'Café Espresso',
    descricao: 'Dose intensa com crema aveludada e aroma marcante.',
    categoria: 'Cafés',
    preco: 6.50,
    disponivel: true,
    icone: Icons.coffee,
  ),
  Produto(
    id: 'produto-2',
    nome: 'Cappuccino',
    descricao: 'Espresso, leite vaporizado e espuma cremosa com cacau.',
    categoria: 'Cafés',
    preco: 9.50,
    disponivel: true,
    icone: Icons.local_cafe,
  ),
  Produto(
    id: 'produto-3',
    nome: 'Pão de Queijo',
    descricao: 'Porção quentinha, macia por dentro e dourada por fora.',
    categoria: 'Salgados',
    preco: 6.00,
    disponivel: true,
    icone: Icons.bakery_dining,
  ),
  Produto(
    id: 'produto-4',
    nome: 'Bolo de Chocolate',
    descricao: 'Fatia úmida com cobertura cremosa de chocolate.',
    categoria: 'Doces',
    preco: 8.50,
    disponivel: true,
    icone: Icons.cake,
  ),
  Produto(
    id: 'produto-5',
    nome: 'Suco Natural',
    descricao: 'Suco fresco preparado na hora com frutas selecionadas.',
    categoria: 'Bebidas',
    preco: 7.00,
    disponivel: true,
    icone: Icons.local_drink,
  ),
];
