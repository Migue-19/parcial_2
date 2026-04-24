import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimientos_service.dart';
import '../../themes/app_theme.dart';

class EstablecimientoDetailView extends StatelessWidget {
  final Establecimiento establecimiento;

  const EstablecimientoDetailView({required this.establecimiento, super.key});

  Future<void> _confirmarEliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.fondoTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borde),
        ),
        title: const Text('Eliminar establecimiento',
            style: TextStyle(color: AppTheme.textoOscuro)),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${establecimiento.nombre}"? Esta acción no se puede deshacer.',
            style: const TextStyle(color: AppTheme.textoGris)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textoGris)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.peligro,
                foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await EstablecimientosService().delete(establecimiento.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Establecimiento eliminado correctamente'),
              backgroundColor: AppTheme.acento,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.go('/establecimientos');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al eliminar: $e'),
                backgroundColor: AppTheme.peligro,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        title: Text(
          establecimiento.nombre,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textoOscuro),
        ),
        backgroundColor: AppTheme.fondoTarjeta,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppTheme.acento),
            tooltip: 'Editar',
            onPressed: () async {
              await context.push(
                '/establecimientos/${establecimiento.id}/editar',
                extra: establecimiento,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppTheme.peligro.withOpacity(0.8)),
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (establecimiento.logoUrl != null &&
              establecimiento.logoUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                establecimiento.logoUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primario.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borde),
                  ),
                  child: const Center(
                    child: Icon(Icons.store_rounded, size: 60, color: AppTheme.acento),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.acento.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borde),
              ),
              child: const Center(
                child: Icon(Icons.store_rounded, size: 60, color: AppTheme.acento),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Container(
            decoration: BoxDecoration(
              color: AppTheme.fondoTarjeta,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borde),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Nombre', value: establecimiento.nombre),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borde),
                _DetailRow(label: 'NIT', value: establecimiento.nit),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borde),
                _DetailRow(label: 'Dirección', value: establecimiento.direccion),
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borde),
                _DetailRow(label: 'Teléfono', value: establecimiento.telefono),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textoGris,
                    side: const BorderSide(color: AppTheme.borde, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.push(
                      '/establecimientos/${establecimiento.id}/editar',
                      extra: establecimiento,
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.acento,
                    foregroundColor: AppTheme.fondo,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmarEliminar(context),
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Eliminar establecimiento'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.peligro,
                side: BorderSide(color: AppTheme.peligro.withOpacity(0.6), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textoGris)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textoOscuro)),
          ),
        ],
      ),
    );
  }
}
// Note: The above code defines the `EstablecimientoDetailView` widget, which displays detailed information about a specific establishment. It includes the establishment's name, NIT, address, phone number, and logo (if available). The view also provides options to edit or delete the establishment, with appropriate confirmation dialogs and error handling.