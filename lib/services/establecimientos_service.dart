import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../config/env.dart';
import '../models/establecimiento.dart';

class EstablecimientosService {
  /// En web las rutas van como query param adicional del proxy,
  /// así que el baseUrl ya contiene la URL completa de la API.
  /// Necesitamos construir la URL final de forma diferente en web.
  String _buildUrl(String path) {
    if (kIsWeb) {
      final encoded = Uri.encodeComponent('${Env.parkingUrl}$path');
      return 'https://corsproxy.io/?url=$encoded';
    }
    return path;
  }

  Dio get _dio => Dio(BaseOptions(
        baseUrl: kIsWeb ? '' : Env.parkingUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ));

  String get _base => '/establecimientos';

  Future<MultipartFile> _buildLogoPart(XFile logo) async {
    if (kIsWeb) {
      final bytes = await logo.readAsBytes();
      return MultipartFile.fromBytes(
        bytes,
        filename: logo.name.isNotEmpty ? logo.name : 'logo.jpg',
      );
    }

    final filename = logo.path.split(RegExp(r'[\\/]')).last;
    return MultipartFile.fromFile(logo.path, filename: filename);
  }

  /// GET /establecimientos
  Future<List<Establecimiento>> getAll() async {
    try {
      final url = _buildUrl(_base);
      print('GET $_base');
      print('URL completa: $url');

      final response = await _dio.get<dynamic>(url);

      print('Status: ${response.statusCode}');
      print('Tipo de data: ${response.data.runtimeType}');

      final dataStr = response.data.toString();
      print('Data: ${dataStr.substring(0, (dataStr.length).clamp(0, 1000))}');

      final parsed = _parsearLista(response.data);
      print('✓ Total de establecimientos obtenidos: ${parsed.length}');
      return parsed;
    } on DioException catch (e) {
      print('✗ DioException en getAll');
      print('   tipo: ${e.type}');
      print('   mensaje: ${e.message}');
      print('   statusCode: ${e.response?.statusCode}');
      print('   responseData: ${e.response?.data}');
      print('   URL: ${e.requestOptions.uri}');
      throw _manejarError(e);
    } catch (e, stack) {
      print('✗ Error inesperado en getAll: $e');
      print(stack);
      throw Exception('Error inesperado: $e');
    }
  }

  List<Establecimiento> _parsearLista(dynamic data) {
    List<dynamic> list;

    const knownListKeys = [
      'data', 'establecimientos', 'estacionamientos', 'parking',
      'result', 'results', 'items', 'rows', 'records',
    ];

    if (data is List) {
      list = data;
      print('✓ Data es una lista directa con ${data.length} elementos');
    } else if (data is Map) {
      print('Data es un Map con keys: ${data.keys.toList()}');

      List<dynamic>? found;
      for (final key in knownListKeys) {
        if (data.containsKey(key) && data[key] is List) {
          found = data[key] as List<dynamic>;
          print('✓ Lista encontrada en key "$key" con ${found.length} elementos');
          break;
        }
      }
      if (found == null) {
        for (final entry in data.entries) {
          if (entry.value is List) {
            found = entry.value as List<dynamic>;
            print('Lista encontrada en clave "${entry.key}" con ${found.length} elementos.');
            break;
          }
        }
      }

      list = found ?? [];
      if (found == null) {
        print('No se encontró lista en la respuesta Map. Keys: ${data.keys.toList()}');
      }
    } else {
      list = [];
      print('Formato de respuesta desconocido: ${data.runtimeType}');
    }

    print('Intentando parsear ${list.length} establecimientos...');

    final parsed = <Establecimiento>[];
    for (int i = 0; i < list.length; i++) {
      try {
        final item = list[i];
        final Map<String, dynamic> map;
        if (item is Map<String, dynamic>) {
          map = item;
        } else if (item is Map) {
          map = Map<String, dynamic>.from(item);
        } else {
          print('Item $i no es un Map: ${item.runtimeType}');
          continue;
        }
        parsed.add(Establecimiento.fromJson(map));
      } catch (e) {
        print('✗ Error parseando item $i: $e');
      }
    }

    print('✓ ${parsed.length} establecimientos parseados exitosamente');
    return parsed;
  }

