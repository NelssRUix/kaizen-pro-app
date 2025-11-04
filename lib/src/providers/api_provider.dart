import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaizen_pro/src/api/api_interface.dart';
import 'package:kaizen_pro/src/api/api_service.dart';

final apiProvider = Provider<ApiInterface>((ref) {
  final secureStorage = FlutterSecureStorage();
  final api = Api(secureStorage);
  api.initialize();
  return api;
});