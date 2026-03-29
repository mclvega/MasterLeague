import 'dart:convert';

class Player {
  static const Object _undefined = Object();

  final String id;
  final String name;
  final String position;
  final double price;
  final String? teamId;
  final bool isFree;
  final int overall;
  final String club;
  final String nationality;
  final int age;
  final String? contractDuration;
  final String? contractStart;
  final String? contractEnd;
  final String? photoUrl;
  final String playerStyle;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.price,
    this.teamId,
    this.isFree = false,
    required this.overall,
    required this.club,
    required this.nationality,
    required this.age,
    this.contractDuration,
    this.contractStart,
    this.contractEnd,
    this.photoUrl,
    required this.playerStyle,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    final rawTeamId = map['teamId']?.toString() ?? map['team_id']?.toString();
    final normalizedTeamId = rawTeamId == null || rawTeamId.trim().isEmpty
        ? null
        : rawTeamId.trim();
    final isFree = _parseBool(
      map['isFree'] ??
          map['is_free'] ??
          map['isfree'] ??
          map['freeAgent'] ??
          map['free_agent'],
      fallback: normalizedTeamId == null,
    );

    return Player(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      position: map['position']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      teamId: isFree ? null : normalizedTeamId,
      isFree: isFree,
      overall: (map['overall'] as num?)?.toInt() ?? 0,
      club: map['club']?.toString() ?? '',
      nationality: map['nationality']?.toString() ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      contractDuration: map['contractDuration']?.toString() ?? map['contract_duration']?.toString(),
      contractStart: map['contractStart']?.toString() ?? map['contract_start']?.toString(),
      contractEnd: map['contractEnd']?.toString() ?? map['contract_end']?.toString(),
      photoUrl: map['photoUrl']?.toString() ?? map['photo_url']?.toString() ?? map['photo']?.toString(),
      playerStyle: map['playerStyle']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'price': price,
      'teamId': assignedTeamId,
      'isFree': isFreeAgent,
      'overall': overall,
      'club': club,
      'nationality': nationality,
      'age': age,
      'contractDuration': contractDuration,
      'contractStart': contractStart,
      'contractEnd': contractEnd,
      'photoUrl': photoUrl,
      'playerStyle': playerStyle,
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
    Object? teamId = _undefined,
    bool? isFree,
    int? overall,
    String? club,
    String? nationality,
    int? age,
    Object? contractDuration = _undefined,
    Object? contractStart = _undefined,
    Object? contractEnd = _undefined,
    Object? photoUrl = _undefined,
    String? playerStyle,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      price: price ?? this.price,
      teamId: identical(teamId, _undefined) ? this.teamId : teamId as String?,
      isFree: isFree ?? this.isFree,
      overall: overall ?? this.overall,
      club: club ?? this.club,
      nationality: nationality ?? this.nationality,
      age: age ?? this.age,
      contractDuration: identical(contractDuration, _undefined)
          ? this.contractDuration
          : contractDuration as String?,
      contractStart: identical(contractStart, _undefined)
          ? this.contractStart
          : contractStart as String?,
      contractEnd: identical(contractEnd, _undefined)
          ? this.contractEnd
          : contractEnd as String?,
      photoUrl: identical(photoUrl, _undefined) ? this.photoUrl : photoUrl as String?,
      playerStyle: playerStyle ?? this.playerStyle,
    );
  }

  String? get assignedTeamId {
    final normalizedTeamId = teamId?.trim();
    if (isFreeAgent || normalizedTeamId == null || normalizedTeamId.isEmpty) {
      return null;
    }
    return normalizedTeamId;
  }

  bool get isFreeAgent => isFree || teamId == null || teamId!.trim().isEmpty;

  DateTime? get contractStartDate {
    if (contractStart == null || contractStart!.trim().isEmpty) return null;
    return DateTime.tryParse(contractStart!.trim());
  }

  DateTime? get contractEndDate {
    if (contractEnd == null || contractEnd!.trim().isEmpty) return null;
    return DateTime.tryParse(contractEnd!.trim());
  }

  bool get hasContractDates => contractStartDate != null || contractEndDate != null;

  int? get contractDurationDays {
    final start = contractStartDate;
    final end = contractEndDate;
    if (start == null || end == null || end.isBefore(start)) return null;
    return end.difference(start).inDays + 1;
  }

  String? get contractDurationFormatted {
    if (!hasContractDates) return null;
    final days = contractDurationDays;
    if (days != null) return '$days dias';
    if (contractDuration == null || contractDuration!.trim().isEmpty) return null;
    return contractDuration;
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return fallback;
    if ({'1', 'true', 'si', 'sí', 'yes', 'y'}.contains(normalized)) return true;
    if ({'0', 'false', 'no', 'n'}.contains(normalized)) return false;
    return fallback;
  }
}