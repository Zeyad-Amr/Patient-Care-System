import 'dart:typed_data';
import 'package:app/models/readings.dart';
import 'package:app/core/services/service.dart';
import 'package:app/ui/screens/heart_rate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.server}) : super(key: key);
  final BluetoothDevice? server;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothConnection? connection;
  String _messageBuffer = '';
  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;
  List<String> dataList = [];

  Readings readings = Readings(
    status: 0,
  );

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server!.address).then((connection) {
      debugPrint('Connected to the device');
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input!.listen(_onDataReceived).onData((data) {
        // Allocate buffer for parsed data
        int backspacesCounter = 0;
        for (var byte in data) {
          if (byte == 8 || byte == 127) {
            backspacesCounter++;
          }
        }
        Uint8List buffer = Uint8List(data.length - backspacesCounter);
        int bufferIndex = buffer.length;

        // Apply backspace control character
        backspacesCounter = 0;
        for (int i = data.length - 1; i >= 0; i--) {
          if (data[i] == 8 || data[i] == 127) {
            backspacesCounter++;
          } else {
            if (backspacesCounter > 0) {
              backspacesCounter--;
            } else {
              buffer[--bufferIndex] = data[i];
            }
          }
        }
        // Create message if there is new line character
        String dataString = String.fromCharCodes(buffer);
        dataList.add(dataString);

        debugPrint('data ${dataList.join()}');
        try {
          String x = dataList.join().split("@")[dataList.join().split("@").length - 2];
          List<String> data = x.split('*');
          if (data.length == 6) {
            setState(() {
              readings = Readings(status: int.parse(data[0]));
              debugPrint(readings.toString());
            });
          } else {
            debugPrint("Waiting ${data.length} ....");
            debugPrint(x.toString());
          }
        } catch (e) {
          debugPrint("Error $e");
        }

        if (isDisconnecting) {
          debugPrint('Disconnecting locally!');
        } else {
          debugPrint('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
      setState(() {});
    }).catchError((error) {
      debugPrint('Cannot connect, exception occured');
      debugPrint(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }

    super.dispose();
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Care System"),
        backgroundColor: Colors.grey[900],
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 15,
          ),
          child: Image.asset('assets/logo.png'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  try {
                    connection!.close();
                  } catch (e) {
                    debugPrint('$e');
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Services()));
                },
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.red,
                )),
          )
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: const HeartRateScreen(),
      ),
    );
  }
}
