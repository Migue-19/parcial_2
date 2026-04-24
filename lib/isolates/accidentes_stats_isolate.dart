Map<String, dynamic> calcularStatsAccidentesIsolate(
  List<Map<String, dynamic>> registros,
) {
  final startMs = DateTime.now().millisecondsSinceEpoch;
  print('[Isolate] Iniciado — ${registros.length} registros recibidos');

  final porClase = <String, int>{};
  final porGravedad = <String, int>{};
  final porBarrio = <String, int>{};
  final porDia = <String, int>{};

  for (final row in registros) {
    final clase = _normalizarClase(row['clase_de_accidente']?.toString() ?? '');
    porClase[clase] = (porClase[clase] ?? 0) + 1;

    final gravedad =
        _normalizarGravedad(row['gravedad_del_accidente']?.toString() ?? '');
    porGravedad[gravedad] = (porGravedad[gravedad] ?? 0) + 1;

    final barrioRaw = (row['barrio_hecho']?.toString() ?? '').trim();
    final barrio = barrioRaw.isEmpty ? 'Desconocido' : barrioRaw;
    porBarrio[barrio] = (porBarrio[barrio] ?? 0) + 1;

    final dia = _normalizarDia(row['dia']?.toString() ?? 'Desconocido');
    porDia[dia] = (porDia[dia] ?? 0) + 1;
  }

  final sortedBarrios = porBarrio.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topBarrios = Map<String, int>.fromEntries(sortedBarrios.take(5));

  final diasOrden = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  final porDiaOrdenado = <String, int>{};
  for (final dia in diasOrden) {
    if (porDia.containsKey(dia)) {
      porDiaOrdenado[dia] = porDia[dia]!;
    }
  }
  for (final entry in porDia.entries) {
    if (!porDiaOrdenado.containsKey(entry.key)) {
      porDiaOrdenado[entry.key] = entry.value;
    }
  }

  final elapsedMs = DateTime.now().millisecondsSinceEpoch - startMs;
  print('[Isolate] Completado en $elapsedMs ms');

  return {
    'porClase': porClase,
    'porGravedad': porGravedad,
    'topBarrios': topBarrios,
    'porDia': porDiaOrdenado,
    'total': registros.length,
  };
}

String _normalizarClase(String clase) {
  final lower = clase.toLowerCase();
  if (lower.contains('choque')) return 'Choque';
  if (lower.contains('atropello')) return 'Atropello';
  if (lower.contains('volcamiento')) return 'Volcamiento';
  return 'Otros';
}

String _normalizarGravedad(String gravedad) {
  final lower = gravedad.toLowerCase();
  if (lower.contains('muerto') || lower.contains('fatal')) return 'Con muertos';
  if (lower.contains('herido')) return 'Con heridos';
  if (lower.contains('dano') || lower.contains('da\u00f1o')) return 'Solo danos';
  return 'Solo danos';
}

String _normalizarDia(String dia) {
  final lower = dia.toLowerCase().trim();
  const mapa = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miercoles',
    'mi\u00e9rcoles': 'Miercoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sabado',
    's\u00e1bado': 'Sabado',
    'domingo': 'Domingo',
  };
  return mapa[lower] ?? 'Desconocido';
}
