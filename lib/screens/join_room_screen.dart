import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/paint_screen.dart';
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

  joinRoom() async {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text
      };

      await http
          .post(
              Uri.parse(
                  'https://flutter-skribbl-clone.herokuapp.com/api/room/check'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(<String, String>{
                'roomName': _roomNameController.text.toString()
              }))
          .then((response) {
        if (response.statusCode == 200) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PaintScreen(data: data, screenFrom: 'joinRoom')));
        } else if (response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                'Room "${_roomNameController.text}" is full!',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                'Room "${_roomNameController.text}" is not exist!',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        //backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
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
    );
  }
}
