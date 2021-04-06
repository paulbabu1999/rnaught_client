import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'package:covid_19/Globals.dart' as Globals;



class Home1 extends StatefulWidget {
  final int r;
  Home1({@required this.r});
  @override
  _Home1State createState() => _Home1State();
}

class _Home1State extends State<Home1> {

  TextEditingController age = new TextEditingController();
  TextEditingController gender = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Covid Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: age,
                decoration: InputDecoration(
                    hintText: "Your Age",
                    labelText: "Age",
                    labelStyle: TextStyle(fontSize: 24, color: Colors.black),
                    border: InputBorder.none,
                    fillColor: Colors.black12,
                    filled: true),
                obscureText: false,
                maxLength: 20,
              ),
              SizedBox(
                height: 16,
              ),

              TextField(
                controller: gender,
                decoration: InputDecoration(
                    hintText: "Your Gender",
                    labelText: "Gender",
                    labelStyle: TextStyle(fontSize: 24, color: Colors.black),
                    border: InputBorder.none,
                    fillColor: Colors.black12,
                    filled: true),
                obscureText: false,
                maxLength: 20,
              ),
              SizedBox(
                height: 16,
              ),

              RaisedButton(
                highlightElevation: 0.0,
                    splashColor: Colors.white,
                    highlightColor: Colors.blue,
                    elevation: 0.0,
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ),

                    onPressed: () async {
                      final response = await http.post(
                      Globals.ip_address+'/add_person',
                      body: json.encode({
                      'id': widget.r,
                      'age': age.text,
                      'gender': gender.text,
                    }),
                    );
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home(r: widget.r)));
                    },
              )
            ],
          ),
        ),
      ),
    );  




  }
}