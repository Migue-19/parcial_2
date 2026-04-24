import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/establecimiento.dart';
import '../services/establecimientos_service.dart';
import '../views/home_view.dart';
import '../views/accidentes/accidentes_view.dart';
import '../views/establecimientos/establecimientos_list_view.dart';
import '../views/establecimientos/establecimiento_detail_view.dart';
import '../views/establecimientos/establecimiento_form_view.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/accidentes',
      name: 'accidentes',
      builder: (context, state) => const AccidentesView(),
    ),
    GoRoute(
      path: '/establecimientos',
      name: 'establecimientos-list',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    GoRoute(
      path: '/establecimientos/nuevo',
      name: 'establecimientos-create',
      builder: (context, state) =>
          const EstablecimientoFormView(establecimiento: null),
    ),
    GoRoute(
      path: '/establecimientos/:id',
      name: 'establecimientos-detail',
      builder: (context, state) {
        final est = state.extra;
        if (est is Establecimiento) {
          return EstablecimientoDetailView(establecimiento: est);
        }
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('ID inválido')),
          );
        }
        return _EstablecimientoLoader(id: id, editar: false);
      },
    ),
    GoRoute(
      path: '/establecimientos/:id/editar',
      name: 'establecimientos-edit',
      builder: (context, state) {
        final est = state.extra;
        if (est is Establecimiento) {
          return EstablecimientoFormView(establecimiento: est);
        }
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('ID inválido')),
          );
        }
        return _EstablecimientoLoader(id: id, editar: true);
      },
    ),
  ],
);

/// Carga un establecimiento por ID cuando no viene en `extra`
class _EstablecimientoLoader extends StatefulWidget {
  final int id;
  final bool editar;
  const _EstablecimientoLoader({required this.id, required this.editar});

  @override
  State<_EstablecimientoLoader> createState() => _EstablecimientoLoaderState();
}

class _EstablecimientoLoaderState extends State<_EstablecimientoLoader> {
  Establecimiento? _est;
  String? _error;

  @override
  void initState() {
    super.initState();
    EstablecimientosService().getOne(widget.id).then((e) {
      if (mounted) setState(() => _est = e);
    }).catchError((e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    if (_est == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (widget.editar) {
      return EstablecimientoFormView(establecimiento: _est);
    }
    return EstablecimientoDetailView(establecimiento: _est!);
  }
}
// Note: The above code defines the routing configuration for the application using the `go_router` package. It includes routes for the home view, accidents view, establishments list view, establishment detail view, and establishment form view (for both creating and editing). The `_EstablecimientoLoader` widget is used to fetch an establishment by ID when navigating to the detail or edit views without passing the establishment data in `extra`.