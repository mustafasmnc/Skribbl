import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/controller/paint_screen_controller.dart';
import 'package:skribbl_clone/model/my_custom_painter.dart';
import 'package:skribbl_clone/model/touch_points.dart';
import 'package:skribbl_clone/screens/waiting_lobby_screen.dart';
import 'package:skribbl_clone/sidebar/player_scoreboard_drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/scheduler.dart';

class PaintScreen extends StatefulWidget {
  //final Map<String, String> data;
  //final String screenFrom;
  PaintScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  //String socketServer = 'http://192.168.1.107:4000';
  String socketServer = 'https://flutter-skribbl-clone.herokuapp.com';
  var args = Get.arguments;
  late IO.Socket socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  //Color selectedColor = Colors.black;
  double opacity = 1;
  //double strokeWidth = 2;
  //List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  //List<Map> messages = [];
  TextEditingController _txtController = TextEditingController();
  //int guessedUserCtr = 0;
  //int _totalTime = 60;
  //int _start = 60;
  Timer? _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  //List<Map> scoreBoard = [];
  //bool isTextInputReadOnly = false;
  //int maxPoints = 0;
  //String winner = "";
  //bool isShowFinalLeaderBoard = false;

  PaintScreenController paintScreenController = PaintScreenController();

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (paintScreenController.start.value == 0) {
        socket.emit('change-turn', dataOfRoom['name']);
        //print('socket:change-turn');
        setState(() {
          timer.cancel();
        });
      } else {
        //setState(() {
        paintScreenController.start.value--;
        //});
      }
    });
  }

  void renderTextBlank(String text) {
    paintScreenController.textBlankWidget.clear();
    for (var i = 0; i < text.length; i++) {
      if (text[i] != ' ') {
        paintScreenController.textBlankWidget.add(Text(
          '_',
          style: TextStyle(fontSize: 30),
        ));
      } else {
        paintScreenController.textBlankWidget.add(Text(
          ' ',
          style: TextStyle(fontSize: 30),
        ));
      }
    }
  }

  //socket io client connection
  connect() {
    socket = IO.io(
        socketServer,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.connect();

    if (args[1] == 'createRoom') {
      socket.emit('create-game', args[0]);
    } else {
      socket.emit('join-game', args[0]);
    }

    //listen to socket
    socket.onConnect((data) {
      //print("connected");
      socket.on('updateRoom', (roomData) {
        //print('roomData: ${roomData}');
        //print('socketId:::${socket.id}');
        //setState(() {
        renderTextBlank(roomData['word']);
        //paintScreenController.dataOfRoom.addAll(roomData);
        //print("---------------------");
        //print(paintScreenController.dataOfRoom);
        //});
        setState(() {
          dataOfRoom = roomData;
        });

        // if (roomData['isJoin'] != true) {
        //   startTimer();
        // }
        if (dataOfRoom['isJoin'] == false) {
          paintScreenController.startGame.value = true;
          startTimer();
        }
        paintScreenController.scoreBoard.clear();
        for (var i = 0; i < roomData['players'].length; i++) {
          //setState(() {
          paintScreenController.scoreBoard.add({
            'username': roomData['players'][i]['nickname'],
            'points': roomData['players'][i]['points'].toString()
          });
          //});
        }
      });

      socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = paintScreenController.selectedColor.value
                      .withOpacity(opacity)
                  ..strokeWidth = paintScreenController.strokeWidth.value));
          });
        }
      });

      socket.on('msg', (data) {
        //print('MSGDATA:: ${data['msg']}');
        //setState(() {
        paintScreenController.messages.add(data);
        paintScreenController.guessedUserCtr.value = data['guessedUserCtr'];
        //});
        if (paintScreenController.guessedUserCtr ==
            dataOfRoom['players'].length - 1) {
          socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      socket.on('change-player-turn', (data) {
        String oldWord = dataOfRoom['word'];
        Get.defaultDialog(
          barrierDismissible: false,
          title: '',
          content: Text('Word was $oldWord'),
          cancel: TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Close')),
        );
        Future.delayed(Duration(seconds: 2), () {
          renderTextBlank(data['word']);
          setState(() {
            dataOfRoom = data;
            points.clear();
          });
          paintScreenController.isTextInputReadOnly.value = false;
          paintScreenController.guessedUserCtr.value = 0;
          paintScreenController.start.value = 60;
          paintScreenController.selectedColor.value = Colors.black;
          paintScreenController.strokeWidth.value = 2.0;
          paintScreenController.messages.clear();
          //});
          SchedulerBinding.instance!.addPostFrameCallback((_) {
            Get.back();
            //   Navigator.of(context, rootNavigator: true).pop();
          });

          _timer!.cancel();
          startTimer();
        });

        // showDialog(
        //     barrierDismissible: false,
        //     context: context,
        //     builder: (context) {
        //       Future.delayed(Duration(seconds: 2), () {
        //         //setState(() {
        //         renderTextBlank(data['word']);

        //         setState(() {
        //           //print("dataOfRoom: " + dataOfRoom['turn']['nickname']);
        //           //print("Widget: ${widget.data['nickname']}");
        //           dataOfRoom = data;
        //           points.clear();
        //         });
        //         paintScreenController.isTextInputReadOnly.value = false;
        //         paintScreenController.guessedUserCtr.value = 0;
        //         paintScreenController.start.value = 60;
        //         paintScreenController.selectedColor.value = Colors.black;
        //         paintScreenController.strokeWidth.value = 2.0;
        //         paintScreenController.messages.clear();
        //         //});
        //         SchedulerBinding.instance!.addPostFrameCallback((_) {
        //           Navigator.of(context, rootNavigator: true).pop();
        //         });

        //         _timer!.cancel();
        //         startTimer();
        //       });
        //       return AlertDialog(
        //         title: Center(child: Text('Word was $oldWord')),
        //         actions: [
        //           TextButton(
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //               },
        //               child: Text('Close'))
        //         ],
        //       );
        //     });
      });

      socket.on('update-score', (roomData) {
        paintScreenController.scoreBoard.clear();
        for (var i = 0; i < roomData['players'].length; i++) {
          //setState(() {
          paintScreenController.scoreBoard.add({
            'username': roomData['players'][i]['nickname'],
            'points': roomData['players'][i]['points'].toString()
          });
          //});
        }
      });

      socket.on('show-leaderboard', (roomPlayers) {
        //print('show-leaderboard');
        //print(roomPlayers);
        paintScreenController.scoreBoard.clear();
        for (var i = 0; i < roomPlayers.length; i++) {
          //setState(() {
          paintScreenController.scoreBoard.add({
            'username': roomPlayers[i]['nickname'],
            'points': roomPlayers[i]['points'].toString()
          });
          //});
          //{
          //  'points':120,
          //  'username':'joe'
          //}
          //...
          if (paintScreenController.maxPoints.value <
              int.parse(paintScreenController.scoreBoard[i]['points'])) {
            paintScreenController.winner.value =
                paintScreenController.scoreBoard[i]['username'];
            paintScreenController.maxPoints.value =
                int.parse(paintScreenController.scoreBoard[i]['points']);
          }
        }
        //print(paintScreenController.isShowFinalLeaderBoard);
        setState(() {
          _timer!.cancel();
          socket.close();
          socket.clearListeners();
          socket.disconnect();
        });
        paintScreenController.isShowFinalLeaderBoard.value = true;
        Get.offAndToNamed('/final_leaderboard_screen', arguments: [
          paintScreenController.scoreBoard,
          paintScreenController.winner.value
        ]);
        //paintScreenController.startGame.value = false;
      });

      socket.on('start-game', (data) {
        setState(() {});
        paintScreenController.startGame.value = true;
        startTimer();
      });

      socket.on('color-change', (colorString) {
        //print('colorString: $colorString');
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        //setState(() {
        paintScreenController.selectedColor.value = otherColor;
        //});
      });

      socket.on('stroke-width', (value) {
        //setState(() {
        paintScreenController.strokeWidth.value = value;
        //});
      });

      socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });

      socket.on('close-input', (data) {
        socket.emit('update-score', args[0]['name']);
        //setState(() {
        paintScreenController.isTextInputReadOnly.value = true;
        //});
      });

      socket.on('user-disconnected', (roomData) {
        paintScreenController.scoreBoard.clear();
        for (var i = 0; i < roomData['players'].length; i++) {
          //setState(() {
          paintScreenController.scoreBoard.add({
            'username': roomData['players'][i]['nickname'],
            'points': roomData['players'][i]['points'].toString()
          });
          //});
        }
      });

      socket.on(
          'not-correct-game',
          // (data) => Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (context) => HomeScreen()),
          //     (route) => false),
          (data) => Get.offAndToNamed('home_screen'));

      //print("connection: ${socket.connected}");
      //socket.emit('message', 'test');
      //setState(() {});
    });

    socket.onDisconnect((data) {});
  }

  @override
  void dispose() {
    socket.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  void selectColor() {
    Get.defaultDialog(
      title: 'Choose color',
      content: SingleChildScrollView(
        child: BlockPicker(
            pickerColor: paintScreenController.selectedColor.value,
            onColorChanged: (color) {
              String colorString = color.toString();
              String valueString = colorString.split('(0x')[1].split(')')[0];
              // print(colorString);
              // print(valueString);
              Map map = {'color': valueString, 'roomName': dataOfRoom['name']};
              socket.emit('color-change', map);
            }),
      ),
      cancel: TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'Close',
            style: TextStyle(fontSize: 18),
          )),
    );
    // showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //           title: Text("Choose color"),
    //           content: SingleChildScrollView(
    //             child: BlockPicker(
    //                 pickerColor: paintScreenController.selectedColor.value,
    //                 onColorChanged: (color) {
    //                   String colorString = color.toString();
    //                   String valueString =
    //                       colorString.split('(0x')[1].split(')')[0];
    //                   // print(colorString);
    //                   // print(valueString);
    //                   Map map = {
    //                     'color': valueString,
    //                     'roomName': dataOfRoom['name']
    //                   };
    //                   socket.emit('color-change', map);
    //                 }),
    //           ),
    //           actions: [
    //             TextButton(
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //                 child: Text('Close'))
    //           ],
    //         ));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        //backgroundColor: Colors.grey[600],
        drawer: PlayerScore(paintScreenController.scoreBoard),
        //drawer: PlayerScore(),
        floatingActionButton: paintScreenController
                    .isShowFinalLeaderBoard.value ==
                false
            ? Container(
                margin: EdgeInsets.only(bottom: 30),
                child: FloatingActionButton(
                    onPressed: () {
                      //print(args[0]['name']);
                      if (args[0]['isPlayerAdmin'] == 'true') {
                        if (dataOfRoom['isJoin'] == true &&
                            dataOfRoom['players'].length > 1) {
                          socket.emit('start-game', args[0]['name']);
                        } else {
                          Get.snackbar(
                              'Error!', 'Room must have 2 players at least!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              icon: Icon(Icons.error_outline));
                        }
                      } else {
                        Get.snackbar(
                            'Error!', 'Only room leader can start game!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            icon: Icon(Icons.error_outline));
                      }
                    },
                    elevation: 7,
                    backgroundColor: Colors.white,
                    child: paintScreenController.startGame.value == false
                        ? Icon(Icons.play_arrow)
                        : Obx(
                            () => Text(
                              '${paintScreenController.start.value}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 22),
                            ),
                          )),
              )
            : Container(),
        body: dataOfRoom != null
            //? dataOfRoom['isJoin'] != true
            ? dataOfRoom['players'] != null
                ? paintScreenController.startGame.value == true
                    //? paintScreenController.isShowFinalLeaderBoard.value ==false
                    ? Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: width,
                                height: height * 0.55,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    if (dataOfRoom['turn']['nickname'] ==
                                        args[0]['nickname']) {
                                      //print(details.localPosition.dx);
                                      //print(details.globalPosition.dx);
                                      socket.emit('paint', {
                                        'details': {
                                          'dx': details.localPosition.dx,
                                          'dy': details.localPosition.dy
                                        },
                                        'roomName': args[0]['name']
                                      });
                                    }
                                  },
                                  onPanStart: (details) {
                                    if (dataOfRoom['turn']['nickname'] ==
                                        args[0]['nickname']) {
                                      //print(details.localPosition.dx);
                                      //print(details.globalPosition.dx);
                                      socket.emit('paint', {
                                        'details': {
                                          'dx': details.localPosition.dx,
                                          'dy': details.localPosition.dy
                                        },
                                        'roomName': args[0]['name']
                                      });
                                    }
                                  },
                                  onPanEnd: (details) {
                                    if (dataOfRoom['turn']['nickname'] ==
                                        args[0]['nickname']) {
                                      socket.emit('paint', {
                                        'details': null,
                                        'roomName': args[0]['name']
                                      });
                                    }
                                  },
                                  child: SizedBox.expand(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                            size: Size.infinite,
                                            painter: MyCustomPainter(
                                                pointsList: points)
                                            //painter: MyCustomPainter(),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              dataOfRoom['turn']['nickname'] ==
                                      args[0]['nickname']
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.grey),
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                selectColor();
                                              },
                                              icon: Obx(() => Icon(
                                                    Icons.color_lens,
                                                    color: paintScreenController
                                                        .selectedColor.value,
                                                  ))),
                                          Expanded(
                                              child: Obx(() => Slider(
                                                  min: 1.0,
                                                  max: 10.0,
                                                  label: "Strokewidth",
                                                  activeColor:
                                                      paintScreenController
                                                          .selectedColor.value,
                                                  value: paintScreenController
                                                      .strokeWidth.value,
                                                  onChanged: (double value) {
                                                    Map map = {
                                                      'value': value,
                                                      'roomName':
                                                          dataOfRoom['name']
                                                    };
                                                    socket.emit(
                                                        'stroke-width', map);
                                                  }))),
                                          IconButton(
                                              onPressed: () {
                                                socket.emit('clean-screen',
                                                    dataOfRoom['name']);
                                              },
                                              icon: Obx(() => Icon(
                                                    Icons.layers_clear,
                                                    color: paintScreenController
                                                        .selectedColor.value,
                                                  ))),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(top: 20),
                                    ),
                              dataOfRoom['turn']['nickname'] !=
                                      args[0]['nickname']
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children:
                                          paintScreenController.textBlankWidget,
                                    )
                                  : Center(
                                      child: Text(
                                        dataOfRoom['word'],
                                        style: TextStyle(fontSize: 26),
                                      ),
                                    ),

                              //Displaying messages
                              Obx(
                                () => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 2),
                                  height:
                                      MediaQuery.of(context).size.height * 0.28,
                                  child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      itemCount:
                                          paintScreenController.messages.length,
                                      itemBuilder: (context, index) {
                                        var msg = paintScreenController
                                            .messages[index].values;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                msg.elementAt(0) + ": ",
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                msg.elementAt(2),
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 19,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        // return ListTile(
                                        //   title: Text(
                                        //     msg.elementAt(0),
                                        //     style: TextStyle(
                                        //       color: Colors.black,
                                        //       fontSize: 19,
                                        //       fontWeight: FontWeight.bold,
                                        //     ),
                                        //   ),
                                        //   subtitle: Text(
                                        //     msg.elementAt(1),
                                        //     style: TextStyle(
                                        //       color: Colors.grey,
                                        //       fontSize: 16,
                                        //     ),
                                        //   ),
                                        // );
                                      }),
                                ),
                              ),
                            ],
                          ),
                          dataOfRoom['turn']['nickname'] != args[0]['nickname']
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: TextField(
                                        readOnly: paintScreenController
                                            .isTextInputReadOnly.value,
                                        controller: _txtController,
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty) {
                                            var wordValue = value
                                                .trimLeft()
                                                .trimRight()
                                                .toLowerCase();
                                            Map map = {
                                              'username': args[0]['nickname'],
                                              'socketId': socket.id,
                                              'msg': wordValue,
                                              'word': dataOfRoom['word'],
                                              'roomName': args[0]['name'],
                                              'guessedUserCtr':
                                                  paintScreenController
                                                      .guessedUserCtr
                                                      .toInt(),
                                              'totalTime': paintScreenController
                                                  .totalTime
                                                  .toInt(),
                                              'timeTaken': paintScreenController
                                                      .totalTime.value
                                                      .toInt() -
                                                  paintScreenController
                                                      .start.value
                                                      .toInt(),
                                            };
                                            //print('MAP: $map');
                                            //print("ASD: "+dataOfRoom['players']);
                                            //print(paintScreenController.messages);
                                            //print(widget.data['nickname']);
                                            // print(widget.data['name']);
                                            // print( dataOfRoom['word']);
                                            socket.emit('server-msg', map);
                                            _txtController.clear();
                                          }
                                        },
                                        autocorrect: false,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent)),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                            filled: true,
                                            fillColor: Colors.black54,
                                            hintText: 'Your guess',
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            )),
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          SafeArea(
                            child: IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: Colors.black,
                              ),
                              onPressed: () =>
                                  scaffoldKey.currentState!.openDrawer(),
                            ),
                          )
                        ],
                      )
                    //: //Get.offAndToNamed('/final_leaderboard_screen', arguments: [paintScreenController.scoreBoard, paintScreenController.winner.value]);
                    //FinalLeaderBoard(paintScreenController.scoreBoard,paintScreenController.winner.value)
                    : WaitingLobbyScreen(
                        lobbyName: dataOfRoom['name'],
                        numberOfPlayers: dataOfRoom['players'].length,
                        occopancy: dataOfRoom['occupancy'],
                        lobbyLevel: dataOfRoom['level'],
                        players: dataOfRoom['players'],
                      )
                : Center(child: CircularProgressIndicator())
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
