import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaizen_pro/src/components/auth/service/implementation/auth_service.dart';

import '../../../providers/query_provider.dart';
import 'package:kaizen_pro/src/components/auth/model/login_request.dart';
import 'package:kaizen_pro/src/providers/auth_provider.dart';

/// Hook/Helper para operaciones de login
class UseLogin {
	final WidgetRef ref;
	final AuthServiceImpl _service;

	static final _loginProvider =
			NotifierProvider<QueryNotifier<LoginResponse>, QueryState<LoginResponse>>(
		() => QueryNotifier<LoginResponse>(),
	);

	UseLogin(this.ref) : _service = ref.read(authServiceProvider);

	/// Ejecuta el login y actualiza el estado
	Future<void> login(LoginRequest request) async {
		final notifier = ref.read(_loginProvider.notifier);

		final currentState = ref.read(_loginProvider);
		if (currentState.isLoading) return;

		await notifier.fetchData(() async {
			final resp = await _service.login(request);
			return resp;
		});
	}

	/// Estado actual del login
	QueryState<LoginResponse> getState() {
		return ref.watch(_loginProvider);
	}

	/// Invalidar estado para recargar
	void invalidate() {
		ref.invalidate(_loginProvider);
	}
}

/// Extensión en WidgetRef para usar el hook de login
extension LoginHooksExtension on WidgetRef {
	UseLogin get useLogin => UseLogin(this);
}
