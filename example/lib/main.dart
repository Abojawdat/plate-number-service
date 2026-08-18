import 'package:flutter/material.dart';
import 'package:iraqi_license_plate/iraqi_license_plate.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iraqi plates',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF7289DA)),
      // The package ships a full explorer; this is the whole example app.
      home: const PlateGalleryScreen(),
    );
  }
}
