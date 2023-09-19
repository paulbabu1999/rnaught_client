import 'package:flutter/material.dart';
import 'package:covid_19/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //  ClusterManager.createMarkers();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'OpenSans',
        primaryColor: Color(0xffF9F9F9),
        hintColor: Color(0xffA7A7A7),
      ),
      title: 'Flutter Demo',
      onGenerateRoute: generateRoute,
    );
  }
}
