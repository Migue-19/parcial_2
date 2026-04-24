import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
    debugPrint('✓ .env cargado correctamente');
    debugPrint('BASE_URL: ${dotenv.env['BASE_URL']}');
    debugPrint('PARKING_URL: ${dotenv.env['PARKING_URL']}');
  } catch (e) {
    debugPrint('✗ Error cargando .env: $e');
    debugPrint('Usando URLs por defecto');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parcial Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
