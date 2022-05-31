import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/model/touch_points.dart';

class PaintScreenController extends GetxController {
  RxMap dataOfRoom = {}.obs;
  RxBool startGame = false.obs;
  RxList<TouchPoints> points = <TouchPoints>[].obs;
  RxList<Widget> textBlankWidget = <Widget>[].obs;
  RxList<Map> messages = <Map>[].obs;
  var guessedUserCtr = 0.obs;
  var totalTime = 60.obs;
  var start = 60.obs;
  RxList<Map> scoreBoard = <Map>[].obs;
  var isTextInputReadOnly = false.obs;
  var maxPoints = 0.obs;
  var winner = "".obs;
  var isShowFinalLeaderBoard = false.obs;
  var selectedColor = Colors.black.obs;
  RxDouble strokeWidth = 2.0.obs;
}
