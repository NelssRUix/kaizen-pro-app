import 'package:dio/dio.dart';

/// Interface para interceptores de respuesta HTTP
/// Implementa el principio de responsabilidad única (SRP)
abstract class IResponseInterceptor {
  /// Procesa la respuesta exitosa
  void onResponse(Response response, ResponseInterceptorHandler handler);
  
  /// Maneja errores de respuesta
  void onError(DioException err, ErrorInterceptorHandler handler);
}
