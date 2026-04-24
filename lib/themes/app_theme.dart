import 'package:flutter/material.dart';

class AppTheme {
  // Paleta dark mode moderna
  static const Color primario    = Color(0xFF6C63FF); // violeta vibrante
  static const Color acento      = Color(0xFF00D4AA); // teal / verde menta
  static const Color peligro     = Color(0xFFFF5C7C); // rojo suave
  static const Color fondo       = Color(0xFF0F0F1A); // negro azulado
  static const Color fondoTarjeta= Color(0xFF1A1A2E); // azul muy oscuro
  static const Color superficie  = Color(0xFF16213E); // azul marino oscuro
  static const Color borde       = Color(0xFF2A2A4A); // borde sutil
  static const Color textoOscuro = Color(0xFFEAEAFF); // blanco azulado
  static const Color textoGris   = Color(0xFF8B8BAD); // gris violáceo

  // Alias para compatibilidad con referencias existentes en el código
  static const Color amarillo = acento;
  static const Color azul     = primario;
  static const Color rojo     = peligro;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primario,
        primary: primario,
        secondary: acento,
        tertiary: peligro,
        surface: superficie,
        onPrimary: Colors.white,
        onSecondary: fondo,
      ),
      scaffoldBackgroundColor: fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: fondoTarjeta,
        foregroundColor: textoOscuro,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textoOscuro,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: textoOscuro),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: fondoTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borde, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textoOscuro,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textoOscuro,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textoOscuro,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textoGris,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: textoGris,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borde,
        thickness: 1,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: primario),
    );
  }
}
