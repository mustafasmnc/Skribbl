import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:skribbl_clone/model/touch_points.dart';

class MyCustomPainter extends CustomPainter {
  List<TouchPoints> pointsList = <TouchPoints>[].obs;
  MyCustomPainter({required this.pointsList});
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //logic for points
    //if there is a point, we need to display full point
    //if there is a line, we need to connect the points

    for (var i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        //this is a line
        var x1_1 = pointsList[i].points.dx;
        var x1_2 = pointsList[i + 1].points.dx;
        var y1_1 = pointsList[i].points.dy;
        var y1_2 = pointsList[i + 1].points.dy;
        //parmağın kaldırılıp uzak bir noktda çizime devam edildiğinde son alan ile yeni başlanılan alan
        //arasına çizgi çizilmemesi için bu 2 nokta arasında x ve y kordinatları arasında en az 10 pixel
        //alan olması gerekiyor
        if (x1_2 - x1_1 < 10) {
          if (y1_2 - y1_1 < 10) {
            //print(pointsList[i].points.dx);
            canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
                pointsList[i].paint);
          }
        }
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        //this is a point
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));

        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
