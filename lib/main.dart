
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/bluetooth_controller.dart';
import 'package:myapp/control_screen.dart';

// A provider to allow toggling the theme
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode for a professional feel

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => BluetoothController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A more professional and modern color seed
    const Color primarySeedColor = Colors.indigo;

    // Using a clean, modern font like Poppins
    final TextTheme appTextTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    // --- Base Button Style ---
    final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primarySeedColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: appTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
    );

    // --- Light Theme ---
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), // A gentle off-white
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: CardThemeData( // Corrected from CardTheme
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
    );

    // --- Dark Theme ---
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1C2A), // A deep, modern blue-grey
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: CardThemeData( // Corrected from CardTheme
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF26293D), // A slightly lighter container color
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'AutitoCar Control',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const ControlScreen(),
        );
      },
    );
  }
}
