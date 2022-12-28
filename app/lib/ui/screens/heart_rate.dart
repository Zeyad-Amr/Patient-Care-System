import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  List<int> filteredData = [];
  List<SensorValue> data = [];
  double heartSize = 30;
  bool enableHBPM = false;

  List<SensorValue> bpmValues = [SensorValue(time: DateTime.now(), value: 0)];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 100), ((timer) {
      setState(() {
        if (heartSize < 35) {
          heartSize += 0.5;
        } else {
          heartSize = 30;
        }
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          !enableHBPM
              ? const SizedBox()
              : HeartBPMDialog(
                  context: context,
                  onRawData: (value) {
                    setState(() {
                      if (data.length >= 100) data.removeAt(0);
                      data.add(value);
                    });
                  },
                  onBPM: (value) {
                    debugPrint('XXXX $value');
                    if (value > 50 && value < 100) {
                      filteredData.add(value);
                    }
                    if (filteredData.length > 10) {
                      int avg = filteredData.reduce((a, b) => a + b) ~/ filteredData.length;
                      setState(() {
                        bpmValues.add(SensorValue(value: avg, time: DateTime.now()));
                        filteredData.clear();
                      });
                    }
                    setState(() {
                      if (bpmValues.length >= 100) bpmValues.removeAt(0);
                    });
                  },
                  sampleDelay: 1000 ~/ 20,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.08,
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: heartSize,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Heart BPM:", style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(" ${bpmValues.last.value.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 30, color: Colors.white)),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: enableHBPM ? Colors.red : Colors.white,
                        foregroundColor: enableHBPM ? Colors.white : Colors.black,
                      ),
                      onPressed: (() {
                        setState(() {
                          enableHBPM = !enableHBPM;
                        });
                      }),
                      child: const Text('Measure'),
                    ),
                  )
                ],
              ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
              constraints: const BoxConstraints.expand(height: 180),
              child: BPMChart(bpmValues),
            ),
          ),
        ],
      ),
    );
  }
}
