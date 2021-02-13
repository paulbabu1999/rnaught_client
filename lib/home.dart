import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trace.dart';

class Home extends StatefulWidget {
  final int r;
  Home({@required this.r});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: choices.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Covid Tracker'),
          bottom: TabBar(
            isScrollable: false,
            tabs: choices.map<Widget>((Choice choice) {
              return Tab(
                text: choice.title,
                icon: Icon(choice.icon),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: [
            HomeTab(r: widget.r),
            VerificationTab(r: widget.r),
          ],
        ),
      ),
    );
  }
}


class Choice {
  final String title;
  final IconData icon;
  const Choice({this.title, this.icon});
}

const List<Choice> choices = <Choice>[
  Choice(title: 'HOME', icon: Icons.home),
  Choice(title: 'VERIFICATION', icon: Icons.local_hospital),
];






class HomeTab extends StatelessWidget {
  final int r;
  HomeTab({
    Key key,
    @required this.r
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(  
      padding: const EdgeInsets.all(20.0),  
      child:Center(
        child: RaisedButton( 
          highlightElevation: 0.0,
          splashColor: Colors.white,
          highlightColor: Colors.blue,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)), 
          child: Text('Check Percentage'),  
          onPressed: () async {
            final response = await http.post(
                  'http://192.168.1.12:5000/probability',
                    body: json.encode({
                      'id': r,
                    }),
                    ); 
            final decoded = json.decode(response.body);
            final val = decoded["probability"];

            showAlertDialog(context, val: val);  
          },  
        ),
      ),
    );  
  }  
}  
  
showAlertDialog(BuildContext context, {int val = 0, int stcode = 0, int r}) {  
  // Create button  
  Widget okButton = FlatButton(  
    child: Text("OK"),  
    onPressed: () async {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Trace(r: r)));
    }  
  );  
  
  // Create AlertDialog  
  AlertDialog alert1 = AlertDialog(  
    title: Text("Covid Infection Probability"),  
    content: Text("You have $val% chance of having covid."),  
    /*actions: [  
      okButton,  
    ],*/  
  ); 

  AlertDialog alert2 = AlertDialog(  
    title: Text("Covid Confirmation"),  
    content: Text("You have been confirmed positive by doctor. "),  
    actions: [  
      okButton,  
    ],
  );

  AlertDialog alert3 = AlertDialog(  
    title: Text("Covid Confirmation"),  
    content: Text("Error!!!\nTry Again."),  
    /*actions: [  
      okButton,  
    ],*/ 
  );     
  
  // show the dialog  
  showDialog(  
    context: context,  
    builder: (BuildContext context) {
      if (stcode == 0) {
        return alert1;
      } else if (stcode == 201) {
          return alert2;
      } else {
          return alert3;

      }
    },  
  );  
}



class VerificationTab extends StatelessWidget {
  final int r;
  VerificationTab({
    Key key,
    @required this.r
  }) : super(key: key);

  final skey = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: skey,
              decoration: InputDecoration(
                  hintText: "Enter secret key",
                  labelText: "For doctors only",
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
                "Confirm",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20),
              ),

              onPressed: () async {
                final response = await http.post(
                  'http://192.168.1.12:5000/positive',
                    body: json.encode({
                      'id': r,
                      'skey': skey.text,
                    }),
                    );
                final decoded = json.decode(response.body);

                showAlertDialog(context, stcode: decoded, r: r);

              }
    
              )
            ],
          ),
        ),
    );
  }
}
