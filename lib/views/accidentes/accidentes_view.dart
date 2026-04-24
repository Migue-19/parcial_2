import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/accidentes_stats.dart';
import '../../services/accidentes_service.dart';
import '../../themes/app_theme.dart';

class AccidentesView extends StatefulWidget {
  const AccidentesView({super.key});

  @override
  State<AccidentesView> createState() => _AccidentesViewState();
}

class _AccidentesViewState extends State<AccidentesView> {
  AccidentesStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      print('🔄 Cargando accidentes...');
      final service = AccidentesService();
      final registros = await service.fetchAccidentesRaw();
      print('✓ ${registros.length} accidentes cargados');
      
      print('🚀 Procesando estadísticas con Isolate...');
      final stats = await service.computeStats(registros);
      print('✅ Estadísticas procesadas exitosamente');
      print('   - Total: ${stats.total}');
      print('   - Clases: ${stats.porClase.keys.toList()}');
      print('   - Top barrios: ${stats.topBarrios.keys.toList()}');
      
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        title: const Text('Estadísticas de Accidentes'),
        backgroundColor: AppTheme.fondoTarjeta,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarDatos,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: AppTheme.peligro.withOpacity(0.7)),
              const SizedBox(height: 16),
              const Text('Error al cargar datos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                      color: AppTheme.textoOscuro)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textoGris, fontSize: 13)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarDatos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primario, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Datos falsos para el skeleton
    final fakeStats = AccidentesStats(
      porClase: {'Choque': 400, 'Atropello': 300, 'Volcamiento': 200, 'Otro': 100},
      porGravedad: {'Con heridos': 500, 'Solo daños': 300, 'Con muertos': 200},
      topBarrios: {'Barrio A': 120, 'Barrio B': 100, 'Barrio C': 80, 'Barrio D': 60, 'Barrio E': 40},
      porDia: {'Lunes': 100, 'Martes': 120, 'Miercoles': 90, 'Jueves': 110, 'Viernes': 130, 'Sabado': 150, 'Domingo': 80},
      total: 1000,
    );

    final stats = _loading ? fakeStats : _stats!;

    return Skeletonizer(
      enabled: _loading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryHeader(total: stats.total),
            _ChartCard(
              title: 'Distribución por Clase de Accidente',
              icon: Icons.pie_chart_rounded,
              child: _PieChartWidget(data: stats.porClase),
            ),
            _ChartCard(
              title: 'Distribución por Gravedad',
              icon: Icons.warning_rounded,
              child: _PieChartWidget(
                data: stats.porGravedad,
                colors: const [Color(0xFFFF5C7C), Color(0xFFFF9B6B), Color(0xFF00D4AA)],
              ),
            ),
            _ChartCard(
              title: 'Top 5 Barrios con más Accidentes',
              icon: Icons.location_on_rounded,
              child: _BarChartWidget(data: stats.topBarrios, color: AppTheme.peligro),
            ),
            _ChartCard(
              title: 'Distribución por Día de la Semana',
              icon: Icons.calendar_today_rounded,
              child: _BarChartWidget(data: stats.porDia, color: AppTheme.primario),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int total;
  const _SummaryHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF1A1040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primario.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppTheme.peligro.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.car_crash_rounded, color: AppTheme.peligro, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const Text('accidentes procesados con Isolate',
                  style: TextStyle(color: AppTheme.textoGris, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.fondoTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primario),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppTheme.textoOscuro)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatefulWidget {
  final Map<String, int> data;
  final List<Color>? colors;

  const _PieChartWidget({required this.data, this.colors});

  @override
  State<_PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<_PieChartWidget> {
  int _touched = -1;

  static const _defaultColors = [
    Color(0xFF6C63FF), Color(0xFF00D4AA), Color(0xFFFF5C7C),
    Color(0xFFFFB347), Color(0xFF7EC8E3), Color(0xFFB97FD8),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = widget.data.entries.toList();
    final total = entries.fold(0, (s, e) => s + e.value);
    final colors = widget.colors ?? _defaultColors;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null || response.touchedSection == null) {
                      _touched = -1;
                    } else {
                      _touched = response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              sections: entries.asMap().entries.map((e) {
                final idx = e.key;
                final entry = e.value;
                final isTouched = idx == _touched;
                final pct = total > 0 ? entry.value / total * 100 : 0.0;
                return PieChartSectionData(
                  color: colors[idx % colors.length],
                  value: entry.value.toDouble(),
                  title: '${pct.toStringAsFixed(1)}%',
                  radius: isTouched ? 75 : 60,
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: entries.asMap().entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: colors[e.key % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${e.value.key} (${e.value.value})',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textoGris)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final Color color;

  const _BarChartWidget({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = entries.fold(0, (m, e) => e.value > m ? e.value : m);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${entries[group.x].key}\n${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                  final label = entries[idx].key;
                  final short = label.length > 8 ? label.substring(0, 8) : label;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(short,
                        style: const TextStyle(fontSize: 9, color: AppTheme.textoGris,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: AppTheme.textoGris),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppTheme.borde, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: color,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
// Note: The above code defines the `AccidentesView` widget, which displays various statistics about accidents using pie charts and bar charts. It fetches raw accident data, processes it using an isolate to compute statistics, and then visualizes the results. The view also includes error handling and a loading state with skeleton placeholders.