import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_clone/controller/chat_controller.dart';
import 'package:skribbl_clone/model/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

Color purple = Color(0XFF6c5ce7);
Color black = Color(0XFF191919);
Color white = Colors.white;

class _ChatScreenState extends State<ChatScreen> {
  String socketServer = 'serverlink';
  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    //try {
    socket = IO.io(
        socketServer,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.connect();
    // socket.onConnect((_) {
    //   print("connected");
    //   print("connection: ${socket.connected}");
    //   //socket.emit('message', 'test');
    //   //setState(() {});
    // });
    setUpSocketListener();
    //} catch (e) {
    // print("error: " + e.toString());
    //}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: Obx(
              () => Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Connected User ${chatController.connectedUser}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            )),
            Expanded(
                flex: 9,
                child: Obx(
                  () => ListView.builder(
                      itemCount: chatController.chatMessages.length,
                      itemBuilder: (context, index) {
                        var currentItem = chatController.chatMessages[index];
                        return MessageItem(
                          sentByMe:
                              currentItem.sentByMe == socket.id ? true : false,
                          message: currentItem.message,
                        );
                      }),
                )),
            Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: purple,
                    controller: msgInputController,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Container(
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: purple,
                          ),
                          child: IconButton(
                            onPressed: () {
                              sendMessage(msgInputController.text);
                              msgInputController.text = "";
                            },
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJson);
    //print(messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
    // chatController.chatMessages.forEach((element) {
    //   print(element.message);
    // });
    print(chatController.chatMessages.length);
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      //print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });

    socket.on('connected-user', (data) {
      //print(data);
      chatController.connectedUser.value = data;
    });
  }
}

class MessageItem extends StatelessWidget {
  final bool sentByMe;
  final String message;
  const MessageItem({Key? key, required this.sentByMe, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sentByMe ? purple : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: sentByMe ? white : purple,
              ),
            ),
            SizedBox(width: 5),
            Text(
              "1:11 AM",
              style: TextStyle(
                fontSize: 12,
                color: (sentByMe ? white : purple).withOpacity(.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
