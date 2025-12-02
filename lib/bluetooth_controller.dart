
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothController with ChangeNotifier {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothConnectionState get connectionState => _connectionState;

  bool get isConnected => _connectionState == BluetoothConnectionState.connected;

  // --- Scanning --- 
  Future<void> startScan() async {
    _devices.clear();
    notifyListeners();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      _devices = results.map((r) => r.device).toList();
      notifyListeners();
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // --- Connection ---
  Future<void> connectToDevice(BluetoothDevice device) async {
    stopScan();
    
    _connectionStateSubscription = device.connectionState.listen((state) {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _connectedDevice = device;
      } else {
        _connectedDevice = null;
      }
      notifyListeners();
    });

    try {
      await device.connect();
    } catch (e) {
      developer.log('Error connecting to device', error: e);
    }
  }

  Future<void> disconnect() async {
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _connectionState = BluetoothConnectionState.disconnected;
    notifyListeners();
  }

  // --- Sending Data ---
  Future<void> sendData(String data) async {
    if (!isConnected || _connectedDevice == null) return;

    // Discover services and characteristics
    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    
    // Find the correct service and characteristic for your Arduino
    // This is a placeholder - you MUST replace the UUIDs with your actual ones.
    try {
      var targetService = services.firstWhere((s) => s.uuid.toString() == 'YOUR_SERVICE_UUID');
      var targetCharacteristic = targetService.characteristics.firstWhere((c) => c.uuid.toString() == 'YOUR_CHARACTERISTIC_UUID');
      
      // Write the data
      await targetCharacteristic.write(data.codeUnits);
    } catch (e) {
      developer.log('Error sending data', error: e);
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
