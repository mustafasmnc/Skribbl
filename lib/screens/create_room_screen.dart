import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/paint_screen.dart';
import 'package:skribbl_clone/widgets/custom_button.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRoundValue = "2";
  late String? _roomSizeValue = "2";

  createRoom() async {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "occupancy": _roomSizeValue!,
        "maxRounds": _maxRoundValue!
      };
      // if (checkRoomExist() == true) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //       content: Text(
      //           'Room with ${_roomNameController.text} is already exist')));
      // } else {
      //   print(checkRoomExist());
      //   // Navigator.of(context).push(MaterialPageRoute(
      //   //     builder: (context) =>
      //   //         PaintScreen(data: data, screenFrom: 'createRoom')));
      // }

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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${_roomNameController.text} is already exist')));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PaintScreen(data: data, screenFrom: 'createRoom')));
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Text(
                "Create Room",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              CustomTextField(
                controller: _nameController,
                hintText: "Enter your name",
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: _roomNameController,
                hintText: "Enter room name",
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select max rounds",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 40),
                  DropdownButton<String>(
                    focusColor: Color(0xFFF5F6FA),
                    items: <String>["2", "5", "10", "15"]
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ))
                        .toList(),
                    hint: Text(
                      _maxRoundValue!,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _maxRoundValue = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select room size",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 40),
                  DropdownButton<String>(
                    focusColor: Color(0xFFF5F6FA),
                    items: <String>["2", "3", "4", "5", "6", "7", "8"]
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ))
                        .toList(),
                    hint: Text(
                      _roomSizeValue!,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _roomSizeValue = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 40),
              CustomButton(
                title: "Create",
                color: Colors.blue,
                onTap: () => createRoom(),
              )
              // ElevatedButton(
              //     onPressed: () => createRoom(),
              //     style: ButtonStyle(
              //       backgroundColor: MaterialStateProperty.all(Colors.blue),
              //       textStyle: MaterialStateProperty.all(
              //           TextStyle(color: Colors.white)),
              //       minimumSize: MaterialStateProperty.all(
              //           Size(MediaQuery.of(context).size.width / 2.5, 50)),
              //     ),
              //     child: Text(
              //       "Create",
              //       style: TextStyle(color: Colors.white, fontSize: 16),
              //     ))
            ],
          ),
        ),
      ),
    );
  }
}
