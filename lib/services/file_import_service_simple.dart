import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/player.dart';
import '../models/team.dart';
import '../models/competition.dart';

class FileImportService {
  static Future<Map<String, dynamic>> downloadAndLoadExcelData(String url) async {
    try {
      final excelUrl = _toGoogleSheetsXlsxExportUrl(url);
      print('🔄 Descargando Excel desde: $excelUrl');
      
      final response = await http.get(
        Uri.parse(excelUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Android 13; Master League App)',
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/octet-stream, */*',
        },
      );
      
      print('📡 Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Descarga Excel exitosa: ${response.bodyBytes.length} bytes');
        
        // Guardar en archivo local
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_league_data.xlsx');
        await file.writeAsBytes(response.bodyBytes);
        print('💾 Guardado en: ${file.path}');

        final parsed = _parseExcelBytes(response.bodyBytes);
        
        return {
          'players': parsed['players']!,
          'teams': parsed['teams']!,
          'competitions': parsed['competitions']!,
        };
      } else {
        throw Exception('❌ Error HTTP descargando Excel: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error de descarga Excel: $e');
      
      // Intentar cargar archivo local como respaldo
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_league_data.xlsx');
        
        if (await file.exists()) {
          print('📂 Cargando Excel desde archivo local...');
          final bytes = await file.readAsBytes();
          final parsed = _parseExcelBytes(bytes);
          
          return {
            'players': parsed['players']!,
            'teams': parsed['teams']!,
            'competitions': parsed['competitions']!,
          };
        }
      } catch (localError) {
        print('❌ Error con Excel local: $localError');
      }
      
      throw Exception('Error de descarga Excel y sin archivo local disponible: $e');
    }
  }

  // Compatibilidad con llamadas existentes
  static Future<Map<String, dynamic>> downloadAndLoadJsonData(String url) {
    return downloadAndLoadExcelData(url);
  }

  static String _toGoogleSheetsXlsxExportUrl(String url) {
    final idRegex = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final match = idRegex.firstMatch(url);
    if (match != null) {
      final id = match.group(1)!;
      return 'https://docs.google.com/spreadsheets/d/$id/export?format=xlsx';
    }
    return url;
  }

  static Map<String, List<dynamic>> _parseExcelBytes(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      throw Exception('El archivo Excel no contiene hojas');
    }

    final sheets = excel.tables.values.toList();
    final playersRows = sheets.isNotEmpty ? sheets[0].rows : <List<Data?>>[];
    final teamsRows = sheets.length > 1 ? sheets[1].rows : <List<Data?>>[];
    final competitionsRows = sheets.length > 2 ? sheets[2].rows : <List<Data?>>[];

    final players = _parsePlayers(playersRows);
    final teams = _parseTeams(teamsRows);
    final competitions = _parseCompetitions(competitionsRows);

    print('⚽ Jugadores parseados (hoja 1): ${players.length}');
    print('🏟️ Equipos parseados (hoja 2): ${teams.length}');
    print('🏆 Competiciones parseadas (hoja 3): ${competitions.length}');

    return {
      'players': players,
      'teams': teams,
      'competitions': competitions,
    };
  }

  static List<Player> _parsePlayers(List<List<Data?>> rows) {
    if (rows.isEmpty) return [];
    final headers = _headerMap(rows.first);
    final players = <Player>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final name = _cell(row, headers, ['name', 'nombre', 'jugador'], fallbackIndex: 1);
      if (name.isEmpty) continue;

      players.add(
        Player(
          id: _cell(row, headers, ['id', 'playerid', 'player_id'], fallbackIndex: 0).isEmpty
              ? 'p_$i'
              : _cell(row, headers, ['id', 'playerid', 'player_id'], fallbackIndex: 0),
          name: name,
          position: _cell(row, headers, ['position', 'posicion', 'pos'], fallbackIndex: 2),
          price: _toDouble(_cell(row, headers, ['price', 'precio', 'valor'], fallbackIndex: 3)),
          teamId: _nullable(_cell(row, headers, ['teamid', 'team_id', 'equipoid', 'equipo_id'], fallbackIndex: 4)),
          overall: _toInt(_cell(row, headers, ['overall', 'media', 'rating'], fallbackIndex: 5)),
          club: _cell(row, headers, ['club', 'equipo', 'team'], fallbackIndex: 6),
          nationality: _cell(row, headers, ['nationality', 'nacionalidad', 'pais'], fallbackIndex: 7),
          age: _toInt(_cell(row, headers, ['age', 'edad'], fallbackIndex: 8)),
        ),
      );
    }
    return players;
  }

  static List<Team> _parseTeams(List<List<Data?>> rows) {
    if (rows.isEmpty) return [];
    final headers = _headerMap(rows.first);
    final teams = <Team>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final name = _cell(row, headers, ['name', 'nombre', 'equipo'], fallbackIndex: 1);
      if (name.isEmpty) continue;

      final rawPlayerIds = _cell(row, headers, ['playerids', 'player_ids', 'jugadores', 'jugadorids'], fallbackIndex: 4);
      final playerIds = rawPlayerIds
          .split(RegExp(r'[,;|]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      teams.add(
        Team(
          id: _cell(row, headers, ['id', 'teamid', 'team_id'], fallbackIndex: 0).isEmpty
              ? 't_$i'
              : _cell(row, headers, ['id', 'teamid', 'team_id'], fallbackIndex: 0),
          name: name,
          ownerName: _cell(row, headers, ['ownername', 'manager', 'propietario', 'dt'], fallbackIndex: 2),
          budget: _toDouble(_cell(row, headers, ['budget', 'presupuesto'], fallbackIndex: 3)),
          playerIds: playerIds,
          logoUrl: _nullable(_cell(row, headers, ['logourl', 'logo', 'escudo'], fallbackIndex: 5)),
          formation: _nullable(_cell(row, headers, ['formation', 'formacion'], fallbackIndex: 6)),
          homeStadium: _nullable(_cell(row, headers, ['homestadium', 'estadio'], fallbackIndex: 7)),
          established: _nullable(_cell(row, headers, ['established', 'fundacion', 'fundado'], fallbackIndex: 8)),
        ),
      );
    }
    return teams;
  }

  static List<Competition> _parseCompetitions(List<List<Data?>> rows) {
    if (rows.isEmpty) return [];
    final headers = _headerMap(rows.first);
    final competitions = <Competition>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final name = _cell(row, headers, ['name', 'nombre', 'campeonato', 'competicion'], fallbackIndex: 1);
      if (name.isEmpty) continue;

      final rawTeamIds = _cell(row, headers, ['participantteamids', 'teams', 'equipos', 'participantes'], fallbackIndex: 4);
      final participantTeamIds = rawTeamIds
          .split(RegExp(r'[,;|]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final startDateText = _cell(row, headers, ['startdate', 'inicio', 'fecha_inicio'], fallbackIndex: 5);
      final endDateText = _cell(row, headers, ['enddate', 'fin', 'fecha_fin'], fallbackIndex: 6);

      competitions.add(
        Competition(
          id: _cell(row, headers, ['id', 'competitionid', 'competition_id'], fallbackIndex: 0).isEmpty
              ? 'c_$i'
              : _cell(row, headers, ['id', 'competitionid', 'competition_id'], fallbackIndex: 0),
          name: name,
          type: _parseCompetitionType(_cell(row, headers, ['type', 'tipo'], fallbackIndex: 2)),
          status: _parseCompetitionStatus(_cell(row, headers, ['status', 'estado'], fallbackIndex: 3)),
          participantTeamIds: participantTeamIds,
          startDate: _toDate(startDateText),
          endDate: endDateText.isEmpty ? null : _toDate(endDateText),
          prizePool: _toDouble(_cell(row, headers, ['prizepool', 'premio', 'bolsa'], fallbackIndex: 7)),
          description: _nullable(_cell(row, headers, ['description', 'descripcion'], fallbackIndex: 8)),
        ),
      );
    }
    return competitions;
  }

  static Map<String, int> _headerMap(List<Data?> headerRow) {
    final map = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      final key = (headerRow[i]?.value?.toString() ?? '').trim().toLowerCase().replaceAll(' ', '');
      if (key.isNotEmpty) {
        map[key] = i;
      }
    }
    return map;
  }

  static String _cell(List<Data?> row, Map<String, int> headers, List<String> keys, {required int fallbackIndex}) {
    for (final rawKey in keys) {
      final key = rawKey.toLowerCase().replaceAll(' ', '');
      if (headers.containsKey(key)) {
        final idx = headers[key]!;
        if (idx >= 0 && idx < row.length) {
          return (row[idx]?.value?.toString() ?? '').trim();
        }
      }
    }

    if (fallbackIndex >= 0 && fallbackIndex < row.length) {
      return (row[fallbackIndex]?.value?.toString() ?? '').trim();
    }
    return '';
  }

  static String? _nullable(String value) {
    return value.isEmpty ? null : value;
  }

  static double _toDouble(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static int _toInt(String input) {
    return _toDouble(input).round();
  }

  static DateTime _toDate(String input) {
    final parsed = DateTime.tryParse(input);
    return parsed ?? DateTime.now();
  }

  static CompetitionType _parseCompetitionType(String input) {
    final value = input.toLowerCase();
    if (value.contains('cup') || value.contains('copa')) return CompetitionType.cup;
    if (value.contains('tournament') || value.contains('torneo')) return CompetitionType.tournament;
    return CompetitionType.league;
  }

  static CompetitionStatus _parseCompetitionStatus(String input) {
    final value = input.toLowerCase();
    if (value.contains('ongoing') || value.contains('en curso') || value.contains('activo')) {
      return CompetitionStatus.ongoing;
    }
    if (value.contains('completed') || value.contains('finalizado') || value.contains('terminado')) {
      return CompetitionStatus.completed;
    }
    return CompetitionStatus.upcoming;
  }
}