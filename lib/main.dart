import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/chat_screen.dart';
import 'package:skribbl_clone/screens/home_screen.dart';
import 'package:skribbl_clone/screens/paint_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skribbl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
