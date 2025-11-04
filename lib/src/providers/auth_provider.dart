import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaizen_pro/src/providers/api_provider.dart';
import 'package:kaizen_pro/src/components/auth/service/implementation/auth_service.dart';

/// Proveedor del almacenamiento seguro para reusar en otras dependencias
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Proveedor del servicio de autenticación
final authServiceProvider = Provider<AuthServiceImpl>((ref) {
  final api = ref.read(apiProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthServiceImpl(api, storage);
});
