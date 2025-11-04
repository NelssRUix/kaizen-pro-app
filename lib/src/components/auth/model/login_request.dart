/// Modelo para la petición de login y la respuesta que contiene el token
/// Nota: el backend espera el campo `username` (no `email`).
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  /// Serializa la petición usando las claves que el backend espera
  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };

  Map<String, String> toMap() => {
        'username': username.isNotEmpty ? username : '',
        'password': password.isNotEmpty ? password : '',
      };

  LoginRequest copyWith({String? username, String? password}) =>
      LoginRequest(username: username ?? this.username, password: password ?? this.password);
}

class LoginResponse {
  final String token;
  final Map<String, dynamic>? raw;

  LoginResponse({required this.token, this.raw});

  /// Try multiple common shapes to retrieve the token from backend
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Common locations where backends return a token
    String? token;

    // Top-level token
    token = json['token'] as String?;

    // Some APIs use 'access_token' or 'accessToken'
    token ??= json['access_token'] as String?;
    token ??= json['accessToken'] as String?;

    // Some APIs wrap payload in 'data'
    if (token == null && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      token = data['token'] as String? ?? data['access_token'] as String? ?? data['accessToken'] as String?;
    }

    // Fallback to empty string to avoid nullable complications
    return LoginResponse(token: token ?? '', raw: json);
  }

  Map<String, dynamic> toJson() => {
        'token': token,
      };

  Map<String, String> toMap() => {
        'token': token.isNotEmpty ? token : '',
      };

  LoginResponse copyWith({String? token, Map<String, dynamic>? raw}) =>
      LoginResponse(token: token ?? this.token, raw: raw ?? this.raw);
}
