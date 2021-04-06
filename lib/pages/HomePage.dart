import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter_beacon/flutter_beacon.dart' as flutter_beacon;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Constants
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  // Variables
  Timer _sendToServerTimer;
  StreamSubscription bluetoothStateChangeStream;
  StreamSubscription<flutter_beacon.RangingResult> _streamBeaconRanging;

  
  // States
  bool isBluetoothOn = false;
  bool isAdvertising = false; 
  String userid;

  Set<String> uuidsRecieved = new Set<String>();
  
  Set<String> uuidsSend = new Set<String>();

  // Methods
  @override
  void initState() {
    super.initState();
    initApp();
  }


  void initApp() async{
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
    _sendToServerTimer = new Timer.periodic(Duration(seconds: 10), (timer) { sendUUIDSToServer(); });
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
    print("HI");
    if(uuidsRecieved.isEmpty) return;


    // TODO BY NOWFIR KAMBI
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
      result.beacons.forEach(
        (beacon) {
          uuidsRecieved.add(beacon.proximityUUID);
        }
      );
      setState(() {
        uuidsRecieved = uuidsRecieved;
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
                
                Text(uuidsRecieved.join("\n"))
                
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