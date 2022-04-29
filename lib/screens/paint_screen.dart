import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:skribbl_clone/model/my_custom_painter.dart';
import 'package:skribbl_clone/model/touch_points.dart';
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

  @override
  void initState() {
    super.initState();
    connect();
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
        print('roomData: ${roomData['word']}');
        setState(() {
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          //start the timer
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
      body: Stack(
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
                    socket.emit('paint',
                        {'details': null, 'roomName': widget.data['name']});
                  },
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: RepaintBoundary(
                        child: CustomPaint(
                            size: Size.infinite,
                            painter: MyCustomPainter(pointsList: points)),
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
                        socket.emit('clean-screen', dataOfRoom['name']);
                      },
                      icon: Icon(
                        Icons.layers_clear,
                        color: selectedColor,
                      )),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
