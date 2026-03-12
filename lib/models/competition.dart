import 'dart:convert';

enum CompetitionType { league, cup, tournament, event }

enum CompetitionStatus { upcoming, ongoing, completed }

class Competition {
  final String id;
  final String name;
  final CompetitionType type;
  final CompetitionStatus status;
  final List<String> participantTeamIds;
  final DateTime startDate;
  final DateTime? endDate;
  final double prizePool;
  final String? description;
  final Map<String, dynamic>? rules;

  Competition({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.participantTeamIds = const [],
    required this.startDate,
    this.endDate,
    required this.prizePool,
    this.description,
    this.rules,
  });

  factory Competition.fromMap(Map<String, dynamic> map) {
    final rawType = map['type']?.toString() ?? '';

    return Competition(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: _parseCompetitionType(rawType),
      status: CompetitionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => CompetitionStatus.upcoming,
      ),
      participantTeamIds: List<String>.from(map['participantTeamIds'] ?? []),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      prizePool: (map['prizePool'] as num?)?.toDouble() ?? 0.0,
      description: map['description']?.toString(),
      rules: map['rules'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'participantTeamIds': participantTeamIds,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prizePool': prizePool,
      'description': description,
      'rules': rules,
    };
  }

  // Métodos JSON para base de datos
  String toJson() {
    return json.encode(toMap());
  }

  factory Competition.fromJson(String jsonString) {
    return Competition.fromMap(json.decode(jsonString));
  }

  Competition copyWith({
    String? id,
    String? name,
    CompetitionType? type,
    CompetitionStatus? status,
    List<String>? participantTeamIds,
    DateTime? startDate,
    DateTime? endDate,
    double? prizePool,
    String? description,
    Map<String, dynamic>? rules,
  }) {
    return Competition(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      participantTeamIds: participantTeamIds ?? this.participantTeamIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prizePool: prizePool ?? this.prizePool,
      description: description ?? this.description,
      rules: rules ?? this.rules,
    );
  }

  int get participantCount => participantTeamIds.length;
  
  bool get isActive => status == CompetitionStatus.ongoing;
  
  bool get hasEnded => status == CompetitionStatus.completed;

  static CompetitionType _parseCompetitionType(String input) {
    final value = input.trim().toLowerCase();

    switch (value) {
      case 'league':
      case 'liga':
        return CompetitionType.league;
      case 'cup':
      case 'copa':
        return CompetitionType.cup;
      case 'tournament':
      case 'torneo':
        return CompetitionType.tournament;
      case 'event':
      case 'evento':
        return CompetitionType.event;
      default:
        return CompetitionType.league;
    }
  }
}