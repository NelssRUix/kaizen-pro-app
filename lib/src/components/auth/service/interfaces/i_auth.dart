
import 'package:kaizen_pro/src/components/auth/model/login_request.dart';

abstract class IAuth {

  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<void> refreshToken();
  Future<bool> isLoggedIn();
  Future<String?> getToken();

  
}