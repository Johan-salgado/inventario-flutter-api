// lib/main.dart
// Punto de entrada de la aplicacion Flutter

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router/app_router.dart';

Future<void> main() async {
  // Asegurar la inicializacion de los widgets de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar las variables de entorno desde el archivo .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Aviso: No se pudo cargar el archivo .env ($e), se usaran valores por defecto.');
  }

  runApp(const MiInventarioApp());
}

class MiInventarioApp extends StatelessWidget {
  const MiInventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestion de Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
