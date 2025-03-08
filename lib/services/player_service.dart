import '../models/player.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  final List<Player> _players = [];

  List<Player> get players => List.unmodifiable(_players);

  void addPlayer(Player player) {
    _players.add(player);
  }
} 