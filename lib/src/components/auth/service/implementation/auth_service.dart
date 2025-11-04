import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../model/login_request.dart';
import '../interfaces/i_auth.dart';
import 'package:kaizen_pro/src/api/api_interface.dart';

class AuthServiceImpl implements IAuth {
  final ApiInterface _api;
  final FlutterSecureStorage _secureStorage;
  bool _isInitialized = false;

  static const _jwtKey = 'jwt';

  AuthServiceImpl(this._api, this._secureStorage);

  Future<void> _initializeApi() async {
    if (_isInitialized) return;
    await _api.initialize();
    _isInitialized = true;
  }

  Future<String?> _getTokenFromStorage() async => await _secureStorage.read(key: _jwtKey);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    await _initializeApi();

    try {
      final response = await _api.post('/auth/login', data: request.toJson());
      final data = response.data as Map<String, dynamic>? ?? {};

      final loginResp = LoginResponse.fromJson(data);

      if (loginResp.token.isNotEmpty) {
        await _secureStorage.write(key: _jwtKey, value: loginResp.token);
      }

      return loginResp;
    } on DioException catch (e) {
      // Re-lanzar con mensaje más claro
      final message = e.response?.data?.toString() ?? e.message;
      throw Exception('Error en login: $message');
    } catch (e) {
      throw Exception('Error en login: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _initializeApi();
    // No existe ruta de backend para logout: manejar localmente
    // Limpiar header Authorization en el cliente y borrar el token en storage
    try {
      if (_isInitialized) {
        try {
          _api.client.options.headers.remove('Authorization');
        } catch (_) {}
      }
    } catch (_) {}

    await _secureStorage.delete(key: _jwtKey);
  }

  @override
  Future<void> refreshToken() async {
    await _initializeApi();
    // No existe endpoint de backend para refresh; manejar localmente.
    // Aquí solo re-aplicamos el token almacenado (si existe) al cliente API.
    final current = await _getTokenFromStorage();
    if (current == null) throw Exception('No hay token para refrescar.');

    // Re-aplicar el token al cliente para asegurar que siguiente request lo use.
    if (_isInitialized) {
      try {
        _api.client.options.headers['Authorization'] = 'Bearer $current';
      } catch (_) {}
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _getTokenFromStorage();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async => await _getTokenFromStorage();
}
