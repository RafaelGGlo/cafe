import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';

class TelaUsuarios extends StatefulWidget {
  const TelaUsuarios({super.key});

  @override
  State<TelaUsuarios> createState() => _TelaUsuariosState();
}

class _TelaUsuariosState extends State<TelaUsuarios> {
  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);
  static const _borderBeige = Color(0xFFE2D3C2);

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String? _validarObrigatorio(String? valor) {
    if ((valor ?? '').trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) {
      return 'Informe o e-mail';
    }
    final emailValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailValido) {
      return 'E-mail inválido';
    }
    return null;
  }

  Future<void> _criarUsuario() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      await AuthService.instance.criarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      );

      if (!mounted) {
        return;
      }

      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário criado com acesso ao fluxo de pedidos.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Invalid argument(s): ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Usuários'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: AuthService.instance,
          builder: (context, _) {
            final usuarios = AuthService.instance.listarUsuarios();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderBeige),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Criar funcionário',
                          style: TextStyle(
                            color: _coffeeBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CampoUsuario(
                          controller: _nomeController,
                          label: 'Nome',
                          validator: _validarObrigatorio,
                        ),
                        const SizedBox(height: 12),
                        _CampoUsuario(
                          controller: _emailController,
                          label: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validarEmail,
                        ),
                        const SizedBox(height: 12),
                        _CampoUsuario(
                          controller: _senhaController,
                          label: 'Senha',
                          obscureText: true,
                          validator: _validarObrigatorio,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _criarUsuario,
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Criar usuário'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _coffeeBrown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Usuários cadastrados',
                  style: TextStyle(
                    color: _coffeeBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ...usuarios.map((usuario) => _UsuarioCard(usuario: usuario)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CampoUsuario extends StatelessWidget {
  const _CampoUsuario({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _TelaUsuariosState._borderBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _TelaUsuariosState._softGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  const _UsuarioCard({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final roleLabel = usuario.role == UserRole.admin ? 'Admin' : 'Funcionário';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _TelaUsuariosState._softGreen,
            child: Text(
              usuario.nome.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nome,
                  style: const TextStyle(
                    color: _TelaUsuariosState._coffeeBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  usuario.email,
                  style: TextStyle(
                    color: _TelaUsuariosState._coffeeBrown.withValues(
                      alpha: 0.65,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            roleLabel,
            style: const TextStyle(
              color: _TelaUsuariosState._softGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
