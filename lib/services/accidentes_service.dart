import 'dart:isolate';
import 'package:dio/dio.dart';
import '../config/env.dart';
import '../models/accidente.dart';
import '../models/accidentes_stats.dart';
import '../isolates/accidentes_stats_isolate.dart';

class AccidentesService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Accept': 'application/json'},
  ));

  Future<List<Map<String, dynamic>>> fetchAccidentesRaw() async {
    try {
      final url = '${Env.baseUrl}/ezt8-5wyj.json';
      print('📥 Solicitando accidentes desde: $url');

      final response = await _dio.get<dynamic>(
        url,
        queryParameters: {'\$limit': '100000'},
      );

      final data = response.data;
      final List<dynamic> lista = data is List ? data : <dynamic>[];
      final registros = lista
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      print('✓ ${registros.length} accidentes obtenidos');
      return registros;
    } on DioException catch (e) {
      print('✗ Error en AccidentesService: ${e.message}');
      print('   Tipo: ${e.type}');
      throw Exception('Error al obtener accidentes: ${e.message}');
    } catch (e) {
      print('✗ Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  Future<List<Accidente>> fetchAccidentes() async {
    final registros = await fetchAccidentesRaw();
    return registros.map(Accidente.fromJson).toList();
  }

  Future<AccidentesStats> computeStats(List<Map<String, dynamic>> registros) async {
    print('🚀 Iniciando procesamiento con Isolate.run()...');
    try {
      final result = await Isolate.run(
        () => calcularStatsAccidentesIsolate(registros),
      );
      return AccidentesStats.fromMap(result);
    } catch (e) {
      print('⚠️  Fallback al hilo principal: $e');
      final result = calcularStatsAccidentesIsolate(registros);
      return AccidentesStats.fromMap(result);
    }
  }
}