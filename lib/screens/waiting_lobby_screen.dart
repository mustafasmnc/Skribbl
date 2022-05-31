import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaitingLobbyScreen extends StatefulWidget {
  final int occopancy;
  final int numberOfPlayers;
  final String lobbyName;
  final String lobbyLevel;
  final players;
  WaitingLobbyScreen(
      {Key? key,
      required this.occopancy,
      required this.numberOfPlayers,
      required this.lobbyName,
      this.players,
      required this.lobbyLevel})
      : super(key: key);

  @override
  State<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends State<WaitingLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Waiting for ${widget.occopancy - widget.numberOfPlayers} players join',
                style: TextStyle(fontSize: 26, color: Colors.white54),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                          colors: [
                            Colors.black12,
                            widget.lobbyLevel == 'Easy'
                                ? Colors.greenAccent
                                : widget.lobbyLevel == 'Medium'
                                    ? Colors.blueAccent
                                    : widget.lobbyLevel == 'Hard'
                                        ? Colors.redAccent
                                        : Colors.purpleAccent,
                          ],
                          begin: const FractionalOffset(1.0, 1.0),
                          end: const FractionalOffset(1.0, 0.1),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: Center(
                      child: Text(
                        widget.lobbyLevel.toUpperCase(),
                        style: TextStyle(
                            letterSpacing: 3,
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Room Name: ' + widget.lobbyName,
                        style: TextStyle(color: Colors.white54, fontSize: 18),
                      ),
                      Container(
                        width: 70,
                        child: TextField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          onTap: () {
                            //copy room name
                            Clipboard.setData(
                                ClipboardData(text: widget.lobbyName));
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied')));
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              filled: true,
                              fillColor: Colors.grey,
                              hintText: 'Copy',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                  letterSpacing: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text('PLAYERS',
                style: TextStyle(
                    fontSize: 20, color: Colors.white54, letterSpacing: 2)),
            Expanded(
              child: ListView.builder(
                  primary: true,
                  shrinkWrap: true,
                  itemCount: widget.numberOfPlayers,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text("${index + 1})",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54)),
                      title: Text(widget.players[index]['nickname'],
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54)),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
