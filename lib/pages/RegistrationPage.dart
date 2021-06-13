import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covid_19/Globals.dart' as Globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Constants
  final TextEditingController _ageController = new TextEditingController();
  final TextEditingController _genderController = new TextEditingController();

  // States
  bool isLoaded = false;
  String userid;

  // Methods
  @override
  void initState() {
    super.initState();

    // Check if user is already registered,
    SharedPreferences.getInstance().then((prefs) {
      userid = prefs.getString('uid');
      if (userid != null) {
        print(userid);
        Navigator.of(context).pushReplacementNamed('/home');
      }
      setState(() {
        isLoaded = true;
      });
    });
  }

  void registerButton() {
    String gender = _genderController.text;
    int age = int.tryParse(_ageController.text);

    Map body = {
      "gender": gender,
      "age": age,
    };
    http
        .post(Globals.ip_address + 'register',
            headers: {"Content-Type": "application/json"},
            body: json.encode(body))
        .then((response) async {
      final decoded = json.decode(response.body) as Map;
      if (decoded.containsKey('user_id')) {
        String id = decoded['user_id'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', id);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("User Created")));
        setState(() {
          userid = id;
          Navigator.of(context).pushReplacementNamed('/home');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration failed. no data returned")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "R-Naught",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
          body: Builder(
            builder: (context) {
              if (isLoaded == true)
                return _getRegistrationForm();
              else
                return Container(); // Show nothing till data is loaded from localstorage
            },
          )),
    );
  }

  Widget _getRegistrationForm() {
    return Form(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Age"),
            ),
            TextFormField(
              controller: _genderController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hintText: "Gender"),
            ),
            Container(height: 30),
            ElevatedButton(onPressed: registerButton, child: Text("REGISTER"))
          ],
        ),
      ),
    );
  }
}
