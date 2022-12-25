import 'dart:async';
import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'bluetooth_entry_button.dart';

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice? device;
  _DeviceAvailability? availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability) : super(address: device!.address);
}

class ConnectionRoute extends StatefulWidget {
  const ConnectionRoute({Key? key}) : super(key: key);

  @override
  State<ConnectionRoute> createState() => _ConnectionRouteState();
}

class _ConnectionRouteState extends State<ConnectionRoute> with TickerProviderStateMixin {
  final bool checkAvailability = true;

  List<_DeviceWithAvailability> devices = [];

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;

  bool? _isDiscovering;

  // _ConnectionRoute();
  @override
  void initState() {
    super.initState();

    _isDiscovering = checkAvailability;

    if (_isDiscovering!) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                checkAvailability ? _DeviceAvailability.maybe : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var device = i.current;
          if (device.device == r.device) {
            device.availability = _DeviceAvailability.yes;
            device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices.map(
      (device) {
        // if (_device.device.name == 'HC-05') {
        //   return BluetoothDeviceListEntry(
        //     device: _device.device,
        //   );
        // }
        return BluetoothDeviceListEntry(
          device: device.device,
        );
      },
    ).toList();
    return Scaffold(
        body: AnimatedBackground(
      behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
        baseColor: Colors.grey[900]!,
        spawnOpacity: 0.0,
        opacityChangeRate: 0.25,
        minOpacity: 0.1,
        maxOpacity: 0.4,
        spawnMinSpeed: 50.0,
        spawnMaxSpeed: 120.0,
        spawnMinRadius: 7.0,
        spawnMaxRadius: 10.0,
        particleCount: 100,
      )),
      vsync: this,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: list,
        ),
      ),
    ));
  }
}
