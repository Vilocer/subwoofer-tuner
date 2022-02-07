import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class MyPainter extends CustomPainter {
  //         <-- CustomPainter class
  final List<int> oneCycleData;

  MyPainter(this.oneCycleData);

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    List<Offset> maxPoints = [];

    final t = size.width / (oneCycleData.length - 1);
    for (var _i = 0, _len = oneCycleData.length; _i < _len; _i++) {
      maxPoints.add(Offset(
          t * i,
          size.height / 2 -
              oneCycleData[_i].toDouble() / 32767.0 * size.height / 2));
      i++;
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.polygon, maxPoints, paint);
  }

  @override
  bool shouldRepaint(MyPainter old) {
    if (oneCycleData != old.oneCycleData) {
      return true;
    }
    return false;
  }
}

class _MyAppState extends State<MyApp> {
  bool isPlaying = false;
  double frequency = 10;
  double balance = 0;
  double volume = 1;
  waveTypes waveType = waveTypes.SINUSOIDAL;
  int sampleRate = 96000;
  List<int>? oneCycleData;

  String nameWaveType = "Синусоида";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
      ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Настройка сабвуфера'),
            ),
            body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      FloatingActionButton(
                          backgroundColor: Colors.orange,
                          child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                          onPressed: () {
                            isPlaying
                                    ? SoundGenerator.stop()
                                    : SoundGenerator.play();
                          },
                        ),
                      SizedBox(height: 50),
                      Row(
                          children: <Widget>[
                          Expanded(
                            child: FloatingActionButton(
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (frequency != 1) {
                                    this.frequency --;
                                      SoundGenerator.setFrequency(this.frequency);
                                    }
                                  });
                                },
                              )
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text("Частота:"),
                                SizedBox(height: 5),
                                Text(this.frequency.toString() + " Hz ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                                  )
                            ],)
                          ),
                            Expanded(
                              child: FloatingActionButton(
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    this.frequency ++;
                                    SoundGenerator.setFrequency(this.frequency);
                                  });
                                },
                              ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Длина волны: " +
                          (sampleRate / this.frequency).round().toString()),
                      SizedBox(height: 20),
                      Slider(
                        min: 1,
                        max: 1000,
                        thumbColor: Colors.orange,
                        activeColor: Colors.deepOrangeAccent,
                        value: this.frequency,
                        onChanged: (_value) {
                          setState(() {
                            this.frequency = _value.floorToDouble();
                            SoundGenerator.setFrequency(
                                this.frequency);
                          });
                      }),
                      Divider(color: Colors.white),
                      SizedBox(height: 20),
                      Center(
                          child: DropdownButton<waveTypes>(
                              value: this.waveType,
                              onChanged: (waveTypes? newValue) {
                                setState(() {
                                  this.waveType = newValue!;
                                  SoundGenerator.setWaveType(this.waveType);
                                });
                              },
                              items:
                                  waveTypes.values.map((waveTypes classType) {
                                
                                  switch(classType.toString().split('.').last) {
                                    case "SINUSOIDAL": {
                                      this.nameWaveType = 'Синусоида';
                                    }
                                    break;
                                    case "SQUAREWAVE": {
                                      this.nameWaveType = 'Меандр';
                                    }
                                    break;
                                    case "TRIANGLE": {
                                      this.nameWaveType = "Треугольная";
                                    }
                                    break;
                                    case "SAWTOOTH": {
                                      this.nameWaveType = "Пилообразная";
                                    }
                                    break;
                                    default: {
                                      this.nameWaveType = 'Default';
                                    }
                                  } 

                                return DropdownMenuItem<waveTypes>(
                                    value: classType,
                                    child: Text(this.nameWaveType));
                              }).toList())),
                    ]))));
  }

  @override
  void dispose() {
    super.dispose();
    SoundGenerator.release();
  }

  @override
  void initState() {
    super.initState();
    isPlaying = false;

    SoundGenerator.init(sampleRate);

    SoundGenerator.onIsPlayingChanged.listen((value) {
      setState(() {
        isPlaying = value;
      });
    });

    SoundGenerator.onOneCycleDataHandler.listen((value) {
      setState(() {
        oneCycleData = value;
      });
    });

    SoundGenerator.setAutoUpdateOneCycleSample(true);
    //Force update for one time
    SoundGenerator.refreshOneCycleData();
  }
}