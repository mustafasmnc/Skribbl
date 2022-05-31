import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/controller/paint_screen_controller.dart';

class PlayerScore extends StatelessWidget {
  RxList<Map> userData;
  PlayerScore(this.userData);

  PaintScreenController paintScreenController = PaintScreenController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Drawer(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'POINTS',
                style: TextStyle(letterSpacing: 2, fontSize: 18),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      var data = userData[index].values;
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          data.elementAt(0),
                          style: TextStyle(color: Colors.white54, fontSize: 22),
                        ),
                        trailing: Text(
                          data.elementAt(1),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
