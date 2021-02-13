import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Trace extends StatefulWidget {
  final int r;
  Trace({@required this.r});
  @override
  _TraceState createState() => _TraceState();
}

class _TraceState extends State<Trace>{

  TextEditingController id2 = new TextEditingController();
  TextEditingController dura = new TextEditingController();
  TextEditingController loc = new TextEditingController();

  @override
  Widget build(BuildContext context){
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
                controller: id2,
                decoration: InputDecoration(
                    hintText: "ID of Contact",
                    labelText: "Contact",
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
                controller: dura,
                decoration: InputDecoration(
                    hintText: "Duration of contact",
                    labelText: "Duration(in minutes)",
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
                controller: loc,
                decoration: InputDecoration(
                    hintText: "Location of contact",
                    labelText: "Location",
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
                        'http://192.168.1.12:5000/new_contact',
                        body: json.encode({
                        'id1': widget.r,
                        'id2': id2.text,
                        'duration': dura.text,
                        'location': loc.text,
                        }),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
    );

  }
}
