import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/widgets/custom_button.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  bool loading = false;

  joinRoom() async {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text.trim(),
        "isPlayerAdmin": 'false'
      };

      await http
          .post(
              Uri.parse(
                  'https://flutter-skribbl-clone.herokuapp.com/api/room/check'),
              //Uri.parse('http://192.168.1.107:4000/api/room/check'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(<String, String>{
                'roomName': _roomNameController.text.trim().toString()
              }))
          .then((response) {
        if (response.statusCode == 200) {
          setState(() {
            loading = false;
          });
          Get.offAndToNamed('/paint_screen', arguments: [data, 'joinRoom']);
          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (context) =>
          //         PaintScreen(data: data, screenFrom: 'joinRoom')));
        } else if (response.statusCode == 202) {
          setState(() {
            loading = false;
          });
          Get.snackbar('Error!', 'Room ${_roomNameController.text} is full',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              icon: Icon(Icons.error_outline));
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     backgroundColor: Colors.redAccent,
          //     content: Text(
          //       'Room "${_roomNameController.text}" is full!',
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16),
          //     )));
        } else {
          setState(() {
            loading = false;
          });
          Get.snackbar(
              'Error!', 'Room ${_roomNameController.text} is not exist',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              icon: Icon(Icons.error_outline));
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     backgroundColor: Colors.redAccent,
          //     content: Text(
          //       'Room "${_roomNameController.text}" is not exist!',
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16),
          //     )));
        }
      });
    } else {
      Get.snackbar('Error!', 'Please fill out all required fields!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: Icon(Icons.error_outline));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          //backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Join Room",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    controller: _nameController,
                    hintText: "Enter your name",
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    controller: _roomNameController,
                    hintText: "Enter room name",
                  ),
                ),
                SizedBox(height: 40),
                CustomButton(
                  title: "Join",
                  color: Colors.green,
                  onTap: () => joinRoom(),
                )
                // ElevatedButton(
                //     onPressed: () => joinRoom(),
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all(Colors.blue),
                //       textStyle:
                //           MaterialStateProperty.all(TextStyle(color: Colors.white)),
                //       minimumSize: MaterialStateProperty.all(
                //           Size(MediaQuery.of(context).size.width / 2.5, 50)),
                //     ),
                //     child: Text(
                //       "Join",
                //       style: TextStyle(color: Colors.white, fontSize: 16),
                //     ))
              ],
            ),
            loading
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                    ),
                    child: Center(child: CircularProgressIndicator()))
                : Container()
          ],
        ),
      ),
    );
  }
}
