import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/model/my_custom_painter.dart';
import 'package:skribbl_clone/model/touch_points.dart';
import 'package:skribbl_clone/screens/waiting_lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({Key? key, required this.data, required this.screenFrom})
      : super(key: key);

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  String socketServer = 'serverlink';
  late IO.Socket socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController _txtController = TextEditingController();
  int guessedUserCtr = 0;
  int _totalTime = 60;
  int _start = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (var i = 0; i < text.length; i++) {
      textBlankWidget.add(Text(
        '_',
        style: TextStyle(fontSize: 30),
      ));
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

    if (widget.screenFrom == 'createRoom') {
      socket.emit('create-game', widget.data);
    } else {
      socket.emit('join-game', widget.data);
    }

    //listen to socket
    socket.onConnect((data) {
      print("connected");
      socket.on('updateRoom', (roomData) {
        //print('roomData: ${roomData['word']}');
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
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
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        }
      });

      socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if (guessedUserCtr == dataOfRoom['players'].length - 1) {
          socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  guessedUserCtr = 0;
                  _start = 60;
                  points.clear();
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                title: Center(child: Text('Word was $oldWord')),
              );
            });
      });

      socket.on('color-change', (colorString) {
        print('colorString: $colorString');
        int value = int.parse(colorString, radix: 16);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
          print(selectedColor);
        });
      });

      socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });

      //print("connection: ${socket.connected}");
      //socket.emit('message', 'test');
      //setState(() {});
    });

    socket.onDisconnect((data){
      
    });
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Choose color"),
              content: SingleChildScrollView(
                child: BlockPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      String colorString = color.toString();
                      String valueString =
                          colorString.split('(0x')[1].split(')')[0];
                      // print(colorString);
                      // print(valueString);
                      Map map = {
                        'color': valueString,
                        'roomName': dataOfRoom['name']
                      };
                      socket.emit('color-change', map);
                    }),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '$_start',
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
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
                              //print(details.localPosition.dx);
                              socket.emit('paint', {
                                'details': {
                                  'dx': details.localPosition.dx,
                                  'dy': details.localPosition.dy
                                },
                                'roomName': widget.data['name']
                              });
                            },
                            onPanStart: (details) {
                              //print(details.localPosition.dx);
                              socket.emit('paint', {
                                'details': {
                                  'dx': details.localPosition.dx,
                                  'dy': details.localPosition.dy
                                },
                                'roomName': widget.data['name']
                              });
                            },
                            onPanEnd: (details) {
                              socket.emit('paint', {
                                'details': null,
                                'roomName': widget.data['name']
                              });
                            },
                            child: SizedBox.expand(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                      size: Size.infinite,
                                      painter:
                                          MyCustomPainter(pointsList: points)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  selectColor();
                                },
                                icon: Icon(
                                  Icons.color_lens,
                                  color: selectedColor,
                                )),
                            Expanded(
                                child: Slider(
                                    min: 1.0,
                                    max: 10.0,
                                    label: "Strokewidth",
                                    activeColor: selectedColor,
                                    value: strokeWidth,
                                    onChanged: (double value) {
                                      Map map = {
                                        'value': value,
                                        'roomName': dataOfRoom['name']
                                      };
                                      socket.emit('stroke-width', map);
                                    })),
                            IconButton(
                                onPressed: () {
                                  socket.emit(
                                      'clean-screen', dataOfRoom['name']);
                                },
                                icon: Icon(
                                  Icons.layers_clear,
                                  color: selectedColor,
                                )),
                          ],
                        ),
                        dataOfRoom['turn']['nickname'] !=
                                widget.data['nickname']
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: textBlankWidget,
                              )
                            : Center(
                                child: Text(
                                  dataOfRoom['word'],
                                  style: TextStyle(fontSize: 26),
                                ),
                              ),
                        //Displaying messages
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                var msg = messages[index].values;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.elementAt(0) + ": ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        msg.elementAt(1),
                                        style: TextStyle(
                                          color: Colors.black54,
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
                      ],
                    ),
                    dataOfRoom['turn']['nickname'] != widget.data['nickname']
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: TextField(
                                controller: _txtController,
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    Map map = {
                                      'username': widget.data['nickname'],
                                      'msg': value.trim(),
                                      'word': dataOfRoom['word'],
                                      'roomName': widget.data['name'],
                                      'guessedUserCtr': guessedUserCtr,
                                      'totalTime': _totalTime,
                                      'timeTaken': _totalTime - _start,
                                    };
                                    socket.emit('msg', map);
                                    _txtController.clear();
                                  }
                                },
                                autocorrect: false,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    filled: true,
                                    fillColor: Color(0xFFF5F5FA),
                                    hintText: 'Your guess',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    )),
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          )
                        : Container()
                  ],
                )
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  numberOfPlayers: dataOfRoom['players'].length,
                  occopancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
