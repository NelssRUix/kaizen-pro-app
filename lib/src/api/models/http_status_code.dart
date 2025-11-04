/// Enumeración de códigos de estado HTTP más comunes
enum HttpStatusCode {
  success(200),
  created(201),
  accepted(202),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  conflict(409),
  unprocessableEntity(422),
  internalServerError(500),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504);

  const HttpStatusCode(this.code);
  final int code;

  /// Verifica si es un código de éxito (2xx)
  bool get isSuccess => code >= 200 && code < 300;
  
  /// Verifica si es un error del cliente (4xx)
  bool get isClientError => code >= 400 && code < 500;
  
  /// Verifica si es un error del servidor (5xx)
  bool get isServerError => code >= 500 && code < 600;

  /// Obtiene el HttpStatusCode desde un código entero
  static HttpStatusCode? fromCode(int code) {
    for (HttpStatusCode status in HttpStatusCode.values) {
      if (status.code == code) return status;
    }
    return null;
  }
}
