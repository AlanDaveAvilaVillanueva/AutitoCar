import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/control_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'dart:async';

// Provider para gestionar el estado de la conexión con Firebase
class ConnectionProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  
  bool _isConnected = false;
  User? _user;
  late StreamSubscription<User?> _authStateSubscription;

  bool get isConnected => _isConnected;

  ConnectionProvider() {
    // Escuchar los cambios en el estado de autenticación
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isConnected = (user != null);
      
      if (_isConnected) {
        // Marcar el estado como 'connected' en la base de datos cuando el usuario se autentica
        _databaseRef.child('status').set('connected');
        // Asegurarse de que al desconectarse, el estado cambie
        _databaseRef.child('status').onDisconnect().set('disconnected');
      }
      
      notifyListeners();
    });
  }

  // Conectar usando autenticación anónima
  Future<void> connect() async {
    try {
      if (_user == null) {
        await _auth.signInAnonymously();
      }
    } catch (e) {
      print("Error al conectar anónimamente: $e");
    }
    // El listener de authStateChanges se encargará de notificar a los widgets
  }

  // Desconectar
  Future<void> disconnect() async {
    try {
      await _auth.signOut();
      // El listener de authStateChanges se encargará de notificar a los widgets
    } catch (e) {
      print("Error al desconectar: $e");
    }
  }

  // Método para enviar comandos a la Realtime Database
  Future<void> sendCommand(String command) async {
    if (_isConnected) {
      try {
        // Usamos push() para crear una lista de comandos y no sobreescribir el último
        await _databaseRef.child('control/command').set(command);
        print("Comando '$command' enviado.");
      } catch (e) {
        print("Error al enviar comando a Firebase: $e");
      }
    } else {
      print("No se puede enviar el comando, no hay conexión a Firebase.");
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
