import 'package:flutter/material.dart';

class Produto {
  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.preco,
    required this.disponivel,
    required this.icone,
  });

  final String id;
  final String nome;
  final String descricao;
  final String categoria;
  final double preco;
  final bool disponivel;
  final IconData icone;

  Produto copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? categoria,
    double? preco,
    bool? disponivel,
    IconData? icone,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      preco: preco ?? this.preco,
      disponivel: disponivel ?? this.disponivel,
      icone: icone ?? this.icone,
    );
  }
}
