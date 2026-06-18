import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../widgets/botao_principal.dart';
import '../widgets/campo_texto_login.dart';
import 'tela_admin_dashboard.dart';
import 'tela_cardapio_funcionario.dart';

class TelaLoginFuncionario extends StatefulWidget {
  const TelaLoginFuncionario({super.key});

  @override
  State<TelaLoginFuncionario> createState() => _TelaLoginFuncionarioState();
}

class _TelaLoginFuncionarioState extends State<TelaLoginFuncionario> {
  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaOculta = true;
  String? _erroLogin;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
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

  String? _validarSenha(String? valor) {
    if ((valor ?? '').isEmpty) {
      return 'Informe a senha';
    }

    return null;
  }

  void _entrar() {
    FocusScope.of(context).unfocus();

    setState(() {
      _erroLogin = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    final usuario = AuthService.instance.login(email: email, senha: senha);

    if (usuario != null) {
      final destino = usuario.role == UserRole.admin
          ? const TelaAdminDashboard()
          : const TelaCardapioFuncionario();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destino),
      );
      return;
    }

    setState(() {
      _erroLogin = 'E-mail ou senha inválidos';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _coffeeBrown.withValues(alpha: 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.coffee,
                      color: _coffeeBrown,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Cafeteria Interna',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _coffeeBrown,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Acesso dos funcionários',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8A725E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CampoTextoLogin(
                          controller: _emailController,
                          label: 'E-mail',
                          hint: 'Digite seu e-mail',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validarEmail,
                        ),
                        const SizedBox(height: 16),
                        CampoTextoLogin(
                          controller: _senhaController,
                          label: 'Senha',
                          hint: 'Digite sua senha',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _senhaOculta,
                          validator: _validarSenha,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _senhaOculta = !_senhaOculta;
                              });
                            },
                            icon: Icon(
                              _senhaOculta
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            tooltip: _senhaOculta
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                          ),
                        ),
                        if (_erroLogin != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _erroLogin!,
                              style: const TextStyle(
                                color: Color(0xFFB94A48),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        BotaoPrincipal(texto: 'Entrar', onPressed: _entrar),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _softGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sistema interno da cafeteria',
                        style: TextStyle(
                          color: Color(0xFF8A725E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
