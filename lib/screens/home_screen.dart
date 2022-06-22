import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "DOODLE",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Doodle Gum',
                  letterSpacing: 7),
            ),
            SizedBox(height: 5),
            Text(
              "Sketch Game",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Doodle Gum',
                  letterSpacing: 2),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text(
              "Create/Join a room to play!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: height > 600 ? 24 : 20,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  title: 'Create',
                  color: Colors.blue,
                  onTap: () => Get.toNamed('create_room_screen'),
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => CreateRoomScreen())),
                ),
                CustomButton(
                  title: 'Join',
                  color: Colors.green,
                  onTap: () => Get.toNamed('join_room_screen'),
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => JoinRoomScreen(),
                  //)),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            GestureDetector(
              onTap: () => Get.toNamed('how_to_play_screen'),
              child: Text(
                "How to play?",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
