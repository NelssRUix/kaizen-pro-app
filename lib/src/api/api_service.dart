import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_interface.dart';
import 'interceptors/http_response_interceptor.dart';

class Api implements ApiInterface {
  Api(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  Dio? _mophraApi;
  String? _cachedJwt;

  static const _jwtKey = 'jwt';

  @override
  Dio get client {
    if (_mophraApi == null) {
      throw Exception("El cliente API no ha sido inicializado. Llama a initialize() primero.");
    }
    return _mophraApi!;
  }

  @override
  Future<void> initialize() async {
  if (_mophraApi != null) return;

    await dotenv.load();

    final String baseUrl = dotenv.env['API_URL'] ?? '';
    final String secretKey = dotenv.env['SECRET_KEY'] ?? '';

    _mophraApi = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'api-key': secretKey,
        },
      ),
    );

    // Cache the jwt token once to avoid a platform-channel read for every request,
    // which can be slow on some devices.
    try {
      _cachedJwt = await _secureStorage.read(key: _jwtKey);
    } catch (_) {
      _cachedJwt = null;
    }

    // Authentication interceptor: uses cached token when available. If cache is empty,
    // it will attempt a read once (fallback) and cache it.
    _mophraApi!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? jwt = _cachedJwt;
          if (jwt == null) {
            try {
              jwt = await _secureStorage.read(key: _jwtKey);
              _cachedJwt = jwt;
            } catch (_) {
              jwt = null;
            }
          }

          if (jwt != null && jwt.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $jwt';
          }

          return handler.next(options);
        },
      ),
    );

    // Agregar interceptor de respuestas HTTP (manejo de errores y códigos de estado)
    _mophraApi!.interceptors.add(HttpResponseInterceptor());
  }

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return client.get(path, queryParameters: queryParameters);
  }

  @override
  Future<Response> post(String path, {dynamic data}) {
    return client.post(path, data: data);
  }

  @override
  Future<Response> put(String path, {dynamic data}) {
    return client.put(path, data: data);
  }

  @override
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) {
    return client.delete(path, queryParameters: queryParameters);
  }
}
