import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinalLeaderBoard extends StatelessWidget {
  // final scoreBoard;
  // final String winner;
  //FinalLeaderBoard(this.scoreBoard, this.winner);
  var args = Get.arguments;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Column(
                  children: [
                    Container(
                      child: Text(
                        'LEADERBOARD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Doodle Gum',
                            fontSize: height > 600 ? 16 : 10,
                            letterSpacing: 5),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 30,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 40,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 30,
                        )
                      ],
                    ),
                    Divider(),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  args[1] != ""
                      ? "${args[1]} has won the game"
                      : "All players win the game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 26),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                      primary: true,
                      shrinkWrap: true,
                      itemCount: args[0].length,
                      itemBuilder: (context, index) {
                        var data = args[0][index].values;
                        return Card(
                            child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person),
                              args[1] == data.elementAt(0)
                                  ? Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                    )
                                  : Container()
                            ],
                          ),
                          title: Text(
                            data.elementAt(0),
                            style:
                                TextStyle(color: Colors.white54, fontSize: 22),
                          ),
                          trailing: Text(
                            data.elementAt(1),
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ));
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
