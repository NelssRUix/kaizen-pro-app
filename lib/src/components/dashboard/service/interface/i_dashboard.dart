import 'dart:async';
import 'package:kaizen_pro/src/components/dashboard/models/dashboard_model.dart';

/// Contrato para consumir los datos del dashboard vía Socket.IO
abstract class IDashboardSocketService {
	/// Conecta al namespace/ruta `/dashboard` agregando `?token=` a la URL.
	///
	/// - [token]: token JWT o similar.
	/// - [baseUrl]: URL base del servidor (ej: https://api.tuapp.com). Si no se
	///   provee, el servicio intentará leer `SOCKET_URL` o `API_URL` del `.env`.
	Future<void> connect({required String token, String? baseUrl});

	/// Conecta usando el token almacenado localmente (por ejemplo, el guardado
	/// en login con la clave `jwt`). Si no existe token, lanza una excepción.
	Future<void> connectUsingStoredToken({String? baseUrl});

	/// Desconecta y limpia recursos.
	Future<void> disconnect();

	/// Indica si hay una conexión activa.
	bool get isConnected;

	/// Último valor recibido (si existe).
	DashboardModel? get lastValue;

	/// Flujo de actualizaciones del dashboard.
	Stream<DashboardModel> get updates;
}

