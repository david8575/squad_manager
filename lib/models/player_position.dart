import 'package:flutter/material.dart';
import 'player.dart';

class PlayerPosition {
  final Player player;
  final Offset position;

  PlayerPosition({
    required this.player,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'player': player.toJson(),
      'position': {'dx': position.dx, 'dy': position.dy},
    };
  }

  factory PlayerPosition.fromJson(Map<String, dynamic> json) {
    return PlayerPosition(
      player: Player.fromJson(json['player']),
      position: Offset(
        json['position']['dx'] as double,
        json['position']['dy'] as double,
      ),
    );
  }
}
