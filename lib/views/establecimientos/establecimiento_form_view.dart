import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/establecimiento.dart';
import '../../services/establecimientos_service.dart';
import '../../themes/app_theme.dart';

class EstablecimientoFormView extends StatefulWidget {
  /// null = crear nuevo; not-null = editar existente
  final Establecimiento? establecimiento;

  const EstablecimientoFormView({required this.establecimiento, super.key});

  @override
  State<EstablecimientoFormView> createState() =>
      _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _nit;
  late final TextEditingController _direccion;
  late final TextEditingController _telefono;

  XFile? _logoFile;
  Uint8List? _logoBytes;
  bool _saving = false;

  bool get _isEditing => widget.establecimiento != null;

  @override
  void initState() {
    super.initState();
    final e = widget.establecimiento;
    _nombre = TextEditingController(text: e?.nombre ?? '');
    _nit = TextEditingController(text: e?.nit ?? '');
    _direccion = TextEditingController(text: e?.direccion ?? '');
    _telefono = TextEditingController(text: e?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _nit.dispose();
    _direccion.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _logoFile = picked;
        _logoBytes = bytes;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.fondoTarjeta,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Seleccionar imagen',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textoGris)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primario),
              title: const Text('Galería', style: TextStyle(color: AppTheme.textoOscuro)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primario),
              title: const Text('Cámara', style: TextStyle(color: AppTheme.textoOscuro)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final service = EstablecimientosService();
    try {
      if (_isEditing) {
        await service.update(
          id: widget.establecimiento!.id!,
          nombre: _nombre.text.trim(),
          nit: _nit.text.trim(),
          direccion: _direccion.text.trim(),
          telefono: _telefono.text.trim(),
          logo: _logoFile,
        );
      } else {
        await service.create(
          nombre: _nombre.text.trim(),
          nit: _nit.text.trim(),
          direccion: _direccion.text.trim(),
          telefono: _telefono.text.trim(),
          logo: _logoFile,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Establecimiento actualizado correctamente'
                : 'Establecimiento creado correctamente'),
            backgroundColor: AppTheme.acento,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.peligro,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Establecimiento' : 'Nuevo Establecimiento'),
        backgroundColor: AppTheme.fondoTarjeta,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de logo
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primario.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primario.withOpacity(0.4), width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside),
                    ),
                    child: _logoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                        child: _logoBytes != null
                          ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                          : _logoPlaceholder(),
                          )
                        : widget.establecimiento?.logoUrl != null &&
                                widget.establecimiento!.logoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                    widget.establecimiento!.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _logoPlaceholder()),
                              )
                            : _logoPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Toca para seleccionar logo',
                    style: TextStyle(fontSize: 12, color: AppTheme.textoGris)),
              ),
              const SizedBox(height: 24),

              // Campos del formulario
              _FormField(controller: _nombre, label: 'Nombre', hint: 'Nombre del establecimiento',
                  icon: Icons.store_rounded, validator: _required),
              const SizedBox(height: 14),
              _FormField(controller: _nit, label: 'NIT', hint: '000.000.000-0',
                  icon: Icons.badge_rounded, validator: _required,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _FormField(controller: _direccion, label: 'Dirección', hint: 'Calle 10 # 5-20',
                  icon: Icons.location_on_rounded, validator: _required),
              const SizedBox(height: 14),
              _FormField(controller: _telefono, label: 'Teléfono', hint: '3001234567',
                  icon: Icons.phone_rounded, validator: _required,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 28),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _guardar,
                  icon: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.fondo))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    _saving ? 'Guardando...' : (_isEditing ? 'Actualizar' : 'Crear Establecimiento'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textoGris,
                    side: const BorderSide(color: AppTheme.borde),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primario, size: 36),
        SizedBox(height: 4),
        Text('Logo', style: TextStyle(fontSize: 11, color: AppTheme.primario)),
      ],
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Este campo es requerido' : null;
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textoOscuro)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textoOscuro),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textoGris, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.primario),
            filled: true,
            fillColor: AppTheme.fondoTarjeta,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borde),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borde),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primario, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.peligro),
            ),
          ),
        ),
      ],
    );
  }
}
// Note: The above code defines the `EstablecimientoFormView` widget, which is used for both creating a new establishment and editing an existing one. It includes form fields for the establishment's name, NIT, address, and phone number, as well as a selector for the logo image. The form includes validation and error handling, and interacts with the `EstablecimientosService` to save the data to the backend API.
// Note: The above code defines the `EstablecimientoFormView` widget, which is used for both creating a new establishment and editing an existing one. It includes form fields for the establishment's name, NIT, address, and phone number, as well as a selector for the logo image. The form includes validation and error handling, and interacts with the `EstablecimientosService` to save the data to the backend API.