
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothController with ChangeNotifier {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  bool _isScanning = false;

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothConnectionState get connectionState => _connectionState;
  bool get isScanning => _isScanning;

  bool get isConnected => _connectionState == BluetoothConnectionState.connected;

  BluetoothController() {
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      Future.microtask(() => notifyListeners());
    });
  }

  // --- Scanning --- 
  Future<void> startScan() async {
    _devices.clear();
    Future.microtask(() => notifyListeners());

    // The isScanning stream will notify listeners of state changes
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    
    FlutterBluePlus.scanResults.listen((results) {
      // Use a Set to avoid duplicates, then convert back to a List
      final newDevices = <BluetoothDevice>{};
      for (var r in results) {
        newDevices.add(r.device);
      }
      _devices = newDevices.toList();
      Future.microtask(() => notifyListeners());
    }, onError: (e) => developer.log('Error listening to scan results', error: e));
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // --- Connection ---
  Future<void> connectToDevice(BluetoothDevice device) async {
    stopScan();
    
    _connectionStateSubscription?.cancel(); // Cancel any previous subscription
    _connectionStateSubscription = device.connectionState.listen((state) {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _connectedDevice = device;
      } else {
        if (_connectedDevice == device) { // Only clear if it's the same device disconnecting
           _connectedDevice = null;
        }
      }
      Future.microtask(() => notifyListeners());
    });

    try {
      await device.connect(timeout: const Duration(seconds: 15));
    } catch (e) {
      developer.log('Error connecting to device', error: e);
      _connectionStateSubscription?.cancel();
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _connectedDevice = null;
    _connectionState = BluetoothConnectionState.disconnected;
    Future.microtask(() => notifyListeners());
  }

  // --- Sending Data ---
  Future<void> sendData(String data) async {
    if (!isConnected || _connectedDevice == null) {
      developer.log('Not connected, cannot send data.');
      return;
    }
    
    try {
      // Discover services - this is crucial!
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      
      // *******************************************************************
      // !! URGENTE: DEBES REEMPLAZAR ESTOS VALORES UUID !!
      // Busca los UUIDs correctos para tu módulo Bluetooth (HC-05, etc.)
      // *******************************************************************
      const String serviceUUID = "00001101-0000-1000-8000-00805f9b34fb"; // UUID estándar para SPP
      const String characteristicUUID = "00001101-0000-1000-8000-00805f9b34fb";

      var targetService = services.firstWhere((s) => s.uuid.toString().toLowerCase() == serviceUUID);
      var targetCharacteristic = targetService.characteristics.firstWhere((c) => c.uuid.toString().toLowerCase() == characteristicUUID);
      
      // Write the data as a list of bytes
      await targetCharacteristic.write(data.codeUnits, withoutResponse: true);
       developer.log('Sent data: $data');
    } catch (e) {
      developer.log('Error sending data: Service/Characteristic not found or write failed.', error: e);
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    _isScanningSubscription?.cancel();
    super.dispose();
  }
}
