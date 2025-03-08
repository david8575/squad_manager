import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';
import '../models/player_position.dart';

class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  List<Player> availablePlayers = [];
  List<PlayerPosition> placedPlayers = [];
  
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
        availablePlayers = decodedPlayers.map((player) => Player.fromJson(player)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포메이션 배치'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFormation,
          ),
        ],
      ),
      body: Column(
        children: [
          // 축구장 영역
          Expanded(
            flex: 5,
            child: DragTarget<Player>(
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 축구장 이미지
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.95,
                        heightFactor: 0.95,
                        child: Image.asset(
                          'assets/images/field.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    // 배치된 선수들
                    ...placedPlayers.map((playerPosition) {
                      return Positioned(
                        left: playerPosition.position.dx,
                        top: playerPosition.position.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              final index = placedPlayers.indexOf(playerPosition);
                              placedPlayers[index] = PlayerPosition(
                                player: playerPosition.player,
                                position: Offset(
                                  playerPosition.position.dx + details.delta.dx,
                                  playerPosition.position.dy + details.delta.dy,
                                ),
                              );
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              availablePlayers.add(playerPosition.player);
                              placedPlayers.remove(playerPosition);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('선수가 목록으로 이동되었습니다'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${playerPosition.player.number}.${playerPosition.player.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
              onAcceptWithDetails: (details) {
                final player = details.data;
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(details.offset);
                
                setState(() {
                  placedPlayers.add(
                    PlayerPosition(
                      player: player,
                      position: localPosition,
                    ),
                  );
                  availablePlayers.remove(player);
                });
              },
            ),
          ),
          // 선수 목록 패널
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Draggable<Player>(
                    data: player,
                    feedback: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${player.number}.${player.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    childWhenDragging: PlayerCard(
                      player: player,
                      opacity: 0.5,
                    ),
                    child: PlayerCard(player: player),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFormation() async {
    final prefs = await SharedPreferences.getInstance();
    final formationJson = jsonEncode(
      placedPlayers.map((pp) => pp.toJson()).toList(),
    );
    await prefs.setString('formation', formationJson);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포메이션이 저장되었습니다')),
      );
    }
  }
}

class PlayerCard extends StatelessWidget {
  final Player player;
  final double opacity;
  final bool isDragging;

  const PlayerCard({
    super.key,
    required this.player,
    this.opacity = 1.0,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = isDragging || opacity < 1.0;
    
    if (isSmall) {
      return Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDragging ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            '${player.number}.${player.name}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: isDragging ? 8 : 1,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text('${player.number}번'),
              Text(
                player.mainPosition,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}