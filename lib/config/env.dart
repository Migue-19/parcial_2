import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const String _defaultBaseUrl = 'https://www.datos.gov.co/resource';
  static const String _defaultParkingUrl = 'https://parking.visiontic.com.co/api';

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? _defaultBaseUrl;
    return url.isEmpty ? _defaultBaseUrl : url;
  }

  static String get parkingUrl {
    final url = dotenv.env['PARKING_URL'] ?? _defaultParkingUrl;
    return url.isEmpty ? _defaultParkingUrl : url;
  }
}
