import 'package:flutter/material.dart';
import 'package:skribbl_clone/screens/paint_screen.dart';
import 'package:skribbl_clone/widgets/custom_text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRoundValue = "0";
  late String? _roomSizeValue = "0";

  createRoom() {
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
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PaintScreen(data: data, screenFrom: 'createRoom')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Room",
                style: TextStyle(
                  color: Colors.black,
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
                      color: Colors.black,
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
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ))
                        .toList(),
                    hint: Text(
                      _maxRoundValue!,
                      style: TextStyle(
                        color: Colors.black,
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
                      color: Colors.black,
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
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ))
                        .toList(),
                    hint: Text(
                      _roomSizeValue!,
                      style: TextStyle(
                        color: Colors.black,
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
              ElevatedButton(
                  onPressed: () => createRoom(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2.5, 50)),
                  ),
                  child: Text(
                    "Create",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
