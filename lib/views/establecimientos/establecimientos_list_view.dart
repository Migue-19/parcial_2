import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimientos_service.dart';
import '../../themes/app_theme.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() =>
      _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  List<Establecimiento> _items = [];
  bool _loading = true;
  String? _error;

  final List<Establecimiento> _fakeItems = List.generate(
    6,
    (i) => Establecimiento(
      id: i,
      nombre: 'Nombre del establecimiento',
      nit: '000.000.000-0',
      direccion: 'Calle 10 # 5-20, Ciudad',
      telefono: '3001234567',
    ),
  );

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await EstablecimientosService().getAll();
      print('📥 Vista recibió ${list.length} establecimientos');
      for (int i = 0; i < list.length && i < 5; i++) {
        print('   [$i] ${list[i].nombre} - ${list[i].nit}');
      }
      if (mounted) setState(() { _items = list; _loading = false; });
    } catch (e) {
      print('✗ Error en vista: $e');
      String msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('connection')) {
        msg = 'Sin conexión al servidor. Verifica tu red e intenta de nuevo.\n\nDetalle: $msg';
      } else if (msg.contains('404')) {
        msg = 'Ruta no encontrada en el servidor (404). Verifica la URL de la API.\n\nDetalle: $msg';
      } else if (msg.contains('401') || msg.contains('403')) {
        msg = 'Acceso denegado (${msg.contains("401") ? "401" : "403"}). La API puede requerir autenticación.';
      }
      if (mounted) setState(() { _error = msg; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        title: const Text('Establecimientos'),
        backgroundColor: AppTheme.fondoTarjeta,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/establecimientos/nuevo');
          if (mounted) _cargar();
        },
        backgroundColor: AppTheme.acento,
        foregroundColor: AppTheme.fondo,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo',
            style: TextStyle(fontWeight: FontWeight.w600)),
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
              const Text('Error al cargar establecimientos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                      color: AppTheme.textoOscuro)),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textoGris, fontSize: 13)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargar,
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

    final displayItems = _loading ? _fakeItems : _items;

    if (!_loading && _items.isEmpty) {
      return const Center(
        child: Text('No hay establecimientos registrados.',
            style: TextStyle(color: AppTheme.textoGris)),
      );
    }

    return Skeletonizer(
      enabled: _loading,
      child: Column(
        children: [
          Container(
            color: AppTheme.fondoTarjeta,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.store_rounded, size: 16, color: AppTheme.acento),
                const SizedBox(width: 8),
                Text('${displayItems.length} establecimientos',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textoGris)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borde),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return _EstablecimientoTile(
                  item: item,
                  onTap: _loading
                      ? () {}
                      : () async {
                          if (item.id == null) return;
                          await context.push(
                            '/establecimientos/${item.id}',
                            extra: item,
                          );
                          if (mounted) _cargar();
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EstablecimientoTile extends StatelessWidget {
  final Establecimiento item;
  final VoidCallback onTap;

  const _EstablecimientoTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.fondoTarjeta,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.primario.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borde),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.logoUrl != null && item.logoUrl!.isNotEmpty
                    ? Image.network(item.logoUrl!,
                        width: 52, height: 52, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderLogo())
                    : _placeholderLogo(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombre,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: AppTheme.textoOscuro)),
                    const SizedBox(height: 3),
                    Text('NIT: ${item.nit}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textoGris)),
                    Text(item.direccion,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textoGris),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textoGris, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderLogo() {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: AppTheme.acento.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.store_rounded, color: AppTheme.acento, size: 26),
    );
  }
}
