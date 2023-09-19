import 'package:covid_19/Globals.dart' as Globals;
import 'package:flutter/material.dart';
import 'home1.dart';
//import 'home.dart';
/*import 'dart:math';*/

import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _r = 0;
  /*var _random = new Random();
  void generateRandomNumber() {
    _r = _random.nextInt(100);
  }*/

  /*void initState() { 
      super.initState();
      checkId();  
  } */ 
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
                    onPressed: () async {
                      /*generateRandomNumber();*/

                      final response = await http.get(Globals.ip_address+'id');

                      final decoded = json.decode(response.body);

                      setState(() {                      
                        _r = decoded['id'];
                      });

                      /*SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt('uid', decoded['id']);*/

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Proceed(r: _r)),
                      );
                    },
                  ),
                ))));
  }
  /*void checkId() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int uid = prefs.getInt('uid');
      if(uid != null){
        Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
      }
  }*/
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
                  context, MaterialPageRoute(builder: (context) => Home1(r: widget.r)));
            },
          ),
        ),
      ),
    );
  }
}
