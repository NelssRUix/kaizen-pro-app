import 'package:flutter/material.dart';
import 'package:kaizen_pro/src/api/models/http_status_code.dart';
import 'package:kaizen_pro/src/services/navigation_service.dart';

/// Clase personalizada para excepciones de API
/// Implementa el principio de responsabilidad única (SRP)
class ApiException implements Exception {
  final String message;
  final HttpStatusCode statusCode;
  final String? endpoint;
  final dynamic originalError;

  const ApiException({
    required this.message,
    required this.statusCode,
    this.endpoint,
    this.originalError,
  });

  /// Factory para crear excepciones basadas en código de estado
  factory ApiException.fromStatusCode({
    required int statusCode,
    String? message,
    String? endpoint,
    dynamic originalError,
    bool autoRedirectOn401 = true,
  }) {
    final httpStatus = HttpStatusCode.fromCode(statusCode);
    final defaultMessage = _getDefaultMessage(statusCode);
    
    // Manejar redirección automática para error 401
    if (statusCode == 401 && autoRedirectOn401) {
      _handleUnauthorized();
    }
    
    return ApiException(
      message: message ?? defaultMessage,
      statusCode: httpStatus ?? HttpStatusCode.internalServerError,
      endpoint: endpoint,
      originalError: originalError,
    );
  }

  /// Maneja la redirección automática cuando el usuario no está autorizado (401)
  static void _handleUnauthorized() {
    try {
      // Usar el servicio de navegación para redirigir al login
      final navigationService = NavigationService();
      navigationService.navigateToLogin();
    } catch (e) {
      // Si no se puede navegar automáticamente, al menos loguear el error
      debugPrint('Error al redirigir automáticamente al login: $e');
    }
  }

  /// Verifica si esta excepción es un error de autorización
  bool get isUnauthorized => statusCode.code == 401;

  /// Obtiene mensaje por defecto según el código de estado
  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta. Verifique los datos enviados';
      case 401:
        return 'No autorizado. Debe iniciar sesión nuevamente';
      case 403:
        return 'Acceso denegado. No tiene permisos para esta acción';
      case 404:
        return 'Recurso no encontrado';
      case 405:
        return 'Método no permitido';
      case 409:
        return 'Conflicto. El recurso ya existe';
      case 422:
        return 'Datos no válidos. Revise la información';
      case 500:
        return 'Error interno del servidor';
      case 502:
        return 'Servidor no disponible';
      case 503:
        return 'Servicio temporalmente no disponible';
      case 504:
        return 'Tiempo de espera agotado';
      default:
        return 'Error desconocido';
    }
  }

  @override
  String toString() {
    return 'ApiException: $message (${statusCode.code})${endpoint != null ? ' - Endpoint: $endpoint' : ''}';
  }
}
