import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';

class PlayerRegistrationScreen extends StatefulWidget {
  const PlayerRegistrationScreen({super.key});

  @override
  State<PlayerRegistrationScreen> createState() => _PlayerRegistrationScreenState();
}

class _PlayerRegistrationScreenState extends State<PlayerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _numberController = TextEditingController();
  final _mainPositionController = TextEditingController();
  final _subPositionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _numberController.dispose();
    _mainPositionController.dispose();
    _subPositionController.dispose();
    super.dispose();
  }

  Future<void> _savePlayers(Player newPlayer) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingPlayersJson = prefs.getString('players');
    List<Player> players = [];
    
    if (existingPlayersJson != null) {
      final List<dynamic> decodedPlayers = jsonDecode(existingPlayersJson);
      players = decodedPlayers.map((player) => Player.fromJson(player)).toList();
    }
    
    players.add(newPlayer);
    final String updatedPlayersJson = jsonEncode(players.map((p) => p.toJson()).toList());
    await prefs.setString('players', updatedPlayersJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('선수 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '선수 이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '선수 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: '나이',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: '등번호',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '등번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mainPositionController,
                decoration: const InputDecoration(
                  labelText: '주 포지션',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '주 포지션을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subPositionController,
                decoration: const InputDecoration(
                  labelText: '부 포지션',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '부 포지션을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final player = Player(
                      name: _nameController.text,
                      age: int.parse(_ageController.text),
                      number: int.parse(_numberController.text),
                      mainPosition: _mainPositionController.text,
                      subPosition: _subPositionController.text,
                    );
                    
                    await _savePlayers(player);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('선수가 등록되었습니다')),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('등록하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 