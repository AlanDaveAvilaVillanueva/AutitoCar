import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/main.dart'; // Importa ConnectionProvider y ThemeProvider

// Pantalla principal de control
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  // Método para enviar un comando a través del ConnectionProvider
  void _sendCommand(BuildContext context, String command) {
    Provider.of<ConnectionProvider>(context, listen: false).sendCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutitoCar Control'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF1A1C2A), const Color(0xFF202333)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE8EDF2)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Center(
              child: Consumer<ConnectionProvider>(
                builder: (context, connection, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStatusIndicator(context, connection.isConnected, isDarkMode),
                      const SizedBox(height: 30),
                      _buildConnectionButtons(context, connection),
                      const SizedBox(height: 40),
                      _buildDirectionalControls(context, connection.isConnected),
                      const SizedBox(height: 30),
                      _buildExtraControls(context, connection.isConnected),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el indicador de estado de conexión
  Widget _buildStatusIndicator(BuildContext context, bool isConnected, bool isDarkMode) {
    final Color connectedColor = Colors.green.shade400;
    final Color disconnectedColor = Colors.red.shade400;
    final Color indicatorColor = isConnected ? connectedColor : disconnectedColor;

    return Card(
      elevation: 8,
      shadowColor: indicatorColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [indicatorColor.withOpacity(0.8), indicatorColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isConnected ? Icons.wifi : Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              isConnected ? 'CONECTADO' : 'DESCONECTADO',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los botones de conexión y desconexión
  Widget _buildConnectionButtons(BuildContext context, ConnectionProvider connection) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: connection.isConnected ? null : () => connection.connect(),
          icon: const Icon(Icons.wifi_tethering, size: 20),
          label: const Text('CONECTAR'),
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.disabled)) return Colors.grey.shade600;
                  return Theme.of(context).colorScheme.primary;
                }),
              ),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: connection.isConnected ? () => connection.disconnect() : null,
          icon: const Icon(Icons.power_settings_new, size: 20),
          label: const Text('APAGAR'),
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.disabled)) return Colors.grey.shade600;
                  return Theme.of(context).colorScheme.error;
                }),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
        ),
      ],
    );
  }

  // Widget para los controles direccionales
  Widget _buildDirectionalControls(BuildContext context, bool isConnected) {
    const double buttonSize = 90.0;
    const double borderRadius = 28.0;

    void handlePress(String direction) {
      if (isConnected) _sendCommand(context, direction);
    }

    void handleRelease() {
      if (isConnected) _sendCommand(context, 'stop'); // Enviar 'stop' al soltar
    }

    return SizedBox(
      width: (buttonSize * 3) + (14 * 2),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(),
          _buildControlButton(context, icon: Icons.arrow_upward, onPress: () => handlePress('W'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
          _buildControlButton(context, icon: Icons.arrow_back, onPress: () => handlePress('A'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
          _buildControlButton(context, icon: Icons.arrow_forward, onPress: () => handlePress('D'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
          _buildControlButton(context, icon: Icons.arrow_downward, onPress: () => handlePress('S'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
        ],
      ),
    );
  }

  // Widget para los botones de acción adicionales (bocina, luces)
  Widget _buildExtraControls(BuildContext context, bool isConnected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(context, icon: Icons.volume_up, command: 'H', isEnabled: isConnected, label: 'Bocina'),
        const SizedBox(width: 20),
        _buildActionButton(context, icon: Icons.lightbulb, command: 'L', isEnabled: isConnected, label: 'Luz'),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String command, required bool isEnabled, required String label}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (isEnabled) _sendCommand(context, command);
          },
          child: CircleAvatar(
            radius: 35,
            backgroundColor: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }


  // Widget reutilizable para un botón de control
  Widget _buildControlButton(BuildContext context, {required IconData icon, required VoidCallback onPress, required VoidCallback onRelease, required bool isEnabled, required double size, required double borderRadius}) {
    final Color baseColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => onPress(),
      onTapUp: (_) => onRelease(),
      onTapCancel: () => onRelease(),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(4, 4),
              )
            ]),
        child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isEnabled
                      ? [baseColor.withOpacity(0.85), baseColor]
                      : [Colors.grey.shade700, Colors.grey.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, color: Colors.white, size: size * 0.5)),
          ),
      ),
    );
  }
}
