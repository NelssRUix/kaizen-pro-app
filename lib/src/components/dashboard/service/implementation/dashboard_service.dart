import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:kaizen_pro/src/components/dashboard/models/dashboard_model.dart';
import 'package:kaizen_pro/src/components/dashboard/service/interface/i_dashboard.dart';
import 'package:kaizen_pro/src/api/api_interface.dart';

/// Servicio que gestiona la conexión Socket.IO al dashboard.
class DashboardSocketService implements IDashboardSocketService {
	DashboardSocketService(this._secureStorage, {ApiInterface? api}) : _api = api;

	final FlutterSecureStorage _secureStorage;
	final ApiInterface? _api;
	IO.Socket? _socket;
	final _controller = StreamController<DashboardModel>.broadcast();
	DashboardModel? _last;

	@override
	bool get isConnected => _socket?.connected == true;

	@override
	DashboardModel? get lastValue => _last;

	@override
	Stream<DashboardModel> get updates => _controller.stream;

	@override
	Future<void> connect({required String token, String? baseUrl}) async {
		// Si ya hay una conexión, la cerramos antes de reconectar
		if (_socket != null) {
			await disconnect();
		}

		// Determinar URL base desde parámetro o .env
		final String url = _resolveBaseUrl(baseUrl);

		if (url.isEmpty) {
			throw Exception('Base URL para socket no configurada (SOCKET_URL o API_URL)');
		}

		// Conexión al namespace/ruta "/dashboard" con query ?token=...
		// Ej: https://api.tuapp.com/dashboard?token=XYZ
		final String nsUrl = _buildDashboardUrl(url, token);

		// Configurar opciones (preferir transporte websocket)
		final opts = IO.OptionBuilder()
				.setTransports(['websocket'])
				.disableAutoConnect()
				.build();

		final socket = IO.io(nsUrl, opts);

		// Listeners básicos
		socket.onConnect((_) {
			if (kDebugMode) {
				print('[DashboardSocket] conectado a $nsUrl');
			}
		});

		socket.onConnectError((data) {
			if (kDebugMode) {
				print('[DashboardSocket] connect_error: $data');
			}
		});

		socket.onError((data) {
			if (kDebugMode) {
				print('[DashboardSocket] error: $data');
			}
		});

		socket.onDisconnect((_) {
			if (kDebugMode) {
				print('[DashboardSocket] desconectado');
			}
		});

		// Listener del evento principal
		socket.on('dashboard:update', (data) {
			try {
						if (data is Map) {
							final model = DashboardModel.fromJson(Map<String, dynamic>.from(data));
					_last = model;
					_controller.add(model);
				} else if (data is String) {
					// En caso de recibir string, no parseamos aquí para evitar dependencias json.
					if (kDebugMode) {
						print('[DashboardSocket] data es String, se esperaba Map.');
					}
				}
			} catch (e) {
				if (kDebugMode) {
					print('[DashboardSocket] error parseando dashboard:update -> $e');
				}
			}
		});

		socket.connect();
		_socket = socket;
	}

		@override
		Future<void> connectUsingStoredToken({String? baseUrl}) async {
			String? token;
			try {
				token = await _secureStorage.read(key: 'jwt');
			} catch (_) {
				token = null;
			}
			if (token == null || token.isEmpty) {
				throw Exception('No hay token almacenado para conectar el dashboard socket.');
			}
			await connect(token: token, baseUrl: baseUrl);
		}

	@override
	Future<void> disconnect() async {
		try {
			_socket?.off('dashboard:update');
			_socket?.dispose();
			_socket?.disconnect();
			_socket = null;
		} catch (_) {}
	}

	String _buildDashboardUrl(String base, String token) {
		// Normalizar base (sin slash final)
		final String cleanedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
		// Agregar namespace/ruta y query param token
		final String url = '$cleanedBase/dashboard?token=$token';
		return url;
	}

			String _resolveBaseUrl(String? baseUrl) {
				// 1) Param explícito
				if (baseUrl != null && baseUrl.trim().isNotEmpty) return baseUrl.trim();

				// 2) Variable de entorno específica para sockets
				final envSocket = dotenv.env['SOCKET_URL']?.trim();
				if (envSocket != null && envSocket.isNotEmpty) return envSocket;

				// 3) Base URL del ApiInterface (si está disponible e inicializado)
					if (_api != null) {
					try {
							final candidate = _api.client.options.baseUrl.trim();
						if (candidate.isNotEmpty) return candidate;
					} catch (_) {
						// client no inicializado o sin baseUrl; continuar
					}
				}

				// 4) Fallback a API_URL del .env
				final envApi = dotenv.env['API_URL']?.trim();
				return envApi ?? '';
			}
}

