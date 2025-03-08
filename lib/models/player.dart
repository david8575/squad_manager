class Player {
  final String name;
  final int age;
  final int number;
  final String mainPosition;
  final String subPosition;

  Player({
    required this.name,
    required this.age,
    required this.number,
    required this.mainPosition,
    required this.subPosition,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'number': number,
      'mainPosition': mainPosition,
      'subPosition': subPosition,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      age: json['age'],
      number: json['number'],
      mainPosition: json['mainPosition'],
      subPosition: json['subPosition'],
    );
  }
} 