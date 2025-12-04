import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/control_screen.dart';
import 'package:http/http.dart' as http;

// Provider para gestionar el estado de la conexión WiFi
class ConnectionProvider with ChangeNotifier {
  bool _isConnected = false;
  final String _host = "192.168.1.100"; // IP del host de Arduino (ajustar si es necesario)

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      // Intenta hacer una petición simple para verificar la conexión
      final response = await http.get(Uri.parse('http://$_host/'));
      if (response.statusCode == 200) {
        _isConnected = true;
      } else {
        _isConnected = false;
      }
    } catch (e) {
      _isConnected = false;
    }
    notifyListeners();
  }

  void disconnect() {
    _isConnected = false;
    notifyListeners();
  }

  // Método para enviar comandos al Arduino
  Future<void> sendCommand(String command) async {
    if (_isConnected) {
      try {
        await http.get(Uri.parse('http://$_host/control?command=$command'));
      } catch (e) {
        // Manejar errores de envío si es necesario
        print('Error al enviar comando: $e');
      }
    }
  }
}

// Provider para el tema de la aplicación
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

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
        ChangeNotifierProvider(create: (context) => ConnectionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.indigo;
    final TextTheme appTextTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

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

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.dark),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1C2A),
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF26293D),
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
