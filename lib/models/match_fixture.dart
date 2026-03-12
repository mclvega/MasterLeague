class MatchFixture {
  final String id;
  final String eventId;
  final int matchday;
  final String homeTeamId;
  final String awayTeamId;
  final int? homeGoals;
  final int? awayGoals;
  final DateTime kickoffDate;
  final String status;
  final String? venue;
  final String? notes;

  const MatchFixture({
    required this.id,
    required this.eventId,
    required this.matchday,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.kickoffDate,
    required this.status,
    this.homeGoals,
    this.awayGoals,
    this.venue,
    this.notes,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null;

  factory MatchFixture.fromMap(Map<String, dynamic> map) {
    return MatchFixture(
      id: (map['id'] ?? '').toString(),
      eventId: (map['eventId'] ?? map['event_id'] ?? '').toString(),
      matchday: _toInt(map['matchday']) ?? 1,
      homeTeamId: (map['homeTeamId'] ?? map['home_team_id'] ?? '').toString(),
      awayTeamId: (map['awayTeamId'] ?? map['away_team_id'] ?? '').toString(),
      homeGoals: _toInt(map['homeGoals'] ?? map['home_goals']),
      awayGoals: _toInt(map['awayGoals'] ?? map['away_goals']),
      kickoffDate: DateTime.tryParse((map['kickoffDate'] ?? map['kickoff_date'] ?? '').toString()) ?? DateTime.now(),
      status: (map['status'] ?? '').toString(),
      venue: _toNullableString(map['venue']),
      notes: _toNullableString(map['notes']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
