import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/screens/create_room_screen.dart';
import 'package:skribbl_clone/screens/join_room_screen.dart';
import 'package:skribbl_clone/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Create/Join a room to play!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
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
          )
        ],
      ),
    );
  }
}
