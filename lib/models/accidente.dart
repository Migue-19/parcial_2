class Accidente {
  final String claseAccidente;
  final String gravedadAccidente;
  final String barrioHecho;
  final String dia;
  final String hora;
  final String area;
  final String claseVehiculo;

  const Accidente({
    required this.claseAccidente,
    required this.gravedadAccidente,
    required this.barrioHecho,
    required this.dia,
    required this.hora,
    required this.area,
    required this.claseVehiculo,
  });

  factory Accidente.fromJson(Map<String, dynamic> json) {
    return Accidente(
      claseAccidente: json['clase_de_accidente']?.toString() ?? 'Otro',
      gravedadAccidente:
          json['gravedad_del_accidente']?.toString() ?? 'Desconocido',
      barrioHecho: json['barrio_hecho']?.toString() ?? 'Desconocido',
      dia: json['dia']?.toString() ?? 'Desconocido',
      hora: json['hora']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      claseVehiculo: json['clase_de_vehiculo']?.toString() ?? '',
    );
  }
}
