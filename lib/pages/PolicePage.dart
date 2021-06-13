import 'package:flutter/material.dart';

class PolicePage extends StatefulWidget {
  final Map<String, dynamic> probabilityList;
  PolicePage({@required this.probabilityList});
  @override
  _PolicePageState createState() => _PolicePageState();
}

class _PolicePageState extends State<PolicePage> {
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
                children: [
                  Text(
                    widget.probabilityList.entries
                        .map((e) =>
                            e.key.toUpperCase() +
                            "\t:-\n" +
                            e.value.entries
                                .map((e) => e.key + ":" + e.value.toString())
                                .join(", "))
                        .join("\n"),
                    style: TextStyle(fontSize: 16),
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
