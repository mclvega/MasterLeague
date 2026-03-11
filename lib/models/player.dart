class Player {
  final String id;
  final String name;
  final String position;
  final double price;
  final String? teamId;
  final int overall;
  final String club;
  final String nationality;
  final int age;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.price,
    this.teamId,
    required this.overall,
    required this.club,
    required this.nationality,
    required this.age,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      position: map['position']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      teamId: map['teamId']?.toString(),
      overall: (map['overall'] as num?)?.toInt() ?? 0,
      club: map['club']?.toString() ?? '',
      nationality: map['nationality']?.toString() ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'price': price,
      'teamId': teamId,
      'overall': overall,
      'club': club,
      'nationality': nationality,
      'age': age,
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? position,
    double? price,
    String? teamId,
    int? overall,
    String? club,
    String? nationality,
    int? age,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      price: price ?? this.price,
      teamId: teamId ?? this.teamId,
      overall: overall ?? this.overall,
      club: club ?? this.club,
      nationality: nationality ?? this.nationality,
      age: age ?? this.age,
    );
  }

  bool get isFreeAgent => teamId == null || teamId!.isEmpty;
}