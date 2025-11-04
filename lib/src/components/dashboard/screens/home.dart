import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kaizen_pro/src/routes/app_routes.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const LandingScreen({
    super.key,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    // Tamaño del logo responsive: usa la mitad del ancho de pantalla en móviles
    // y un tamaño fijo mayor en pantallas amplias.
  final screenWidth = MediaQuery.of(context).size.width;
    // Tamaños reducidos: hacer la app un poco más compacta.
    // logoSize más pequeño y menos escala para recorte.
    final double logoSize = screenWidth >= 800
      ? 360.0
      : (screenWidth >= 600 ? 320.0 : screenWidth * 0.6);
    // Multiplicador para escalar/recortar visualmente la imagen.
    final double imageScale = screenWidth >= 800
      ? 1.08
      : (screenWidth >= 600 ? 1.12 : 1.18);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
          // Reducimos el padding vertical para que el logo quede más arriba
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: OverflowBox(
                      maxWidth: logoSize * imageScale,
                      maxHeight: logoSize * imageScale,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/logo/logo.png',
                        width: logoSize * imageScale,
                        height: logoSize * imageScale,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Carrusel de imágenes locales
                _ImageCarousel(
                  imagePaths: [
                    'assets/logo/01.png',
                    'assets/logo/02.png',
                    'assets/logo/03.png',
                  ],
                  height: 180,
                ),

                const SizedBox(height: 32),

                const Text(
                  'Gestiona tus Proyectos\ncon Precisión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'La herramienta definitiva para empresas y negocios\nque buscan alcanzar sus metas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la ruta de login y luego ejecutar el callback si existe
                      Navigator.of(context).pushNamed(AppRoutes.login);
                      if (onGetStarted != null) onGetStarted!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E40AF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Ahora',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                const _FeatureCard(
                  icon: Icons.schedule_rounded,
                  title: 'Trazado de Tiempos',
                  description:
                      'Define plazos claros para cada meta y mantén el control total de tus proyectos.',
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                const SizedBox(height: 32),

                const _FeatureCard(
                  icon: Icons.flag_outlined,
                  title: 'Objetivos Claros',
                  description:
                      'Establece objetivos específicos que impulsan el avance de tus planes de mejora.',
                ),
                const SizedBox(height: 32),

                const _FeatureCard(
                  icon: Icons.grid_view_rounded,
                  title: 'Múltiples Proyectos',
                  description:
                      'Gestiona varios proyectos simultáneamente con una vista organizada y eficiente.',
                ),
                const SizedBox(height: 32),

                const _FeatureCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Seguimiento de Avances',
                  description:
                      'Monitorea el progreso en tiempo real y ajusta estrategias para alcanzar tus metas.',
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final double height;

  const _ImageCarousel({
    Key? key,
    required this.imagePaths,
    this.height = 180.0,
  }) : super(key: key);

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late final PageController _controller;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.imagePaths.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final next = (_current + 1) % widget.imagePaths.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imagePaths.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.imagePaths[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imagePaths.length, (index) {
            final bool active = _current == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 14 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF1E40AF) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.6,
                    letterSpacing: 0,
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
