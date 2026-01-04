import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const ParentPalApp());
}

class ParentPalApp extends StatelessWidget {
  const ParentPalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParentPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(),
    );
  }
}
