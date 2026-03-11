enum CompetitionType { league, cup, tournament }

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
    return Competition(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: CompetitionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => CompetitionType.league,
      ),
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
}