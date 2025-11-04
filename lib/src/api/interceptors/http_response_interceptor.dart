import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaizen_pro/src/api/exceptions/api_exception.dart';
import 'package:kaizen_pro/src/api/interceptors/interfaces/i_response_interceptor.dart';
import 'package:kaizen_pro/src/api/models/http_status_code.dart';
import 'package:kaizen_pro/src/services/navigation_service.dart';


class HttpResponseInterceptor extends Interceptor implements IResponseInterceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode ?? 0;
    final httpStatus = HttpStatusCode.fromCode(statusCode);

    // Procesar respuestas exitosas (2xx)
    if (httpStatus?.isSuccess ?? false) {
      _handleSuccessResponse(response, handler);
      return;
    }

    // Si no es exitosa, convertir a error
    final apiException = ApiException.fromStatusCode(
      statusCode: statusCode,
      endpoint: response.requestOptions.uri.toString(),
      originalError: response.data,
    );

    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiException,
        type: DioExceptionType.badResponse,
      ),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Procesar diferentes tipos de errores
    final apiException = _createApiExceptionFromError(err);
    
    // Crear nuevo DioException con ApiException personalizada
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      error: apiException,
      type: err.type,
    );

    handler.next(customError);
  }

  /// Maneja respuestas exitosas
  void _handleSuccessResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Crea ApiException personalizada desde DioException
  ApiException _createApiExceptionFromError(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final endpoint = err.requestOptions.uri.toString();
    
    // Intentar extraer mensaje del backend
    String? backendMessage;
    if (err.response?.data is Map<String, dynamic>) {
      final data = err.response!.data as Map<String, dynamic>;
      backendMessage = data['message'] ?? data['error'] ?? data['msg'];
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Tiempo de conexión agotado',
          statusCode: HttpStatusCode.gatewayTimeout,
          endpoint: endpoint,
          originalError: err,
        );
      
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Tiempo de envío agotado',
          statusCode: HttpStatusCode.gatewayTimeout,
          endpoint: endpoint,
          originalError: err,
        );
      
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Tiempo de respuesta agotado',
          statusCode: HttpStatusCode.gatewayTimeout,
          endpoint: endpoint,
          originalError: err,
        );
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(statusCode, backendMessage, endpoint, err);
      
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Solicitud cancelada',
          statusCode: HttpStatusCode.badRequest,
          endpoint: endpoint,
          originalError: err,
        );
      
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Error de conexión. Verifique su conexión a internet',
          statusCode: HttpStatusCode.serviceUnavailable,
          endpoint: endpoint,
          originalError: err,
        );
      
      default:
        return ApiException(
          message: backendMessage ?? 'Error desconocido',
          statusCode: HttpStatusCode.internalServerError,
          endpoint: endpoint,
          originalError: err,
        );
    }
  }

  /// Maneja errores de respuesta HTTP específicos
  ApiException _handleBadResponse(int statusCode, String? backendMessage, String endpoint, DioException err) {
    switch (statusCode) {
      case 400:
        return ApiException(
          message: backendMessage ?? 'Datos inválidos. Verifique la información ingresada',
          statusCode: HttpStatusCode.badRequest,
          endpoint: endpoint,
          originalError: err,
        );
      
      case 401:
        // Si llega un 401, forzamos logout: borrar token e ir a login.
        try {
          const storage = FlutterSecureStorage();
          // Eliminar el token almacenado
          storage.delete(key: 'jwt');
          // Navegar al login en la siguiente microtarea para no interferir con el flujo del interceptor
          Future.microtask(() => NavigationService().navigateToLogin());
        } catch (_) {}

        return ApiException(
          message: backendMessage ?? 'Sesión expirada. Debe iniciar sesión nuevamente',
          statusCode: HttpStatusCode.unauthorized,
          endpoint: endpoint,
          originalError: err,
        );
      
      case 403:
        return ApiException(
          message: backendMessage ?? 'Acceso denegado. No tiene permisos para esta acción',
          statusCode: HttpStatusCode.forbidden,
          endpoint: endpoint,
          originalError: err,
        );
      
      case 404:
        return ApiException(
          message: backendMessage ?? 'Recurso no encontrado. Verifique los datos ingresados',
          statusCode: HttpStatusCode.notFound,
          endpoint: endpoint,
          originalError: err,
        );
      
      case 500:
        return ApiException(
          message: backendMessage ?? 'Error interno del servidor. Intente nuevamente',
          statusCode: HttpStatusCode.internalServerError,
          endpoint: endpoint,
          originalError: err,
        );
      
      default:
        return ApiException.fromStatusCode(
          statusCode: statusCode,
          message: backendMessage,
          endpoint: endpoint,
          originalError: err,
        );
    }
  }
}
