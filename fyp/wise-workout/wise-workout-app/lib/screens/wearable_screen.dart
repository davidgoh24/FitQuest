import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:easy_localization/easy_localization.dart';

class WearableScreen extends StatefulWidget {
  const WearableScreen({Key? key}) : super(key: key);

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  final Health _health = Health();
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Text(
              'wearable_connect_title'.tr(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'wearable_connect_description'.tr(),
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildDeviceButton('HEALTH CONNECT'),
            if (_isConnected)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'wearable_connected_message'.tr(args: ['HEALTH CONNECT']),
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConnecting
                    ? null
                    : () => _isConnected
                        ? _disconnectDevice()
                        : _connectToDevice(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF071655),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isConnecting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isConnected
                            ? 'wearable_disconnect_button'.tr()
                            : 'wearable_connect_button'.tr(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'wearable_screen_title'.tr(),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(String deviceName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: _isConnected ? const Color(0xFFE6F0FF) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF3D7EFF)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          deviceName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isConnected
                ? const Color(0xFF3D7EFF)
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _connectToDevice() async {
    setState(() => _isConnecting = true);
    try {
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];
      final permissions = types.map((e) => HealthDataAccess.READ).toList();
      final isAuthorized =
          await _health.requestAuthorization(types, permissions: permissions);

      setState(() {
        _isConnected = isAuthorized;
        _isConnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isAuthorized
              ? 'wearable_connect_health_success'.tr()
              : 'wearable_connect_health_failure'.tr(),
        ),
      ));
    } catch (_) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('wearable_connection_failed'.tr())),
      );
    }
  }

  Future<void> _disconnectDevice() async {
    setState(() => _isConnecting = true);
    try {
      await _health.revokePermissions(); 
      setState(() {
        _isConnected = false; 
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'wearable_disconnect_success'.tr(args: ['HEALTH CONNECT']),
          ),
        ),
      );
    } catch (_) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('wearable_disconnect_failed'.tr())),
      );
    }
  }
}
