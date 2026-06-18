import "package:flutter/material.dart";
import 'package:workmanager/workmanager.dart';

import 'screens/tela_login_funcionario.dart';
import 'services/auth_service.dart';
import 'services/backup_scheduler_service.dart';
import 'services/pedido_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isAutomaticBackupSupported) {
    await Workmanager().initialize(backupCallbackDispatcher);
  }
  await AuthService.instance.carregarUsuarios();
  await PedidoService.instance.carregarPedidos();
  runApp(const CafeteriaApp());
}

class CafeteriaApp extends StatelessWidget {
  const CafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const softGreen = Color(0xFF6D8B74);
    const lightBeige = Color(0xFFF7EFE5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafeteria Interna',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coffeeBrown,
          primary: coffeeBrown,
          secondary: softGreen,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: lightBeige,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBeige,
          foregroundColor: coffeeBrown,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const TelaLoginFuncionario(),
    );
  }
}
