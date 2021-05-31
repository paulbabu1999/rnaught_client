import 'package:flutter/material.dart';

class PolicePage extends StatefulWidget {
  final Map<String,int> probabilityList;
  PolicePage({@required this.probabilityList});
  @override
  _PolicePageState createState() => _PolicePageState();
}

class _PolicePageState extends State<PolicePage> {
  // Constants
  
  // States


  // Methods
   
  @override
  Widget build(BuildContext context) {
    if(widget.probabilityList.isEmpty)
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                      Text("No nearby devices"),
                      SizedBox(height: 100)
              ]
            ),
          )
        ),
      );

    else
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                      Text(widget.probabilityList.entries.map((e)=>e.key + "\t:\t" + e.value.toString()).join("\n"))
              ]
            ),
          )
        ),
      );
  }


  @override
  void dispose(){
    super.dispose();
  }
}