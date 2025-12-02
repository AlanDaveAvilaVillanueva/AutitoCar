
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/bluetooth_controller.dart';
import 'package:myapp/main.dart'; // Importing ThemeProvider

// Convert to a StatefulWidget to manage the slider's state
class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  double _speed = 200; // Default speed value (0-255)

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
              child: Consumer<BluetoothController>(
                builder: (context, controller, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStatusIndicator(context, controller.isConnected, isDarkMode),
                      const SizedBox(height: 30),
                      _buildConnectionButtons(context, controller),
                      const SizedBox(height: 40),
                      // Add the Speed Slider if connected
                      if (controller.isConnected)
                        _buildSpeedSlider(context, controller.sendData),
                      const SizedBox(height: 40),
                      _buildDirectionalControls(context, controller.isConnected, controller.sendData),
                      const SizedBox(height: 30),
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

  Widget _buildSpeedSlider(BuildContext context, Function(String) sendData) {
    return Column(
      children: [
        Text(
          'Velocidad',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _speed,
          min: 0,
          max: 255,
          divisions: 255,
          label: _speed.round().toString(),
          onChanged: (double value) {
            setState(() {
              _speed = value;
            });
          },
          // Send data only when the user finishes sliding
          onChangeEnd: (double value) {
            sendData('S:${value.round()}');
          },
        ),
      ],
    );
  }

  Widget _buildDirectionalControls(BuildContext context, bool isConnected, Function(String) sendData) {
    const double buttonSize = 90.0;
    const double borderRadius = 28.0;

    // Press and Hold action
    void handlePress(String direction) {
      if (isConnected) {
        sendData(direction);
      }
    }

    // Release action
    void handleRelease() {
      if (isConnected) {
        sendData('stop');
      }
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
          _buildControlButton(context, icon: Icons.arrow_upward, onPress: () => handlePress('forward'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
          _buildControlButton(context, icon: Icons.arrow_back, onPress: () => handlePress('left'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          // The center button is no longer needed
          Container(), 
          _buildControlButton(context, icon: Icons.arrow_forward, onPress: () => handlePress('right'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
          _buildControlButton(context, icon: Icons.arrow_downward, onPress: () => handlePress('backward'), onRelease: handleRelease, isEnabled: isConnected, size: buttonSize, borderRadius: borderRadius),
          Container(),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, {required IconData icon, required VoidCallback onPress, required VoidCallback onRelease, required bool isEnabled, required double size, required double borderRadius}) {
    final Color baseColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => onPress(),
      onTapUp: (_) => onRelease(),
      onTapCancel: () => onRelease(), // Also stop if the gesture is cancelled
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

  // Unchanged methods from here

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
            colors: [ indicatorColor.withOpacity(0.8), indicatorColor ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: Colors.white, size: 20),
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

  Widget _buildConnectionButtons(BuildContext context, BluetoothController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showDeviceList(context, controller),
          icon: const Icon(Icons.bluetooth_searching, size: 20),
          label: const Text('CONECTAR'),
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
              ),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: controller.isConnected ? controller.disconnect : null,
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

  void _showDeviceList(BuildContext context, BluetoothController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (kIsWeb) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Text(
                'La funcionalidad Bluetooth no está disponible en la vista previa web. Por favor, utiliza el emulador de Android para probar esta característica.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        controller.startScan();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (BuildContext context, ScrollController scrollController) {
            return Consumer<BluetoothController>(
              builder: (context, controller, child) {
                if (controller.isScanning && controller.devices.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text("Buscando dispositivos..."),
                      ],
                    ),
                  );
                }
                if (!controller.isScanning && controller.devices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No se encontraron dispositivos Bluetooth cercanos.", textAlign: TextAlign.center),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: controller.devices.length,
                  itemBuilder: (context, index) {
                    final device = controller.devices[index];
                    return ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: Text(device.name ?? 'Dispositivo Desconocido'),
                      subtitle: Text(device.id.toString()),
                      onTap: () {
                        controller.connectToDevice(device);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
