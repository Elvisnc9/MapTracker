import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_tracker/Pages/google_map.dart';

void main() {
  WidgetsFlutterBinding();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Tracker',
      theme: ThemeData(
        useMaterial3: true, 
      ),
      home: const GoogleMapPage()
    );
  }
}

