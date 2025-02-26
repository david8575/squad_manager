import 'package:flutter/material.dart';

class TeamManagementScreen extends StatefulWidget {
  @override
  _TeamManagementScreenState createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> players = [];

  void _addPlayer() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        players.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      players.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("팀 선수 등록")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "선수 이름 입력",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPlayer,
              child: Text("선수 추가"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePlayer(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
