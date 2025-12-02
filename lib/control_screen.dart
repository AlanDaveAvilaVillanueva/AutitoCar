
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/bluetooth_controller.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Control'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<BluetoothController>(
            builder: (context, controller, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusIndicator(context, controller.isConnected),
                  const SizedBox(height: 20),
                  _buildConnectionButtons(context, controller),
                  const SizedBox(height: 40), // Adjusted for better spacing
                  _buildDirectionalControls(context, controller.isConnected, controller.sendData),
                  const SizedBox(height: 40), // Adjusted for better spacing
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, bool isConnected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green.shade600 : Colors.red.shade600,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? 'CONECTADO' : 'DESCONECTADO',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionButtons(BuildContext context, BluetoothController controller) {
    final ButtonStyle? defaultStyle = Theme.of(context).elevatedButtonTheme.style;
    final ButtonStyle disconnectStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }
          return Colors.red;
        },
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _showDeviceList(context, controller),
          child: const Text('CONECTAR'),
        ),
        ElevatedButton(
          onPressed: controller.isConnected ? controller.disconnect : null,
          style: defaultStyle?.merge(disconnectStyle),
          child: const Text('DESCONECTAR'),
        ),
      ],
    );
  }

  void _showDeviceList(BuildContext context, BluetoothController controller) {
    controller.startScan();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<BluetoothController>(
          builder: (context, controller, child) {
            return ListView.builder(
              itemCount: controller.devices.length,
              itemBuilder: (context, index) {
                final device = controller.devices[index];
                return ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
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
  }

  Widget _buildDirectionalControls(BuildContext context, bool isConnected, Function(String) sendData) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(context, icon: Icons.arrow_upward, onPressed: isConnected ? () => sendData('forward') : null),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(context, icon: Icons.arrow_back, onPressed: isConnected ? () => sendData('left') : null),
            const SizedBox(width: 80),
            _buildControlButton(context, icon: Icons.arrow_forward, onPressed: isConnected ? () => sendData('right') : null),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(context, icon: Icons.arrow_downward, onPressed: isConnected ? () => sendData('backward') : null),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context, {required IconData icon, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
      child: Icon(icon, size: 32),
    );
  }
}
