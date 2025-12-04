import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/control_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'dart:async';

// --- Gestor de Estado para la Conexión con CONEXIÓN MANUAL ---
class ConnectionProvider with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _anonymousUser;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // El constructor ahora está vacío, no se conecta automáticamente
  ConnectionProvider();

  // MÉTODO PARA CONECTAR MANUALMENTE
  Future<void> connect() async {
    if (isConnected) return; // Si ya está conectado, no hace nada
    try {
      // Inicia sesión de forma anónima para esta sesión de control
      UserCredential userCredential = await _auth.signInAnonymously();
      _anonymousUser = userCredential.user;
      print("Sesión anónima iniciada: ${_anonymousUser?.uid}");

      // Una vez autenticado, configura el estado en la base de datos
      await _databaseRef.child('status').set('connected');
      await _databaseRef.child('status').onDisconnect().set('disconnected');

      _isConnected = true;
      print("Conexión con Realtime Database establecida.");
    } catch (e) {
      _isConnected = false;
      print("Error al conectar: $e");
    }
    notifyListeners();
  }

  // MÉTODO PARA DESCONECTAR MANUALMENTE
  Future<void> disconnect() async {
    if (!isConnected) return; // Si no está conectado, no hace nada
    try {
      // Actualiza el estado en la base de datos antes de desconectar
      await _databaseRef.child('status').set('disconnected');
      if (_anonymousUser != null) {
        // Cierra la sesión anónima actual
        await _auth.signOut();
        _anonymousUser = null;
        print("Sesión anónima cerrada.");
      }
       _isConnected = false;
       print("Conexión con Realtime Database terminada.");
    } catch (e) {
      print("Error al desconectar: $e");
    }
    notifyListeners();
  }

  Future<void> sendCommand(String command) async {
    if (isConnected) {
      try {
        await _databaseRef.child('control/command').set(command);
        print("Comando '$command' enviado.");
      } catch (e) {
        print("Error al enviar comando: $e");
      }
    } else {
      print("No se puede enviar el comando, no hay conexión.");
    }
  }

   @override
  void dispose() {
    // Asegurarse de desconectar si el provider se destruye
    if(isConnected) {
      disconnect();
    }
    super.dispose();
  }
}

// --- Gestor de Estado para el Tema ---
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// --- Punto de Entrada Principal ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// --- Widget Raíz ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.indigo;
    final TextTheme appTextTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.dark),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(titleTextStyle: appTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
    );

    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AutitoCar Control',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// --- Widget de Envoltura de Autenticación ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Este StreamBuilder sigue controlando el login principal (Email/Password)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si el snapshot tiene un usuario Y NO es anónimo, es el usuario principal
        if (snapshot.hasData && !snapshot.data!.isAnonymous) {
          // Proveemos el ConnectionProvider a la pantalla de control
          return ChangeNotifierProvider(
            create: (context) => ConnectionProvider(),
            child: const ControlScreen(),
          );
        }
        
        // En cualquier otro caso (sin usuario, o solo un usuario anónimo residual), muestra el login
        return const LoginScreen();
      },
    );
  }
}
