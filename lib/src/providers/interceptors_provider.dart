import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaizen_pro/src/api/interceptors/http_response_interceptor.dart';
import 'package:kaizen_pro/src/api/interceptors/interfaces/i_response_interceptor.dart';


/// Provider para el interceptor de respuestas HTTP
/// Implementa el principio de inversión de dependencias (DIP)
final responseInterceptorProvider = Provider<IResponseInterceptor>((ref) {
  return HttpResponseInterceptor();
});

/// Provider para la lista de interceptores personalizados
/// Permite agregar más interceptores fácilmente (Principio abierto/cerrado)
final interceptorsProvider = Provider<List<IResponseInterceptor>>((ref) {
  return [
    ref.read(responseInterceptorProvider),
  ];
});
