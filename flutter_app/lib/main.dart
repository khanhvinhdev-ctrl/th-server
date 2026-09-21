import 'package:flutter/material.dart';

import 'dev/index.dart';

void main() {
  runApp(const ThServerApp());
}

class ThServerApp extends StatelessWidget {
  const ThServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThServer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
      ),
      home: const DevHomeScreen(),
    );
  }
}