import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/widgets/custom_button.dart';

class HowToPlayScreen extends StatelessWidget {
  HowToPlayScreen({Key? key}) : super(key: key);
  List howToPlayText = [
    "Create a room by entering your username, room name, number of rounds of the game and number of players in the room.",
    "Join the room by entering the username and the created room name.",
    "For the game to start, either all players must enter the room or if there are at least 2 players in the room, the player who created the room can start the game.",
    "Wait for somebody to start drawing. One person will draw at a time, and you all take it in turns. In the middle, there are a certain number of dashes to indicate how many letters are in the word.",
    "Guess the word using the drawing and the dashes/letters in middle. You have an unlimited amount of guesses so if you get it wrong you can guess again. If somebody guesses the word, it will say '--- has guessed the word'. That person's messages won't appear to players who haven't guessed the word yet for that round, so nobody can cheat.",
    "Start drawing your image. Draw the image as clearly as you can and only draw something relating to the word. You have a variety of colours to use to make your drawing better."
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "HOW TO PLAY",
            style: TextStyle(
                letterSpacing: 2, fontFamily: 'Doodle Gum', fontSize: 12),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    primary: true,
                    shrinkWrap: true,
                    itemCount: howToPlayText.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              index == 0
                                  ? "1-1: "
                                  : index == 1
                                      ? "1-2: "
                                      : "${index + 1}: ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Flexible(
                                child: Text("${howToPlayText[index]}",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(fontSize: 19))),
                          ],
                        ),
                      );
                    }),
                SizedBox(height: 10),
                Text(
                  "Have Fun 😊",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4),
                ),
                SizedBox(height: 20),
                CustomButton(
                  title: 'Home Page',
                  color: Colors.cyan,
                  onTap: () => Get.back(),
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => JoinRoomScreen(),
                  //)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
