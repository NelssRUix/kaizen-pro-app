import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kaizen_pro/src/components/dashboard/models/dashboard_model.dart';
import 'package:kaizen_pro/src/components/dashboard/service/implementation/dashboard_service.dart';
import 'package:kaizen_pro/src/providers/query_provider.dart';
import 'package:kaizen_pro/src/providers/auth_provider.dart';
import 'package:kaizen_pro/src/providers/api_provider.dart';

/// Provider del servicio de Dashboard Socket, reutilizando storage y API base.
final dashboardSocketServiceProvider = Provider<DashboardSocketService>((ref) {
	final storage = ref.read(secureStorageProvider);
	final api = ref.read(apiProvider);
	return DashboardSocketService(storage, api: api);
});

/// Notifier que gestiona conexión, suscripción y estado del dashboard
class DashboardNotifier extends Notifier<QueryState<DashboardModel>> {
	StreamSubscription<DashboardModel>? _sub;

	DashboardSocketService get _service => ref.read(dashboardSocketServiceProvider);

	@override
	QueryState<DashboardModel> build() {
		// Limpiar recursos al desechar el provider
		ref.onDispose(() async {
			await _sub?.cancel();
			_sub = null;
			await _service.disconnect();
		});
		return QueryState<DashboardModel>.initial();
	}

	bool get isConnected => _service.isConnected;

	Future<void> connectUsingStoredToken({String? baseUrl}) async {
		if (_service.isConnected) return;
		state = QueryState<DashboardModel>(isLoading: true, data: state.data, error: null);
		await _service.connectUsingStoredToken(baseUrl: baseUrl);
		await _subscribe();
	}

	Future<void> connect({required String token, String? baseUrl}) async {
		if (_service.isConnected) return;
		state = QueryState<DashboardModel>(isLoading: true, data: state.data, error: null);
		await _service.connect(token: token, baseUrl: baseUrl);
		await _subscribe();
	}

	Future<void> disconnect() async {
		await _sub?.cancel();
		_sub = null;
		await _service.disconnect();
		state = QueryState<DashboardModel>(isLoading: false, data: state.data, error: null);
	}

	Future<void> _subscribe() async {
		await _sub?.cancel();
		_sub = _service.updates.listen(
			(dash) {
				state = QueryState<DashboardModel>(isLoading: false, data: dash, error: null);
			},
			onError: (e) {
				state = QueryState<DashboardModel>(isLoading: false, data: state.data, error: e.toString());
			},
		);
	}
}

final dashboardProvider =
		NotifierProvider<DashboardNotifier, QueryState<DashboardModel>>(() => DashboardNotifier());

/// Hook/Helper para conectar y consumir el stream del dashboard
class UseDashboard {
	final WidgetRef ref;

	UseDashboard(this.ref);

	Future<void> connectUsingStoredToken({String? baseUrl}) async {
		await ref.read(dashboardProvider.notifier).connectUsingStoredToken(baseUrl: baseUrl);
	}

	Future<void> connect({required String token, String? baseUrl}) async {
		await ref.read(dashboardProvider.notifier).connect(token: token, baseUrl: baseUrl);
	}

	Future<void> disconnect() async {
		await ref.read(dashboardProvider.notifier).disconnect();
	}

	QueryState<DashboardModel> getState() => ref.watch(dashboardProvider);

	bool get isConnected => ref.watch(dashboardProvider.notifier).isConnected;
}

/// Extensión en WidgetRef para usar el hook de dashboard
extension DashboardHooksExtension on WidgetRef {
	UseDashboard get useDashboard => UseDashboard(this);
}

