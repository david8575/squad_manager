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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('선수 목록'),
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
                    subtitle: Text(
                      '등번호: ${player.number} | 나이: ${player.age}\n주 포지션: ${player.mainPosition} | 부 포지션: ${player.subPosition}',
                    ),
                  ),
                );
              },
            ),
    );
  }
} 