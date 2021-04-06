import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) => MaterialApp(
       title: 'BLE Demo',
       theme: ThemeData(
         primarySwatch: Colors.blue,
       ),
       home: MyHomePage(title: 'Flutter BLE Demo'),
     );
}
 
class MyHomePage extends StatefulWidget {
 MyHomePage({Key key, this.title}) : super(key: key);

 final String title;
 final FlutterBlue flutterBlue = FlutterBlue.instance;
 final List<BluetoothDevice> devicesList = new List<BluetoothDevice>.empty();

 
 @override
 _MyHomePageState createState() => _MyHomePageState();
}
 
class _MyHomePageState extends State<MyHomePage> {

 _addDeviceTolist(final BluetoothDevice device) {
   if (!widget.devicesList.contains(device)) {
     setState(() {
       widget.devicesList.add(device);
     });
   }
 } 
 @override
 void initState() {
   super.initState();
   widget.flutterBlue.connectedDevices
       .asStream()
       .listen((List<BluetoothDevice> devices) {
     for (BluetoothDevice device in devices) {
       _addDeviceTolist(device);
     }
   });
   widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
     for (ScanResult result in results) {
       _addDeviceTolist(result.device);
     }
   });
   widget.flutterBlue.startScan();
 }
 Widget build(BuildContext context) => Scaffold(
       appBar: AppBar(
         title: Text(widget.title),
       ),
       body: Column(
         children: <Widget>[],
       ),
     );
}