import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/screens/create_room_screen.dart';
import 'package:skribbl_clone/screens/final_learderboard.dart';
import 'package:skribbl_clone/screens/home_screen.dart';
import 'package:skribbl_clone/screens/how_to_play.dart';
import 'package:skribbl_clone/screens/join_room_screen.dart';
import 'package:skribbl_clone/screens/paint_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Doodle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      //home: const HomeScreen(),
      getPages: [
        GetPage(name: '/home_screen', page: () => HomeScreen()),
        GetPage(name: '/how_to_play_screen', page: () => HowToPlayScreen()),
        GetPage(name: '/join_room_screen', page: () => JoinRoomScreen()),
        GetPage(name: '/create_room_screen', page: () => CreateRoomScreen()),
        GetPage(name: '/paint_screen', page: () => PaintScreen()),
        GetPage(
            name: '/final_leaderboard_screen', page: () => FinalLeaderBoard()),
      ],
      initialRoute: '/home_screen',
    );
  }
}
