import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playersJson = prefs.getString('players');
    if (playersJson != null) {
      final List<dynamic> decodedPlayers = jsonDecode(playersJson);
      setState(() {
        players = decodedPlayers.map((player) => Player.fromJson(player)).toList();
      });
    }
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedPlayers = jsonEncode(players.map((player) => player.toJson()).toList());
    await prefs.setString('players', encodedPlayers);
  }

  Future<void> _deletePlayer(int index) async {
    setState(() {
      players.removeAt(index);
    });
    await _savePlayers();
  }

  Future<void> _editPlayer(int index) async {
    final player = players[index];
    final TextEditingController nameController = TextEditingController(text: player.name);
    final TextEditingController numberController = TextEditingController(text: player.number.toString());
    final TextEditingController ageController = TextEditingController(text: player.age.toString());
    final TextEditingController mainPositionController = TextEditingController(text: player.mainPosition);
    final TextEditingController subPositionController = TextEditingController(text: player.subPosition);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선수 정보 수정'),
        backgroundColor: Colors.blue,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: '등번호'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: mainPositionController,
                decoration: const InputDecoration(labelText: '주 포지션'),
              ),
              TextField(
                controller: subPositionController,
                decoration: const InputDecoration(labelText: '부 포지션'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                players[index] = Player(
                  name: nameController.text,
                  number: int.parse(numberController.text),
                  age: int.parse(ageController.text),
                  mainPosition: mainPositionController.text,
                  subPosition: subPositionController.text,
                );
              });
              _savePlayers();
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('선수 목록'),
        backgroundColor: Colors.blue,
      ),
      body: players.isEmpty
          ? const Center(
              child: Text('등록된 선수가 없습니다.'),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(player.name),
                    tileColor: Colors.blue[200],
                    subtitle: Text(
                      '등번호: ${player.number} | 나이: ${player.age}\n주 포지션: ${player.mainPosition} | 부 포지션: ${player.subPosition}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPlayer(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('선수 삭제'),
                              content: Text('${player.name} 선수를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deletePlayer(index);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 