  /// GET /establecimientos/{id}
  Future<Establecimiento> getOne(int id) async {
    try {
      final url = _buildUrl('$_base/$id');
      print('GET $_base/$id');
      final response = await _dio.get<dynamic>(url);
      final data = response.data;
      print('getOne data: $data');

      if (data is Map && data.containsKey('data')) {
        return Establecimiento.fromJson(data['data'] as Map<String, dynamic>);
      }
      return Establecimiento.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _manejarError(e);
    }
  }

  /// POST /establecimientos (multipart/form-data)
  Future<void> create({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    XFile? logo,
  }) async {
    try {
      final url = _buildUrl(_base);
      print('POST $_base');
      final map = <String, dynamic>{
        'nombre': nombre,
        'nit': nit,
        'direccion': direccion,
        'telefono': telefono,
      };
      if (logo != null) {
        map['logo'] = await _buildLogoPart(logo);
      }

      final formData = FormData.fromMap(map);
      final response = await _dio.post(url, data: formData);
      print('✓ Crear status: ${response.statusCode}');
      print('✓ Crear response: ${response.data}');

      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception('La API no confirmó la creación. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('✗ Error al crear: ${e.response?.statusCode} — ${e.response?.data}');
      print('✗ URL intentada: ${e.requestOptions.uri}');
      throw _manejarError(e);
    }
  }

  /// POST /establecimiento-update/{id} (_method=PUT, multipart/form-data)
  Future<void> update({
    required int id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    XFile? logo,
  }) async {
    final map = <String, dynamic>{
      '_method': 'PUT',
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
    };
    if (logo != null) {
      map['logo'] = await _buildLogoPart(logo);
    }

    final formData = FormData.fromMap(map);

    try {
      final url = _buildUrl('/establecimiento-update/$id');
      print('POST /establecimiento-update/$id');
      final response = await _dio.post(url, data: formData);
      print('✓ Update status: ${response.statusCode}');

      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception('La API no confirmó la actualización. Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final firstStatus = e.response?.statusCode ?? 0;
      if (firstStatus == 404 || firstStatus == 405) {
        final fallbackUrl = _buildUrl('$_base/$id');
        print('⚠️ Fallback update: POST $_base/$id con _method=PUT');
        try {
          final response = await _dio.post(fallbackUrl, data: formData);
          print('✓ Update fallback status: ${response.statusCode}');
          if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
            throw Exception('La API no confirmó la actualización. Código: ${response.statusCode}');
          }
          return;
        } on DioException catch (fallbackError) {
          print('✗ Error fallback update: ${fallbackError.response?.statusCode} — ${fallbackError.response?.data}');
          print('✗ URL fallback: ${fallbackError.requestOptions.uri}');
          throw _manejarError(fallbackError);
        }
      }

      print('✗ Error al actualizar: ${e.response?.statusCode} — ${e.response?.data}');
      print('✗ URL intentada: ${e.requestOptions.uri}');
      throw _manejarError(e);
    }
  }

  /// DELETE /establecimientos/{id}
  Future<void> delete(int id) async {
    try {
      final url = _buildUrl('$_base/$id');
      print('DELETE $_base/$id');
      final response = await _dio.delete(url);
      print('✓ Delete status: ${response.statusCode}');
    } on DioException catch (e) {
      print('✗ Error al eliminar: ${e.response?.statusCode} — ${e.response?.data}');
      print('✗ URL intentada: ${e.requestOptions.uri}');
      throw _manejarError(e);
    }
  }

  Exception _manejarError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de conexión agotado. Verifica tu internet.');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final msg = e.response?.data?.toString() ?? 'Sin detalle';
        if (status == 401 || status == 403) {
          return Exception('Acceso denegado ($status). La API puede requerir autenticación.');
        }
        if (status == 404) {
          return Exception('Recurso no encontrado (404). URL: ${e.requestOptions.uri}');
        }
        return Exception('Error del servidor ($status): $msg');
      case DioExceptionType.connectionError:
        return Exception(
          'No se pudo conectar al servidor.\n'
          'URL: ${e.requestOptions.uri}\n'
          'Detalle: ${e.message}',
        );
      case DioExceptionType.badCertificate:
        return Exception('Certificado SSL inválido. Contacta al administrador.');
      case DioExceptionType.cancel:
        return Exception('Petición cancelada.');
      default:
        return Exception('Error de red (${e.type}): ${e.message}');
    }
  }
}