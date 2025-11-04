import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kaizen_pro/src/components/dashboard/hook/dashboar_hook.dart';
import 'package:kaizen_pro/src/components/dashboard/models/dashboard_model.dart';
import 'package:kaizen_pro/src/providers/query_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kaizen_pro/src/providers/auth_provider.dart';
import 'package:kaizen_pro/src/routes/app_routes.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.useDashboard;

    useEffect(() {
      Future.microtask(() => dashboard.connectUsingStoredToken());
      // No usar ref/dashboard en dispose; el Notifier/Service debe encargarse del cleanup.
      return null;
    }, const []);

    final state = dashboard.getState();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E40AF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('Kaizen Pro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Menú', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF1E40AF)),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  // Capture navigator to avoid using BuildContext after async gaps
                  final navigator = Navigator.of(context);

                  // Confirm before logout
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text('¿Deseas cerrar la sesión y volver al login?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Cerrar sesión')),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  // Ejecutar logout del servicio de auth
                  try {
                    await ref.read(authServiceProvider).logout();
                  } catch (_) {}

                  // Navegar al login y limpiar stack
                  navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E40AF),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // If you have a Drawer in the Scaffold, this will open it.
            // If not, you can replace this with your menu handler.
            try {
              Scaffold.of(context).openDrawer();
            } catch (_) {}
          },
        ),
        centerTitle: true,
        title: SizedBox(
          height: 200,
          child: Image.asset(
            'assets/logo/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
        actions: [],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(QueryState<DashboardModel> state) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state.isLoading && state.data == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E40AF)),
        ),
      );
    }

    final dash = state.data;
    if (dash == null) {
      return const Center(
        child: Text(
          'Sin datos aún',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(),
          const SizedBox(height: 24),

      Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricsGrid(
                  totalUsers: dash.totalUsers,
                  totalPlans: dash.totalPlans,
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Análisis Visual',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                _ChartsSection(
                  improvementData: dash.improvementData,
                  objectivesData: dash.objectivesData,
                  actionsData: dash.actionsData,
                  typeObjectives: dash.typeObjectives,
                  usersData: dash.users,
                  timeFramesData: dash.timeFrames,
                ),
                
                const SizedBox(height: 24),
                
                _BenefitsSection(),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Información Detallada del Sistema',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _AlliedUsersCard(totalUsers: dash.totalUsers),
                const SizedBox(height: 16),

                _InfoCard(
                  title: 'Usuarios',
                  icon: Icons.people_outline,
                  items: dash.users,
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Planes de Mejora',
                  icon: Icons.trending_up,
                  items: dash.improvementData,
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Objetivos',
                  icon: Icons.flag_outlined,
                  items: dash.objectivesData,
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Acciones',
                  icon: Icons.task_alt,
                  items: dash.actionsData,
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'TimeFrames',
                  icon: Icons.schedule,
                  items: dash.timeFrames,
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Tipo de Objetivos',
                  icon: Icons.category_outlined,
                  items: dash.typeObjectives,
                  color: const Color(0xFF1E40AF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
        ),
      ),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Proyectos',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optimiza tu flujo de trabajo y alcanza tus objetivos con una gestión eficiente',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final int totalUsers;
  final int totalPlans;

  const _MetricsGrid({
    required this.totalUsers,
    required this.totalPlans,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.people,
            label: 'Total Usuarios',
            value: totalUsers.toString(),
            color: const Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricCard(
            icon: Icons.assignment,
            label: 'Total Planes',
            value: totalPlans.toString(),
            color: const Color(0xFF1E40AF),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A8A),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlliedUsersCard extends StatelessWidget {
  final int totalUsers;

  const _AlliedUsersCard({required this.totalUsers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.group, color: Color(0xFF1E40AF), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Usuarios aliados con KaizenPro',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Estos valores están representados en las gráficas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              totalUsers.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF1E40AF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Beneficios Clave',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _BenefitItem(
            icon: Icons.speed,
            title: 'Mayor Eficiencia',
            description: 'Optimiza recursos y reduce tiempos de entrega',
          ),
          const SizedBox(height: 14),
          _BenefitItem(
            icon: Icons.visibility,
            title: 'Visibilidad Total',
            description: 'Monitorea el progreso en tiempo real',
          ),
          const SizedBox(height: 14),
          _BenefitItem(
            icon: Icons.groups,
            title: 'Mejor Colaboración',
            description: 'Facilita la comunicación entre equipos',
          ),
          const SizedBox(height: 14),
          _BenefitItem(
            icon: Icons.analytics,
            title: 'Decisiones Informadas',
            description: 'Datos precisos para tomar mejores decisiones',
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1E40AF), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DashboardMetric> items;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la card
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                // Badge con el total de items
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido - siempre visible
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sin datos disponibles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast = index == items.length - 1;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.concepto,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCE7FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.cantidad,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final List<DashboardMetric> improvementData;
  final List<DashboardMetric> objectivesData;
  final List<DashboardMetric> actionsData;
  final List<DashboardMetric> typeObjectives;
  final List<DashboardMetric> usersData;
  final List<DashboardMetric> timeFramesData;

  const _ChartsSection({
    required this.improvementData,
    required this.objectivesData,
    required this.actionsData,
    required this.typeObjectives,
    required this.usersData,
    required this.timeFramesData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gráfica de barras para Planes de Mejora y Objetivos
        _BarChartCard(
          title: 'Planes de Mejora vs Objetivos',
          icon: Icons.bar_chart,
          data1: improvementData,
          data2: objectivesData,
          label1: 'Planes',
          label2: 'Objetivos',
        ),
        const SizedBox(height: 16),
        
        // Gráfica circular para Tipo de Objetivos
        if (typeObjectives.isNotEmpty)
          _PieChartCard(
            title: 'Distribución de Tipos de Objetivos',
            icon: Icons.pie_chart,
            data: typeObjectives,
          ),
        const SizedBox(height: 16),
        
        // Gráfica de barras horizontales para Acciones
        if (actionsData.isNotEmpty)
          _HorizontalBarChartCard(
            title: 'Estado de Acciones',
            icon: Icons.analytics,
            data: actionsData,
          ),

        const SizedBox(height: 16),

        if (usersData.isNotEmpty)
          _HorizontalBarChartCard(
            title: 'Usuarios',
            icon: Icons.people_outline,
            data: usersData,
          ),

        const SizedBox(height: 16),

        if (timeFramesData.isNotEmpty)
          _HorizontalBarChartCard(
            title: 'Distribución por TimeFrame',
            icon: Icons.schedule,
            data: timeFramesData,
          ),
      ],
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DashboardMetric> data1;
  final List<DashboardMetric> data2;
  final String label1;
  final String label2;

  const _BarChartCard({
    required this.title,
    required this.icon,
    required this.data1,
    required this.data2,
    required this.label1,
    required this.label2,
  });

  @override
  Widget build(BuildContext context) {
    if (data1.isEmpty && data2.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1E40AF), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF1E40AF), label: label1),
              const SizedBox(width: 20),
              _LegendItem(color: const Color(0xFF60A5FA), label: label2),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue([...data1, ...data2]) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF1E3A8A),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? label1 : label2;
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data1.length) {
                          final text = data1[index].concepto;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text.length > 10 ? '${text.substring(0, 10)}...' : text,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _createBarGroups(data1, data2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(
    List<DashboardMetric> data1,
    List<DashboardMetric> data2,
  ) {
    final maxLength = data1.length > data2.length ? data1.length : data2.length;
    
    return List.generate(maxLength, (index) {
      final double value1 = index < data1.length ? (double.tryParse(data1[index].cantidad) ?? 0.0) : 0.0;
      final double value2 = index < data2.length ? (double.tryParse(data2[index].cantidad) ?? 0.0) : 0.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value1,
            color: const Color(0xFF1E40AF),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          BarChartRodData(
            toY: value2,
            color: const Color(0xFF60A5FA),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxValue(List<DashboardMetric> data) {
    if (data.isEmpty) return 10.0;
    return data
        .map((e) => double.tryParse(e.cantidad) ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
  }
}

class _PieChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DashboardMetric> data;

  const _PieChartCard({
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1E40AF), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: Center(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _createPieSections(data),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Leyenda colocada debajo del gráfico en varias columnas para
              // ahorrar espacio horizontal.
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final color = _getColorForIndex(index);

                  return SizedBox(
                    width: 160,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.concepto,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.cantidad,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(List<DashboardMetric> data) {
    final total = data.fold<double>(
      0.0,
      (sum, item) => sum + (double.tryParse(item.cantidad) ?? 0.0),
    );

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = double.tryParse(item.cantidad) ?? 0.0;
      final percentage = total > 0 ? (value / total * 100) : 0.0;

      return PieChartSectionData(
        color: _getColorForIndex(index),
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF1E40AF),
      const Color(0xFF3B82F6),
      const Color(0xFF60A5FA),
      const Color(0xFF93C5FD),
      const Color(0xFF1E3A8A),
      const Color(0xFF2563EB),
    ];
    return colors[index % colors.length];
  }
}

class _HorizontalBarChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DashboardMetric> data;

  const _HorizontalBarChartCard({
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1E40AF), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            height: data.length * 60.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(data) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF1E3A8A),
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 100,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              data[index].concepto,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: false,
                  verticalInterval: 1,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = double.tryParse(entry.value.cantidad) ?? 0.0;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: const Color(0xFF1E40AF),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxValue(List<DashboardMetric> data) {
    if (data.isEmpty) return 10.0;
    return data
        .map((e) => double.tryParse(e.cantidad) ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
