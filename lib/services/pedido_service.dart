import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pedidos_mock.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../models/produto.dart';

class PedidoService extends ChangeNotifier {
  PedidoService._();

  static final PedidoService instance = PedidoService._();
  static const _pedidosKey = 'pedidos_salvos';

  final List<Pedido> _pedidos = List<Pedido>.from(pedidosMock);
  int _proximoNumero = pedidosMock.length + 1;
  bool _pedidosCarregados = false;

  Future<void> carregarPedidos() async {
    if (_pedidosCarregados) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final pedidosJson = preferences.getString(_pedidosKey);

    if (pedidosJson != null && pedidosJson.isNotEmpty) {
      final pedidosSalvos = jsonDecode(pedidosJson) as List<dynamic>;
      _pedidos
        ..clear()
        ..addAll(
          pedidosSalvos.cast<Map<String, dynamic>>().map(_pedidoFromMap),
        );
    }

    if (_pedidos.isNotEmpty) {
      _proximoNumero =
          _pedidos
              .map((pedido) => pedido.numero)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    _pedidosCarregados = true;
  }

  List<Pedido> listarPedidos() {
    return List.unmodifiable(_pedidos);
  }

  double calcularTotal(List<ItemPedido> itens) {
    return itens.fold(0, (total, item) => total + item.subtotal);
  }

  Future<Pedido> criarPedido({
    required String nomeCliente,
    required String criadoPor,
    required List<ItemPedido> itens,
    required String observacao,
  }) async {
    final pedido = Pedido(
      id: 'pedido-${DateTime.now().microsecondsSinceEpoch}',
      numero: _proximoNumero++,
      nomeCliente: nomeCliente,
      criadoPor: criadoPor,
      itens: List.unmodifiable(itens),
      observacao: observacao,
      total: calcularTotal(itens),
      status: 'Em preparo',
      dataCriacao: DateTime.now(),
    );

    _pedidos.add(pedido);
    await _salvarPedidos();
    notifyListeners();
    return pedido;
  }

  List<Pedido> listarPedidosDeHoje() {
    final hoje = DateTime.now();
    return _pedidos.where((pedido) {
      final data = pedido.dataCriacao;
      return data.year == hoje.year &&
          data.month == hoje.month &&
          data.day == hoje.day;
    }).toList();
  }

  Future<void> _salvarPedidos() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _pedidosKey,
      jsonEncode(_pedidos.map(_pedidoToMap).toList()),
    );
  }

  Map<String, dynamic> _pedidoToMap(Pedido pedido) {
    return {
      'id': pedido.id,
      'numero': pedido.numero,
      'nomeCliente': pedido.nomeCliente,
      'criadoPor': pedido.criadoPor,
      'observacao': pedido.observacao,
      'total': pedido.total,
      'status': pedido.status,
      'dataCriacao': pedido.dataCriacao.toIso8601String(),
      'itens': pedido.itens.map(_itemToMap).toList(),
    };
  }

  Map<String, dynamic> _itemToMap(ItemPedido item) {
    final produto = item.produto;
    return {
      'quantidade': item.quantidade,
      'produto': {
        'id': produto.id,
        'nome': produto.nome,
        'descricao': produto.descricao,
        'categoria': produto.categoria,
        'preco': produto.preco,
        'disponivel': produto.disponivel,
        'icone': produto.icone.codePoint,
      },
    };
  }

  Pedido _pedidoFromMap(Map<String, dynamic> map) {
    final itens = (map['itens'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_itemFromMap)
        .toList();

    return Pedido(
      id: map['id'] as String,
      numero: map['numero'] as int,
      nomeCliente: map['nomeCliente'] as String,
      criadoPor: map['criadoPor'] as String,
      itens: List.unmodifiable(itens),
      observacao: map['observacao'] as String,
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
    );
  }

  ItemPedido _itemFromMap(Map<String, dynamic> map) {
    final produtoMap = map['produto'] as Map<String, dynamic>;
    final produtoIcon = IconData(
      produtoMap['icone'] as int,
      fontFamily: 'MaterialIcons',
    );

    return ItemPedido(
      quantidade: map['quantidade'] as int,
      produto: Produto(
        id: produtoMap['id'] as String,
        nome: produtoMap['nome'] as String,
        descricao: produtoMap['descricao'] as String,
        categoria: produtoMap['categoria'] as String,
        preco: (produtoMap['preco'] as num).toDouble(),
        disponivel: produtoMap['disponivel'] as bool,
        icone: produtoIcon,
      ),
    );
  }
}
