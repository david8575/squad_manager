import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';
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
  final GlobalKey _globalKey = GlobalKey();
  
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
        title: const Text('포메이션'),
        backgroundColor: Colors.blue,
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
            child: RepaintBoundary(
              key: _globalKey,
              child: DragTarget<Player>(
                builder: (context, candidateData, rejectedData) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // 축구장 배경
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.95,
                          heightFactor: 0.95,
                          child: CustomPaint(
                            painter: SoccerFieldPainter(),
                            size: Size.infinite,
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
    
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100,
          name: "formation_${DateTime.now().millisecondsSinceEpoch}"
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['isSuccess'] ? '포메이션이 저장되었습니다' : '저장에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장 중 오류가 발생했습니다')),
        );
      }
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

class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 잔디 배경 그리기
    final backgroundPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // 잔디 패턴 그리기 (가로 방향)
    final stripePaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.fill;
    
    final stripeCount = 10;
    final stripeHeight = size.height / stripeCount;
    for (var i = 0; i < stripeCount; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        stripePaint,
      );
    }

    // 경기장 라인 그리기
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 외곽선
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linePaint);

    // 중앙선 (가로)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    // 센터 서클
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height / 10,
      linePaint,
    );

    // 센터 점
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2,
      Paint()..color = Colors.white,
    );

    // 페널티 박스 (위쪽)
    final penaltyBoxWidth = size.width * 0.4;
    final penaltyBoxHeight = size.height * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        0,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      linePaint,
    );

    // 골 박스 (위쪽)
    final goalBoxWidth = size.width * 0.2;
    final goalBoxHeight = size.height * 0.08;
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalBoxWidth) / 2,
        0,
        goalBoxWidth,
        goalBoxHeight,
      ),
      linePaint,
    );

    // 페널티 박스 (아래쪽)
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyBoxWidth) / 2,
        size.height - penaltyBoxHeight,
        penaltyBoxWidth,
        penaltyBoxHeight,
      ),
      linePaint,
    );

    // 골 박스 (아래쪽)
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalBoxWidth) / 2,
        size.height - goalBoxHeight,
        goalBoxWidth,
        goalBoxHeight,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}