import 'dart:async';
//import 'dart:ffi';
import 'package:covid_19/pages/PolicePage.dart';
import 'package:http/http.dart' as http;
import 'package:covid_19/Globals.dart' as Globals;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter_beacon/flutter_beacon.dart' as flutter_beacon;

//import 'package:geolocation/geolocation.dart';
//import 'package:weather/weather.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Constants
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  //String myKey = '5576f874bd97fe2728f4da4e17989804';

  // Variables
  Timer _sendToServerTimer;
  StreamSubscription bluetoothStateChangeStream;
  StreamSubscription<flutter_beacon.RangingResult> _streamBeaconRanging;
  double lat;
  double long;

  // States
  bool isBluetoothOn = false;
  bool isLocationOn = false;
  bool isAdvertising = false;
  String userid;

  Map<String, int> recentlyRecievedUUIDS = {};
  Set<String> recentlySentUUIDs = new Set<String>();
  Map<String, String> selectedUUIDS = {};

  Map<String, int> closerUUIDS = {};
  Map<String, int> temp1UUIDS = {};
  Map<String, int> temp2UUIDS = {};

  // Methods
  @override
  void initState() {
    super.initState();
    initApp();
  }

  void initApp() async {
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();
    if (permission == PermissionStatus.granted ||
        permission == PermissionStatus.restricted) {
      setState(() {
        isLocationOn = true;
      });
    } else {
      await LocationPermissions().requestPermissions();
      initApp();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString('uid');
    setState(() {
      userid = uuid;
    });

    // Wait for bluetooth to turn on
    bluetoothStateChangeStream =
        FlutterBlue.instance.state.listen((bluetoothState) {
      if (bluetoothState == BluetoothState.on) {
        setState(() {
          isBluetoothOn = true;
        });
        startBeaconServices(uuid);
      } else {
        setState(() {
          isBluetoothOn = false;
        });
        stopBeaconServices();
      }
    });

    // Send UUIDS to server on repeated intervals
    _sendToServerTimer = new Timer.periodic(Duration(seconds: 7), (timer) {
      durationApproximation();
    });
  }

  void startBeaconServices(uuid) {
    startBeaconAdvertising(uuid);
    listenForBeacons();
  }

  void stopBeaconServices() {
    beaconBroadcast.stop();
  }

  void getProbability() {
    Map<String,int> probabilities;
    Map body = {
      "user_id": userid,
    };
    print("Sending PROBABILITY data to server");
    print(json.encode(body));
    http
        .post(Globals.ip_address + 'probability',
            headers: {"Content-Type": "application/json"},
            body: json.encode(body))
        .then((response) async {
      final decoded = json.decode(response.body) as Map<String,int>;
      print("probability");
      print(decoded);
      setState(() {
        probabilities = decoded;
      });
      print(probabilities);
      showProbability(probabilities);
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Can't connect to server")));
    });
  }

  //Future<void> noDisease() async {
   // return showDialog<void>(
   //   context: context,
   //   barrierDismissible: false, // user must tap button!
   //   builder: (BuildContext context) {
    //    return AlertDialog(
    //      title: Text('Covid Infection Probability'),
    //      content: Text('You are not at risk of any infection'),
    //      actions: <Widget>[
    //        TextButton(
    //          child: Text('Close'),
    //          onPressed: () {
    //            Navigator.of(context).pop();
   //           },
   //         ),
   //       ],
  //      );
  //    },
 //   );
 // }

  Future<void> showProbability(Map<String,int> values) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Covid Infection Probability'),
          content: Text('You have following chance of having each disease \n $values'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void iamCovidPositive() {
    verification(context);
  }

  Future<void> verification(BuildContext context) async {
    TextEditingController verifyFieldController1 = TextEditingController();
    TextEditingController verifyFieldController2 = TextEditingController();
    String valueCode;
    String valueType;
    String docCode;
    String typeVirus;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Covid Confirmation'),
            content: Column(
              children: [
                TextField(
                  onChanged: (value1) {
                    setState(() {
                      valueCode = value1;
                    });
                  },
                  controller: verifyFieldController1,
                  decoration:
                      InputDecoration(hintText: "Enter your secret number"),
                ),
                TextField(
                  onChanged: (value2) {
                    setState(() {
                      valueType = value2;
                    });
                  },
                  controller: verifyFieldController2,
                  decoration:
                      InputDecoration(hintText: "Enter the virus type"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    docCode = valueCode;
                    typeVirus = valueType;
                    Navigator.pop(context);
                  });
                  sendVerificationToServer(docCode, typeVirus);
                },
              ),
            ],
          );
        });
  }

  void sendVerificationToServer(String docCode, String typeVirus) {
    Map body = {
      "user_id": userid,
      "code": docCode,
      "virus_type": typeVirus
    };
    print("Sending VERIFICATION data to server");
    print(json.encode(body));
    http
        .post(Globals.ip_address + 'positive',
            headers: {"Content-Type": "application/json"},
            body: json.encode(body))
        .then((response) async {
      final decoded = json.decode(response.body);
      print("positive");
      print(decoded); //test
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Verified as Covid Positive")));
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Can't connect to server")));
    });
  }

  void othersProbability() {
    Map<String, int> probabilityList = {};

    print("Trying to send POLICE data");

    Map<String, int> newConnections = Map.fromEntries(recentlyRecievedUUIDS
        .entries
        .where((element) => !recentlySentUUIDs.contains(element.key))
        .map((e) => MapEntry(e.key, e.value)));

    if (newConnections.keys.isEmpty) {
      print("No data to send");
      return;
    }

    Map body = {
      "connections": newConnections,
    };

    print("Sending POLICE data to server");
    print(json.encode(body));
    http
        .post(Globals.ip_address + 'police',
            headers: {"Content-Type": "application/json"},
            body: json.encode(body))
        .then((response) async {
      final decoded = json.decode(response.body) as Map<String,int>;
      print("police");
      print(decoded);
      setState(() {
        probabilityList = decoded;
        recentlySentUUIDs = recentlyRecievedUUIDS.keys.toSet();
      });
      print(probabilityList);
      print(recentlySentUUIDs);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PolicePage(probabilityList: probabilityList)));
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Can't connect to server")));
    });
  }

  void durationApproximation() {
    int count = 1;
    int res;
    

    if (recentlyRecievedUUIDS.keys.isEmpty){
      print("No connected devices");
    }
    else{
      for (MapEntry e in recentlyRecievedUUIDS.entries) {
        if (e.value > -100) {
          closerUUIDS[e.key] = count;
        }
      }
      print("closerUUIDS");
      print(closerUUIDS);
      if (temp1UUIDS.keys.isEmpty) {
        temp1UUIDS = Map.from(closerUUIDS);
        
      } else if (temp2UUIDS.keys.isEmpty) {
        for (MapEntry e in closerUUIDS.entries) {
          if (temp1UUIDS.containsKey(e.key)) {
            temp2UUIDS.putIfAbsent(e.key, () => (e.value)+count);
          }
        }
        temp1UUIDS = Map.from(closerUUIDS);
      } else {
        for (MapEntry e in closerUUIDS.entries) {
          if (temp2UUIDS.containsKey(e.key)) {
            temp2UUIDS.update(e.key, (value) => value+count);
          } else if (temp1UUIDS.containsKey(e.key)) {
            temp2UUIDS.putIfAbsent(e.key, () => (e.value)+count);
          }
        }
        temp1UUIDS = Map.from(closerUUIDS);
        for (MapEntry e in temp2UUIDS.entries) {
          if (!(closerUUIDS.containsKey(e.key))) {
            setState(() {
              selectedUUIDS.putIfAbsent(e.key, () => e.value.toString());
            });
            res = temp2UUIDS.remove(e.key);
          }
        }
        print("duration");
        print(res);
      }
    }
    if (closerUUIDS.keys.isEmpty){
      if (temp2UUIDS.keys.isEmpty){
        return;
      }
      else{
        for (MapEntry e in temp2UUIDS.entries){
          selectedUUIDS.putIfAbsent(e.key, () => e.value.toString());
        }
        temp2UUIDS = {};
      }
    }
    else{
      for (MapEntry e in temp2UUIDS.entries) {
      if (!(closerUUIDS.containsKey(e.key))) {
        setState(() {
          selectedUUIDS.putIfAbsent(e.key, () => e.value.toString());
        });
        res = temp2UUIDS.remove(e.key);
        }
    }
    print("duration");
    print(res.toString());
    }
    
    closerUUIDS = {};
    print("temp1UUIDS");
    print(temp1UUIDS);
    print("temp2UUIDS");
    print(temp2UUIDS);
    print("selectedUUIDS");
    print(selectedUUIDS);
    print("Trying to send CONTACT data");
    if (selectedUUIDS.keys.isEmpty) {
      print("No data to send");
      return;
    }

    sendUUIDSToServer();
  }

  void sendUUIDSToServer() {

    //Map location  = getMyCoordinates();
    String temperature = "10";
    String humidity = "Low";

    Map body = {
      "user_id": userid,
      "temperature": temperature,
      "humidity": humidity,
      "connections": selectedUUIDS,
    };

    print("Sending CONTACT data to server");
    print(json.encode(body));
    http
        .post(Globals.ip_address + 'new_contact',
            headers: {"Content-Type": "application/json"},
            body: json.encode(body))
        .then((response) async {
      setState(() {
        selectedUUIDS.clear();
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Can't connect to server")));
    });
  }

//Location
//Now Create Method named _getCurrentLocation with async Like Below.
  //_getCurrentLocation() async {
  //Geolocation.currentLocation(accuracy: LocationAccuracy.best)
  //  .listen((result) {
  // if (result.isSuccessful) {
  //  setState(() {
  //   lat = result.location.latitude;
  //  long = result.location.longitude;
  //});
  // }
  //});
  // }

  //Map getMyCoordinates(){
  // _getCurrentLocation();
  //String latitude = lat.toString();
  //String longitude = long.toString();

  //return {"latitude":latitude,"longitude":longitude};
  //}

//Temperature
  // Future<String> getTemp() async {
  // WeatherFactory wf = new WeatherFactory(myKey);
  // Weather w = await wf.currentWeatherByLocation(lat, long);
  // String temp = w.temperature.celsius.toString();
  // return temp;
  //}

  void startBeaconAdvertising(uuid) {
    beaconBroadcast
        .setUUID(uuid)
        .setMajorId(1)
        .setMinorId(100)
        .setLayout('m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
        .setManufacturerId(0x004c)
        .start()
        .then((value) {
      print("Advertising Beacon with uuid= $uuid");
    });

    beaconBroadcast.getAdvertisingStateChange().listen((advertisingStatus) {
      setState(() {
        isAdvertising = advertisingStatus;
      });
    });
  }

  void listenForBeacons() async {
    await flutter_beacon.flutterBeacon.initializeScanning;
    final regions = <flutter_beacon.Region>[
      flutter_beacon.Region(identifier: 'ibeacon')
    ];

    _streamBeaconRanging = flutter_beacon.flutterBeacon
        .ranging(regions)
        .listen((flutter_beacon.RangingResult result) {
      setState(() {
        recentlyRecievedUUIDS = Map.fromEntries(
            result.beacons.map((e) => MapEntry(e.proximityUUID, e.rssi)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userid == null)
      return Container();
    else
      return SafeArea(
        child: Scaffold(
            body: Center(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isBluetoothOn != true)
                  Column(
                    children: [
                      Icon(Icons.bluetooth, color: Colors.red, size: 30),
                      Text("Please turn your bluetooth on"),
                      SizedBox(height: 100)
                    ],
                  ),
                if (isAdvertising == true)
                  Column(
                    children: [
                      Icon(Icons.bluetooth, color: Colors.green, size: 30),
                      Text("Your uid is visible to nearby phones"),
                      SizedBox(height: 100)
                    ],
                  ),
                ElevatedButton(
                    onPressed: getProbability,
                    child: Text("Get My Covid Probability")),
                ElevatedButton(
                  onPressed: iamCovidPositive,
                  child: Text("Covid Verification (Doctors only)"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
                ElevatedButton(
                  onPressed: othersProbability,
                  child: Text("Probaility Verification (Officials only)"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
                SizedBox(height: 30),
                Text(recentlyRecievedUUIDS.entries
                    .map((e) => e.key + "\t:\t" + e.value.toString())
                    .join("\n"))
              ]),
        )),
      );
  }

  @override
  void dispose() {
    super.dispose();
    _streamBeaconRanging.cancel().onError((error, stackTrace) => null);
    bluetoothStateChangeStream.cancel();
    _sendToServerTimer.cancel();
  }
}
