import 'package:flutter/material.dart';

class FinalLeaderBoard extends StatelessWidget {
  final scoreBoard;
  final String winner;
  FinalLeaderBoard(this.scoreBoard, this.winner);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: double.maxFinite,
        child: Column(
          children: [
            ListView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: scoreBoard.length,
                itemBuilder: (context, index) {
                  var data = scoreBoard[index].values;
                  return ListTile(
                    title: Text(
                      data.elementAt(0),
                      style: TextStyle(color: Colors.white54, fontSize: 22),
                    ),
                    trailing: Text(
                      data.elementAt(1),
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }),
            Text(
              winner!=""?"$winner has won the game":"All players win the game",
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            )
          ],
        ),
      ),
    );
  }
}
