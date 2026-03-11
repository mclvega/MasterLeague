import 'dart:convert';

class Team {
  final String id;
  final String name;
  final String ownerName;
  final double budget;
  final List<String> playerIds;
  final String? logoUrl;
  final String? formation;
  final String? homeStadium;
  final String? established;
  final TeamStats? stats;
  final List<String>? trophies;
  final List<dynamic>? transferHistory;
  final double? teamValue;
  final TeamFinances? finances;
  final Map<String, dynamic>? competitionStats;

  Team({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.budget,
    this.playerIds = const [],
    this.logoUrl,
    this.formation,
    this.homeStadium,
    this.established,
    this.stats,
    this.trophies,
    this.transferHistory,
    this.teamValue,
    this.finances,
    this.competitionStats,
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      playerIds: List<String>.from(map['playerIds'] ?? []),
      logoUrl: map['logoUrl']?.toString(),
      formation: map['formation']?.toString(),
      homeStadium: map['homeStadium']?.toString(),
      established: map['established']?.toString(),
      stats: map['stats'] != null ? TeamStats.fromMap(map['stats']) : null,
      trophies: map['trophies'] != null ? List<String>.from(map['trophies']) : null,
      transferHistory: map['transferHistory'] != null ? List<dynamic>.from(map['transferHistory']) : null,
      teamValue: (map['teamValue'] as num?)?.toDouble(),
      finances: map['finances'] != null ? TeamFinances.fromMap(map['finances']) : null,
      competitionStats: map['competitionStats'] != null ? Map<String, dynamic>.from(map['competitionStats']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerName': ownerName,
      'budget': budget,
      'playerIds': playerIds,
      'logoUrl': logoUrl,
      'formation': formation,
      'homeStadium': homeStadium,
      'established': established,
      'stats': stats?.toMap(),
      'trophies': trophies,
      'transferHistory': transferHistory,
      'teamValue': teamValue,
      'finances': finances?.toMap(),
      'competitionStats': competitionStats,
    };
  }

  // Métodos JSON para base de datos
  String toJson() {
    return json.encode(toMap());
  }

  factory Team.fromJson(String jsonString) {
    return Team.fromMap(json.decode(jsonString));
  }

  Team copyWith({
    String? id,
    String? name,
    String? ownerName,
    double? budget,
    List<String>? playerIds,
    String? logoUrl,
    String? formation,
    String? homeStadium,
    String? established,
    TeamStats? stats,
    List<String>? trophies,
    List<dynamic>? transferHistory,
    double? teamValue,
    TeamFinances? finances,
    Map<String, dynamic>? competitionStats,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      budget: budget ?? this.budget,
      playerIds: playerIds ?? this.playerIds,
      logoUrl: logoUrl ?? this.logoUrl,
      formation: formation ?? this.formation,
      homeStadium: homeStadium ?? this.homeStadium,
      established: established ?? this.established,
      stats: stats ?? this.stats,
      trophies: trophies ?? this.trophies,
      transferHistory: transferHistory ?? this.transferHistory,
      teamValue: teamValue ?? this.teamValue,
      finances: finances ?? this.finances,
      competitionStats: competitionStats ?? this.competitionStats,
    );
  }

  int get playerCount => playerIds.length;
}

class TeamStats {
  final int points;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int? position;
  final String? form;

  TeamStats({
    required this.points,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    this.position,
    this.form,
  });

  factory TeamStats.fromMap(Map<String, dynamic> map) {
    return TeamStats(
      points: map['points'] ?? 0,
      matchesPlayed: map['matchesPlayed'] ?? 0,
      wins: map['wins'] ?? 0,
      draws: map['draws'] ?? 0,
      losses: map['losses'] ?? 0,
      goalsFor: map['goalsFor'] ?? 0,
      goalsAgainst: map['goalsAgainst'] ?? 0,
      goalDifference: map['goalDifference'] ?? 0,
      position: map['position'],
      form: map['form']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'points': points,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'goalDifference': goalDifference,
      'position': position,
      'form': form,
    };
  }
}

class TeamFinances {
  final double budgetRemaining;
  final double squadValue;
  final double totalSalaries;
  final double transferBudget;
  final double sponsorshipIncome;

  TeamFinances({
    required this.budgetRemaining,
    required this.squadValue,
    required this.totalSalaries,
    required this.transferBudget,
    required this.sponsorshipIncome,
  });

  factory TeamFinances.fromMap(Map<String, dynamic> map) {
    return TeamFinances(
      budgetRemaining: (map['budgetRemaining'] as num?)?.toDouble() ?? 0.0,
      squadValue: (map['squadValue'] as num?)?.toDouble() ?? 0.0,
      totalSalaries: (map['totalSalaries'] as num?)?.toDouble() ?? 0.0,
      transferBudget: (map['transferBudget'] as num?)?.toDouble() ?? 0.0,
      sponsorshipIncome: (map['sponsorshipIncome'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'budgetRemaining': budgetRemaining,
      'squadValue': squadValue,
      'totalSalaries': totalSalaries,
      'transferBudget': transferBudget,
      'sponsorshipIncome': sponsorshipIncome,
    };
  }
}