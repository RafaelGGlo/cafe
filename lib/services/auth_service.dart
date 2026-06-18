import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const _usuariosCriadosKey = 'usuarios_criados';

  final List<Usuario> _usuarios = [
    const Usuario(
      id: 'usuario-admin',
      nome: 'Admin',
      email: 'admin@gmail.com',
      role: UserRole.admin,
    ),
    const Usuario(
      id: 'usuario-rafael',
      nome: 'Rafael',
      email: 'rafael@cafeteria.com',
      role: UserRole.employee,
    ),
    const Usuario(
      id: 'usuario-funcionario',
      nome: 'Usuário',
      email: 'funcionario@gmail.com',
      role: UserRole.employee,
    ),
  ];

  final Map<String, String> _senhas = {
    'admin@gmail.com': 'admin',
    'rafael@cafeteria.com': 'funcionario',
    'funcionario@gmail.com': 'funcionario',
  };

  Usuario? _usuarioAtual;
  bool _usuariosCarregados = false;

  Usuario? get usuarioAtual => _usuarioAtual;

  String get nomeExibicao {
    final usuario = _usuarioAtual;
    if (usuario == null || usuario.nome.trim().isEmpty) {
      return 'Usuário';
    }
    if (usuario.isAdmin) {
      return 'Admin';
    }
    return usuario.nome.trim();
  }

  Future<void> carregarUsuarios() async {
    if (_usuariosCarregados) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final usuariosJson = preferences.getString(_usuariosCriadosKey);

    if (usuariosJson != null && usuariosJson.isNotEmpty) {
      final usuariosSalvos = jsonDecode(usuariosJson) as List<dynamic>;
      for (final usuarioMap in usuariosSalvos.cast<Map<String, dynamic>>()) {
        final usuario = Usuario(
          id: usuarioMap['id'] as String,
          nome: usuarioMap['nome'] as String,
          email: usuarioMap['email'] as String,
          role: UserRole.employee,
        );
        final email = usuario.email.toLowerCase();
        if (!_senhas.containsKey(email)) {
          _usuarios.add(usuario);
          _senhas[email] = usuarioMap['senha'] as String;
        }
      }
    }

    _usuariosCarregados = true;
  }

  List<Usuario> listarUsuarios() {
    return List.unmodifiable(_usuarios);
  }

  Usuario? login({required String email, required String senha}) {
    final emailNormalizado = email.trim().toLowerCase();

    if (_senhas[emailNormalizado] != senha) {
      return null;
    }

    final usuario = _usuarios.firstWhere(
      (usuario) => usuario.email.toLowerCase() == emailNormalizado,
    );
    return _definirUsuario(usuario);
  }

  Future<Usuario> criarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();

    if (_senhas.containsKey(emailNormalizado)) {
      throw ArgumentError('Este e-mail já está cadastrado.');
    }

    final usuario = Usuario(
      id: 'usuario-criado-${DateTime.now().microsecondsSinceEpoch}',
      nome: nome.trim().isEmpty ? 'Usuário' : nome.trim(),
      email: emailNormalizado,
      role: UserRole.employee,
    );

    _usuarios.add(usuario);
    _senhas[emailNormalizado] = senha;
    await _salvarUsuariosCriados();
    notifyListeners();
    return usuario;
  }

  Future<void> _salvarUsuariosCriados() async {
    final usuariosCriados = _usuarios
        .where((usuario) => usuario.id.startsWith('usuario-criado-'))
        .map(
          (usuario) => {
            'id': usuario.id,
            'nome': usuario.nome,
            'email': usuario.email,
            'senha': _senhas[usuario.email.toLowerCase()] ?? '',
          },
        )
        .toList();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _usuariosCriadosKey,
      jsonEncode(usuariosCriados),
    );
  }

  Usuario _definirUsuario(Usuario usuario) {
    _usuarioAtual = usuario;
    notifyListeners();
    return usuario;
  }

  void logout() {
    _usuarioAtual = null;
    notifyListeners();
  }
}
