import 'dart:convert';

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
  final String? contractDuration;
  final String? contractStart;
  final String? contractEnd;

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
    this.contractDuration,
    this.contractStart,
    this.contractEnd,
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
      contractDuration: map['contractDuration']?.toString() ?? map['contract_duration']?.toString(),
      contractStart: map['contractStart']?.toString() ?? map['contract_start']?.toString(),
      contractEnd: map['contractEnd']?.toString() ?? map['contract_end']?.toString(),
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
      'contractDuration': contractDuration,
      'contractStart': contractStart,
      'contractEnd': contractEnd,
    };
  }

  // Métodos JSON para base de datos
  String toJson() {
    return json.encode(toMap());
  }

  factory Player.fromJson(String jsonString) {
    return Player.fromMap(json.decode(jsonString));
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
    String? contractDuration,
    String? contractStart,
    String? contractEnd,
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
      contractDuration: contractDuration ?? this.contractDuration,
      contractStart: contractStart ?? this.contractStart,
      contractEnd: contractEnd ?? this.contractEnd,
    );
  }

  bool get isFreeAgent => teamId == null || teamId!.isEmpty;

  DateTime? get contractStartDate {
    if (contractStart == null || contractStart!.trim().isEmpty) return null;
    return DateTime.tryParse(contractStart!.trim());
  }

  DateTime? get contractEndDate {
    if (contractEnd == null || contractEnd!.trim().isEmpty) return null;
    return DateTime.tryParse(contractEnd!.trim());
  }

  int? get contractDurationDays {
    final start = contractStartDate;
    final end = contractEndDate;
    if (start == null || end == null || end.isBefore(start)) return null;
    return end.difference(start).inDays + 1;
  }

  String? get contractDurationFormatted {
    final days = contractDurationDays;
    if (days != null) return '$days dias';
    if (contractDuration == null || contractDuration!.trim().isEmpty) return null;
    return contractDuration;
  }
}