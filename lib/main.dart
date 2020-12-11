import 'package:flutter/material.dart';
import 'home.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _random = new Random();
  var _r = 0;
  void generateRandomNumber() {
    _r = _random.nextInt(100);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('Covid Tracker'),
                ),
                body: Center(
                  child: RaisedButton(
                    highlightElevation: 0.0,
                    splashColor: Colors.white,
                    highlightColor: Colors.blue,
                    elevation: 0.0,
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: Text(
                      "Register",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    onPressed: () {
                      generateRandomNumber();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Proceed(r: _r)),
                      );
                    },
                  ),
                ))));
  }
}

class Proceed extends StatefulWidget {
  final int r;
  Proceed({@required this.r});

  @override
  _ProceedState createState() => _ProceedState();
}

class _ProceedState extends State<Proceed> {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Covid Tracker"),
          ),
          body: Center(
            child: Text("Your Unique ID is ${widget.r}"),
          ),
          floatingActionButton: FloatingActionButton(
            child: Text("Proceed"),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          /*Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              child: Text("Proceed"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
          ),*/
        ),
      ),
    );
  }
}
