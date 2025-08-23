import 'package:flutter/foundation.dart';

class WearableService {
  Future<bool> connectDevice(String deviceName) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate connection time

    return true;
  }

  // Get available devices (mock data)
  Future<List<String>> getAvailableDevices() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return ['SAMSUNG', '@WATCH']; // Your device list
  }

  // Check connection status
  Future<bool> isDeviceConnected(String deviceName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return false; // Default to not connected
  }
}