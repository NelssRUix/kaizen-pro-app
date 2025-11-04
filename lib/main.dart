import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kaizen_pro/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura inicialización antes de correr la app

  // Bloquear orientación a modo retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Asegúrate de cargar dotenv antes de ejecutar la aplicación
  await dotenv.load(fileName: ".env");
  runApp(
    ProviderScope(
      // Permite usar Riverpod en toda la app
      child: MyApp(),
    ),
  );
}
