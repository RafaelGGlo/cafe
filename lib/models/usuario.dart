enum UserRole { admin, employee }

class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
  });

  final String id;
  final String nome;
  final String email;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
}
