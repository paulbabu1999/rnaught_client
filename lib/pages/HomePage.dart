import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:covid_19/Globals.dart' as Globals;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter_beacon/flutter_beacon.dart' as flutter_beacon;

import 'package:geolocation/geolocation.dart';
import 'package:weather/weather.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Constants
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  String myKey = '5576f874bd97fe2728f4da4e17989804';

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

  Set<String> recentlyRecievedUUIDS = new Set<String>();
  
  Set<String> recentlySentUUIDs = new Set<String>();

  // Methods
  @override
  void initState() {
    super.initState();
    initApp();
  }


  void initApp() async{
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    if(permission == PermissionStatus.granted || permission == PermissionStatus.restricted){
        setState(() {
          isLocationOn = true;
        });
    }
    else{
      await LocationPermissions().requestPermissions();
      initApp();
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString('uid'); 
    setState(() {
      userid = uuid;
    });


    // Wait for bluetooth to turn on
    bluetoothStateChangeStream =  FlutterBlue.instance.state.listen((bluetoothState) {
      if(bluetoothState == BluetoothState.on){
        setState(() {
          isBluetoothOn = true;
        });
        startBeaconServices(uuid);
      }
      else{
        setState(() {
          isBluetoothOn = false;
        });
        stopBeaconServices();
      }
    });

    // Send UUIDS to server on repeated intervals
    _sendToServerTimer = new Timer.periodic(Duration(seconds: 15), (timer) { sendUUIDSToServer(); });
  }

  void startBeaconServices(uuid){
    startBeaconAdvertising(uuid);
    listenForBeacons();
  }
  void stopBeaconServices(){
    beaconBroadcast.stop();
  }

  void getProbability(){
    // TODO : Complete This
  }

  void iamCovidPositive(){
    // TODO : Complete This
  }

  void sendUUIDSToServer(){
    print("Trying to send data");

    
    Set<String> newUuids = recentlyRecievedUUIDS.difference(recentlySentUUIDs);
    Set<String> disconnectedUuids = recentlySentUUIDs.difference(recentlyRecievedUUIDS);

    if(newUuids.isEmpty && disconnectedUuids.isEmpty){
      print("No data to send");
      return;
    };

    Map location  = getMyCoordinates();
    String temperature  = '10';
    int humidity = 1;


    Map body = {
      "user_id": userid,
      "temperature": temperature,
      "location": location,
      "humidity": humidity,
      "connections": newUuids.toList(),
      "disconnections": disconnectedUuids.toList()
    }; 

    print("Sending data to server");
    http.post(
        Globals.ip_address+'new_contact',
        headers: {"Content-Type": "application/json"},
        body: json.encode(body)
      )
      .then((response) async{
          setState(() {
            recentlySentUUIDs = recentlyRecievedUUIDS;
            recentlyRecievedUUIDS = new Set<String>();
          });
      }).catchError((e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Registration faild. no data returned")));
      });
    
    


      

    // TODO BY NOWFIR KAMBI
  }

//Location
//Now Create Method named _getCurrentLocation with async Like Below.
  _getCurrentLocation() async {
    Geolocation.currentLocation(accuracy: LocationAccuracy.best)
        .listen((result) {
      if (result.isSuccessful) {
        setState(() {
          lat = result.location.latitude;
          long = result.location.longitude;
        });
      }
    });
  }

  Map getMyCoordinates(){
    _getCurrentLocation();
    String latitude = lat.toString();
    String longitude = long.toString();

    return {"latitude":latitude,"longitude":longitude};
  }

//Temperature
  Future<String> getTemp() async {
    WeatherFactory wf = new WeatherFactory(myKey);
    Weather w = await wf.currentWeatherByLocation(lat, long);
    String temp = w.temperature.celsius.toString();
    return temp;
  }
  


  void startBeaconAdvertising(uuid){
    beaconBroadcast
      .setUUID(uuid)
      .setMajorId(1)
      .setMinorId(100)
      .setLayout('m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
      .setManufacturerId(0x004c)
      .start().then((value){
            print("Advertising Beacon with uuid= $uuid");
      });



    beaconBroadcast.getAdvertisingStateChange().listen((advertisingStatus) {
        setState(() {
          isAdvertising = advertisingStatus; 
        });
    });
  }


  void listenForBeacons() async{
    await flutter_beacon.flutterBeacon.initializeScanning;
    final regions = <flutter_beacon.Region>[
      flutter_beacon.Region(identifier: 'ibeacon' )
    ];



    _streamBeaconRanging = flutter_beacon.flutterBeacon.ranging(regions).listen((flutter_beacon.RangingResult result) {
      setState(() {
        recentlyRecievedUUIDS = result.beacons.map((e) => e.proximityUUID).toSet();
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    if(userid == null) return Container();

    else
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                if(isBluetoothOn != true)
                  Column(
                    children: [
                      Icon(Icons.bluetooth,color: Colors.red,size: 30),
                      Text("Bluetooth on aakeda"),
                      SizedBox(height: 100)
                    ],
                  ),

                if(isAdvertising == true)
                  Column(
                    children: [
                      Icon(Icons.bluetooth,color: Colors.green,size: 30),
                      Text("Your uid is visible to nearby phones"),
                      SizedBox(height: 100)
                    ],
                  ),


                ElevatedButton(
                  onPressed: getProbability,
                  child: Text("GET MY COVID PROBABILITY")
                ),

                
                ElevatedButton(
                  onPressed: iamCovidPositive,
                  child: Text("I'M FEELING LUCKY"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),

                SizedBox(height: 30),
                
                Text(recentlyRecievedUUIDS.join("\n"))
                
              ]
            ),
          )
        ),
      );
  }
  @override
  void dispose(){
    super.dispose();
    _streamBeaconRanging.cancel().onError((error, stackTrace) => null);
    bluetoothStateChangeStream.cancel();
    _sendToServerTimer.cancel();
  }
}