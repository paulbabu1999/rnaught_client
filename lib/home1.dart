import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Home1 extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home1> {

  TextEditingController id = new TextEditingController();
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
                controller: id,
                decoration: InputDecoration(
                    hintText: "Your ID",
                    labelText: "ID",
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
                      'http://10.0.2.2:5000/add_person',
                      body: json.encode({
                      'id': id.text,
                      'age': age.text,
                      'gender': gender.text,
                    }),
                    );
                    },
              )
            ],
          ),
        ),
      ),
    );  




  }
}