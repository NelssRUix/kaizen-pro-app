import 'package:flutter/material.dart';

/// Servicio de navegación global para manejar navegación desde cualquier parte de la app
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Obtiene el contexto actual del navegador
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navega a una ruta específica
  Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  /// Navega a una ruta y limpia el stack de navegación
  Future<T?> navigateAndClearStack<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Regresa a la pantalla anterior
  void goBack<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  /// Verifica si se puede regresar
  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  /// Navega al login y limpia el stack
  Future<void> navigateToLogin() {
    return navigateAndClearStack('/login');
  }
}
