
/// Modelo que representa un par concepto/cantidad en el dashboard.
class DashboardMetric {
	final String concepto;
	final String cantidad;

	DashboardMetric({
		required this.concepto,
		required this.cantidad,
	});

	/// Crea una instancia a partir del JSON recibido del backend.
	factory DashboardMetric.fromJson(Map<String, dynamic> json) {
		return DashboardMetric(
			concepto: json['concepto'] as String? ?? '',
			cantidad: json['cantidad']?.toString() ?? '0',
		);
	}

	/// Convierte la instancia a JSON.
	Map<String, dynamic> toJson() {
		return {
			'concepto': concepto,
			'cantidad': cantidad,
		};
	}

	/// Mapa simple de strings útil para formularios o logs.
	Map<String, String> toMap() {
		try {
			return {
				'concepto': concepto.isNotEmpty ? concepto : '',
				'cantidad': cantidad.isNotEmpty ? cantidad : '0',
			};
		} catch (e) {
			return {
				'concepto': '',
				'cantidad': '0',
			};
		}
	}

	DashboardMetric copyWith({
		String? concepto,
		String? cantidad,
	}) {
		return DashboardMetric(
			concepto: concepto ?? this.concepto,
			cantidad: cantidad ?? this.cantidad,
		);
	}

	/// Devuelve la cantidad parseada como int (si es posible), 0 en caso contrario.
	int get cantidadInt {
		try {
			final cleaned = cantidad.toString().replaceAll(RegExp(r"[^0-9-]"), '');
			return int.tryParse(cleaned) ?? 0;
		} catch (e) {
			return 0;
		}
	}
}

/// Modelo que representa los datos del dashboard tal como los devuelve el backend.
class DashboardModel {
	final List<DashboardMetric> users;
	final List<DashboardMetric> improvementData;
	final List<DashboardMetric> objectivesData;
	final List<DashboardMetric> actionsData;
	final List<DashboardMetric> timeFrames;
	final List<DashboardMetric> typeObjectives;

	DashboardModel({
		required this.users,
		required this.improvementData,
		required this.objectivesData,
		required this.actionsData,
		required this.timeFrames,
		required this.typeObjectives,
	});

	/// Crea una instancia a partir del JSON recibido del backend.
	factory DashboardModel.fromJson(Map<String, dynamic> json) {
		List<DashboardMetric> parseList(dynamic maybeList) {
			if (maybeList is List) {
				return maybeList
						.where((e) => e != null)
						.map((e) => DashboardMetric.fromJson(Map<String, dynamic>.from(e as Map)))
						.toList();
			}
			return <DashboardMetric>[];
		}

		return DashboardModel(
			users: parseList(json['users']),
			improvementData: parseList(json['improvementData']),
			objectivesData: parseList(json['objectivesData']),
			actionsData: parseList(json['actionsData']),
			timeFrames: parseList(json['timeFrames']),
			typeObjectives: parseList(json['typeObjectives']),
		);
	}

	/// Convierte la instancia a JSON para enviar/almacenar.
	Map<String, dynamic> toJson() {
		return {
			'users': users.map((e) => e.toJson()).toList(),
			'improvementData': improvementData.map((e) => e.toJson()).toList(),
			'objectivesData': objectivesData.map((e) => e.toJson()).toList(),
			'actionsData': actionsData.map((e) => e.toJson()).toList(),
			'timeFrames': timeFrames.map((e) => e.toJson()).toList(),
			'typeObjectives': typeObjectives.map((e) => e.toJson()).toList(),
		};
	}

	/// Mapa simple de strings útil para formularios o logs.
	Map<String, String> toMapSummary() {
		try {
			final Map<String, String> out = {};
			if (users.isNotEmpty) out['users_total'] = users.map((e) => e.cantidad).join(',');
			if (improvementData.isNotEmpty) out['improvement_total'] = improvementData.map((e) => e.cantidad).join(',');
			if (objectivesData.isNotEmpty) out['objectives_total'] = objectivesData.map((e) => e.cantidad).join(',');
			if (actionsData.isNotEmpty) out['actions_total'] = actionsData.map((e) => e.cantidad).join(',');
			if (timeFrames.isNotEmpty) out['timeFrames_total'] = timeFrames.map((e) => e.cantidad).join(',');
			if (typeObjectives.isNotEmpty) out['typeObjectives_total'] = typeObjectives.map((e) => e.cantidad).join(',');
			return out;
		} catch (e) {
			return {};
		}
	}

	DashboardModel copyWith({
		List<DashboardMetric>? users,
		List<DashboardMetric>? improvementData,
		List<DashboardMetric>? objectivesData,
		List<DashboardMetric>? actionsData,
		List<DashboardMetric>? timeFrames,
		List<DashboardMetric>? typeObjectives,
	}) {
		return DashboardModel(
			users: users ?? this.users,
			improvementData: improvementData ?? this.improvementData,
			objectivesData: objectivesData ?? this.objectivesData,
			actionsData: actionsData ?? this.actionsData,
			timeFrames: timeFrames ?? this.timeFrames,
			typeObjectives: typeObjectives ?? this.typeObjectives,
		);
	}

	/// Helper: obtiene la suma de todas las cantidades en una lista (parseando ints). Útil para totales.
	static int sumListAsInt(List<DashboardMetric> list) {
		return list.fold<int>(0, (prev, el) => prev + el.cantidadInt);
	}

	/// Total de usuarios con lógica defensiva para evitar duplicados:
	/// - Si existe un item cuyo concepto contiene "total" y "usuario", usamos ese valor.
	/// - Si solo hay un elemento, usamos ese.
	/// - En caso contrario, usamos el máximo (no la suma) para evitar doble conteo por categorías.
	int get totalUsers {
		if (users.isEmpty) return 0;
		final candidates = users.where((m) {
			final l = m.concepto.toLowerCase();
			return l.contains('total') && (l.contains('usuario') || l.contains('usuarios'));
		}).toList();
		if (candidates.isNotEmpty) return candidates.first.cantidadInt;
		if (users.length == 1) return users.first.cantidadInt;
		return users.map((e) => e.cantidadInt).fold<int>(0, (prev, v) => v > prev ? v : prev);
	}
	/// Total de planes con lógica defensiva similar a usuarios para evitar duplicados.
	int get totalPlans {
		if (improvementData.isEmpty) return 0;
		final candidates = improvementData.where((m) {
			final l = m.concepto.toLowerCase();
			return l.contains('total') && (l.contains('plan') || l.contains('planes'));
		}).toList();
		if (candidates.isNotEmpty) return candidates.first.cantidadInt;
		if (improvementData.length == 1) return improvementData.first.cantidadInt;
		return improvementData
				.map((e) => e.cantidadInt)
				.fold<int>(0, (prev, v) => v > prev ? v : prev);
	}
}

