class AccidentesStats {
  /// Distribución por clase de accidente
  final Map<String, int> porClase;

  /// Distribución por gravedad
  final Map<String, int> porGravedad;

  /// Top 5 barrios con más accidentes
  final Map<String, int> topBarrios;

  /// Distribución por día de la semana
  final Map<String, int> porDia;

  /// Total de registros procesados
  final int total;

  const AccidentesStats({
    required this.porClase,
    required this.porGravedad,
    required this.topBarrios,
    required this.porDia,
    required this.total,
  });

  factory AccidentesStats.fromMap(Map<String, dynamic> map) {
    Map<String, int> parseIntMap(dynamic value) {
      if (value is! Map) return <String, int>{};
      return value.map(
        (k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0),
      );
    }

    return AccidentesStats(
      porClase: parseIntMap(map['porClase']),
      porGravedad: parseIntMap(map['porGravedad']),
      topBarrios: parseIntMap(map['topBarrios']),
      porDia: parseIntMap(map['porDia']),
      total: int.tryParse(map['total'].toString()) ?? 0,
    );
  }
}
