import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';

void main() {
  final excel = Excel.createExcel();

  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null) {
    excel.delete(defaultSheet);
  }

  const playersSheet = 'Jugadores';
  const teamsSheet = 'Equipos';
  const eventsSheet = 'Eventos';
  const fixtureSheet = 'Fixture';

  excel[playersSheet];
  excel[teamsSheet];
  excel[eventsSheet];
  excel[fixtureSheet];

  final teamNames = [
    'Real Madrid',
    'Manchester City',
    'Bayern Munich',
    'Inter Milan',
    'Liverpool',
    'PSG',
    'Barcelona',
    'Juventus',
    'Chelsea',
    'Atletico Madrid',
    'Borussia Dortmund',
    'Napoli',
  ];

  final owners = [
    'Florentino Perez',
    'Sheikh Mansour',
    'Herbert Hainer',
    'Steven Zhang',
    'Fenway Sports Group',
    'Nasser Al-Khelaifi',
    'Joan Laporta',
    'Andrea Agnelli',
    'Todd Boehly',
    'Enrique Cerezo',
    'Hans-Joachim Watzke',
    'Aurelio De Laurentiis',
  ];

  final stadiums = [
    'Santiago Bernabeu',
    'Etihad Stadium',
    'Allianz Arena',
    'San Siro',
    'Anfield',
    'Parc des Princes',
    'Camp Nou',
    'Allianz Stadium',
    'Stamford Bridge',
    'Metropolitano',
    'Signal Iduna Park',
    'Diego Armando Maradona',
  ];

  const positionsTemplate = [
    'POR',
    'POR',
    'POR',
    'DEC',
    'DEC',
    'DEC',
    'DEC',
    'LI',
    'LD',
    'MCD',
    'MCD',
    'MC',
    'MC',
    'MC',
    'MDI',
    'MDD',
    'MO',
    'EXI',
    'EXD',
    'SD',
    'DC',
    'DC',
    'MO',
  ];

  final nationalities = [
    'España',
    'Argentina',
    'Brasil',
    'Francia',
    'Inglaterra',
    'Portugal',
    'Alemania',
    'Italia',
    'Uruguay',
    'Colombia',
    'Croacia',
    'Paises Bajos',
  ];

  final playersHeaders = [
    'id',
    'name',
    'position',
    'price',
    'team_id',
    'overall',
    'club',
    'nationality',
    'age',
    'contractDuration',
    'contractStart',
    'contractEnd',
    'photo',
  ];

  final teamsHeaders = [
    'id',
    'name',
    'ownerName',
    'budget',
    'playerIds',
    'logoUrl',
    'formation',
    'homeStadium',
    'established',
    'posicion',
    'puntos',
    'pj',
    'g',
    'e',
    'p',
    'gf',
    'gc',
    'dg',
    'competitionStats',
  ];

  final eventsHeaders = [
    'id',
    'name',
    'type',
    'status',
    'participantTeamIds',
    'startDate',
    'endDate',
    'prizePool',
    'description',
    'hasStandings',
    'rules',
  ];

  final fixtureHeaders = [
    'id',
    'eventId',
    'matchday',
    'homeTeamId',
    'awayTeamId',
    'homeGoals',
    'awayGoals',
    'kickoffDate',
    'status',
    'venue',
    'notes',
  ];

  final playersRows = <List<String>>[];
  final teamsRows = <List<String>>[];

  var playerCounter = 1;

  for (var i = 0; i < teamNames.length; i++) {
    final teamId = 't${i + 1}';
    final teamName = teamNames[i];
    final playerIds = <String>[];

    for (var j = 0; j < positionsTemplate.length; j++) {
      final playerId = 'p$playerCounter';
      playerIds.add(playerId);

      final position = positionsTemplate[j];
      final overall = (78 + ((i + j) % 13)).toString();
      final age = (19 + ((i * 2 + j) % 15)).toString();
      final price = (4000000 + (i * 1200000) + (j * 850000)).toString();
      final nationality = nationalities[(i + j) % nationalities.length];
      final durationYears = 2 + ((i + j) % 4);
      final endYear = 2026 + durationYears;

      playersRows.add([
        playerId,
        'Jugador ${i + 1}-${j + 1}',
        position,
        price,
        teamId,
        overall,
        teamName,
        nationality,
        age,
        '$durationYears años',
        '2026-07-01',
        '$endYear-06-30',
        '',
      ]);

      playerCounter++;
    }

    final position = i + 1;
    const pj = 19;
    final wins = (13 - i).clamp(4, 13);
    final draws = 2 + (i % 4);
    final losses = pj - wins - draws;
    final points = wins * 3 + draws;
    final gf = 38 - i;
    final gc = 14 + i;
    final dg = gf - gc;

    final competitionStats = {
      'l1': {
        'position': position,
        'points': points,
        'matchesPlayed': pj,
        'wins': wins,
        'draws': draws,
        'losses': losses,
        'goalsFor': gf,
        'goalsAgainst': gc,
        'goalDifference': dg,
      },
    };

    teamsRows.add([
      teamId,
      teamName,
      owners[i],
      (220000000 + (teamNames.length - i) * 18000000).toString(),
      playerIds.join(','),
      'https://example.com/logo/$teamId.png',
      i % 2 == 0 ? '4-3-3' : '4-2-3-1',
      stadiums[i],
      (1880 + (i * 5)).toString(),
      position.toString(),
      points.toString(),
      pj.toString(),
      wins.toString(),
      draws.toString(),
      losses.toString(),
      gf.toString(),
      gc.toString(),
      dg.toString(),
      jsonEncode(competitionStats),
    ]);
  }

  final leagueTeamIds = List.generate(12, (i) => 't${i + 1}');
  final cup1TeamIds = List.generate(8, (i) => 't${i + 1}');
  final cup2TeamIds = ['t1', 't2', 't3', 't4', 't5', 't6'];

  final leagueTeams = leagueTeamIds.join(',');
  final cup1Teams = cup1TeamIds.join(',');
  final cup2Teams = cup2TeamIds.join(',');

  final eventsRows = [
    [
      'l1',
      'Liga Master Elite 2026',
      'league',
      'ongoing',
      leagueTeams,
      '2026-08-15',
      '2027-05-25',
      '150000000',
      'Liga principal en mitad de temporada.',
      'true',
      jsonEncode({'season': '2026/27', 'matchday': 19, 'totalMatchdays': 38}),
    ],
    [
      'c1',
      'Copa Nacional Master',
      'cup',
      'ongoing',
      cup1Teams,
      '2026-11-10',
      '2027-03-30',
      '45000000',
      'Copa eliminatoria de 8 equipos.',
      'false',
      jsonEncode({'format': 'knockout', 'legs': 2}),
    ],
    [
      'c2',
      'Supercopa Master',
      'cup',
      'upcoming',
      cup2Teams,
      '2027-06-10',
      '2027-07-02',
      '30000000',
      'Copa corta post-temporada.',
      'false',
      jsonEncode({'format': 'knockout', 'legs': 1}),
    ],
  ];

  final fixtureRows = <List<String>>[];
  var fixtureCounter = 1;

  void addFixtureRow({
    required String eventId,
    required int matchday,
    required String homeTeamId,
    required String awayTeamId,
    required String kickoffDate,
    required String status,
    String homeGoals = '',
    String awayGoals = '',
    String venue = '',
    String notes = '',
  }) {
    fixtureRows.add([
      'fx$fixtureCounter',
      eventId,
      matchday.toString(),
      homeTeamId,
      awayTeamId,
      homeGoals,
      awayGoals,
      kickoffDate,
      status,
      venue,
      notes,
    ]);
    fixtureCounter++;
  }

  void addRoundRobinFixtures({
    required String eventId,
    required List<String> teamIds,
    required int rounds,
    required DateTime baseDate,
  }) {
    if (teamIds.length.isOdd || teamIds.length < 2) return;

    final rotation = List<String>.from(teamIds);
    final half = rotation.length ~/ 2;

    for (var round = 0; round < rounds; round++) {
      for (var i = 0; i < half; i++) {
        var home = rotation[i];
        var away = rotation[rotation.length - 1 - i];

        if (round.isOdd) {
          final tmp = home;
          home = away;
          away = tmp;
        }

        final kickoff = baseDate.add(Duration(days: (round * 7) + i));
        addFixtureRow(
          eventId: eventId,
          matchday: round + 1,
          homeTeamId: home,
          awayTeamId: away,
          kickoffDate: kickoff.toIso8601String().split('T').first,
          status: round == 0 ? 'ongoing' : 'upcoming',
          notes: 'Jornada ${round + 1}',
        );
      }

      final fixed = rotation.first;
      final moving = rotation.sublist(1);
      final last = moving.removeLast();
      moving.insert(0, last);
      rotation
        ..clear()
        ..add(fixed)
        ..addAll(moving);
    }
  }

  addRoundRobinFixtures(
    eventId: 'l1',
    teamIds: leagueTeamIds,
    rounds: 3,
    baseDate: DateTime(2026, 8, 18),
  );

  for (var i = 0; i < cup1TeamIds.length; i += 2) {
    addFixtureRow(
      eventId: 'c1',
      matchday: 1,
      homeTeamId: cup1TeamIds[i],
      awayTeamId: cup1TeamIds[i + 1],
      kickoffDate: DateTime(2026, 11, 15 + (i ~/ 2)).toIso8601String().split('T').first,
      status: 'upcoming',
      notes: 'Cuartos de final',
    );
  }

  for (var i = 0; i < cup2TeamIds.length; i += 2) {
    addFixtureRow(
      eventId: 'c2',
      matchday: 1,
      homeTeamId: cup2TeamIds[i],
      awayTeamId: cup2TeamIds[i + 1],
      kickoffDate: DateTime(2027, 6, 12 + (i ~/ 2)).toIso8601String().split('T').first,
      status: 'upcoming',
      notes: 'Ronda inicial',
    );
  }

  void writeSheet(String sheetName, List<String> headers, List<List<String>> rows) {
    final sheet = excel[sheetName];

    for (var c = 0; c < headers.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
          .value = TextCellValue(headers[c]);
    }

    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      for (var c = 0; c < row.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
            .value = TextCellValue(row[c]);
      }
    }
  }

  writeSheet(playersSheet, playersHeaders, playersRows);
  writeSheet(teamsSheet, teamsHeaders, teamsRows);
  writeSheet(eventsSheet, eventsHeaders, eventsRows);
  writeSheet(fixtureSheet, fixtureHeaders, fixtureRows);

  final output = File('datos_prueba/master_league_ejemplo.xlsx');
  output.parent.createSync(recursive: true);

  final bytes = excel.save();
  if (bytes == null) {
    stderr.writeln('No se pudo generar el archivo Excel');
    exitCode = 1;
    return;
  }

  output.writeAsBytesSync(bytes, flush: true);

  stdout.writeln('Excel generado: ${output.path}');
  stdout.writeln('Equipos: ${teamsRows.length}');
  stdout.writeln('Jugadores: ${playersRows.length}');
  stdout.writeln('Eventos: ${eventsRows.length}');
  stdout.writeln('Partidos fixture: ${fixtureRows.length}');
}
