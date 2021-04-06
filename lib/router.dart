import 'package:covid_19/pages/HomePage.dart';
import 'package:covid_19/pages/RegistrationPage.dart';
import 'package:covid_19/pages/SamplePage.dart';
import 'package:flutter/material.dart';

           
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => RegistrationPage());
    case '/home':
      return MaterialPageRoute(builder: (context) => HomePage());
    default:
      return MaterialPageRoute(builder: (context) => Center(child: Text('Page Not Found')));
  }
}