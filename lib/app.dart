import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaizen_pro/src/routes/app_routes.dart';
import 'package:kaizen_pro/src/services/navigation_service.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey, 
      debugShowCheckedModeBanner: false,
      title: 'Mophra App',
      theme: ThemeData.light(), // Forzar tema claro
      darkTheme: ThemeData.light(), // Ignorar el tema oscuro
      themeMode: ThemeMode.light, // Siempre usar el tema claro
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}