import 'package:flutter/material.dart';

class PolicePage extends StatefulWidget {
  final Map<String, int> probabilityList;
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
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Probabilities of nearby\n devices",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.probabilityList.entries
                        .map((e) => e.key.toUpperCase() + "\t:\t" + e.value.toString())
                        .join("\n"),
                    style: TextStyle(fontSize: 14),
                  )
                ]),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
