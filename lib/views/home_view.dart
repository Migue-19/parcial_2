import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_card.dart';
import '../services/accidentes_service.dart';
import '../services/establecimientos_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int? _totalAccidentes;
  int? _totalEstablecimientos;
  bool _loadingAccidentes = true;
  bool _loadingEstablecimientos = true;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    AccidentesService()
        .fetchAccidentesRaw()
        .then((list) {
          if (mounted) {
            setState(() {
              _totalAccidentes = list.length;
              _loadingAccidentes = false;
            });
          }
        })
        .catchError((_) {
          if (mounted) setState(() => _loadingAccidentes = false);
        });

    EstablecimientosService()
        .getAll()
        .then((list) {
          if (mounted) {
            setState(() {
              _totalEstablecimientos = list.length;
              _loadingEstablecimientos = false;
            });
          }
        })
        .catchError((_) {
          if (mounted) setState(() => _loadingEstablecimientos = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.fondoTarjeta,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parcial Flutter',
                    style: TextStyle(
                      color: AppTheme.textoOscuro,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Accidentes Tuluá · Parqueadero',
                    style: TextStyle(color: AppTheme.textoGris, fontSize: 12),
                  ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1040), AppTheme.fondoTarjeta],
                      ),
                    ),
                  ),
                  // Círculos decorativos
                  Positioned(
                    right: -40, top: -20,
                    child: Container(
                      width: 180, height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primario.withOpacity(0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40, top: 50,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.acento.withOpacity(0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primario, AppTheme.acento],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10, top: 30,
                    child: Opacity(
                      opacity: 0.07,
                      child: const Icon(
                        Icons.directions_car_rounded,
                        size: 160,
                        color: AppTheme.primario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Skeletonizer(
                      enabled: _loadingAccidentes,
                      child: _SummaryTile(
                        label: 'Accidentes',
                        value: _totalAccidentes ?? 99999,
                        icon: Icons.car_crash_rounded,
                        color: AppTheme.peligro,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Skeletonizer(
                      enabled: _loadingEstablecimientos,
                      child: _SummaryTile(
                        label: 'Establecimientos',
                        value: _totalEstablecimientos ?? 99,
                        icon: Icons.store_rounded,
                        color: AppTheme.acento,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'MÓDULOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppTheme.textoGris,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CustomCard(
                  title: 'Estadísticas de Accidentes',
                  route: '/accidentes',
                  icon: Icons.bar_chart_rounded,
                  color: AppTheme.peligro,
                  subtitle: 'Accidentes de tránsito en Tuluá',
                  badge: _totalAccidentes != null
                      ? '${_totalAccidentes!} registros'
                      : null,
                ),
                CustomCard(
                  title: 'Gestión de Establecimientos',
                  route: '/establecimientos',
                  icon: Icons.store_rounded,
                  color: AppTheme.acento,
                  subtitle: 'CRUD del sistema de parqueadero',
                  badge: _totalEstablecimientos != null
                      ? '$_totalEstablecimientos registros'
                      : null,
                ),
              ]),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.fondoTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borde),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textoGris)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Note: The above code defines the `HomeView` widget, which serves as the main dashboard of the application. It displays summary cards for the total number of accidents and establishments, and provides navigation to the respective modules for detailed views. The view also includes a visually appealing header with gradients and decorative elements, and uses skeleton placeholders while loading data from the services.