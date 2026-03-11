import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/player.dart';
import '../models/team.dart';
import '../models/competition.dart';

class FileImportService {
  static Future<Map<String, dynamic>> downloadAndLoadJsonData(String url) async {
    try {
      print('🔄 Descargando desde: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Android 13; Master League App)',
          'Accept': 'application/json, text/plain, */*',
        },
      );
      
      print('📡 Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Descarga exitosa: ${response.body.length} caracteres');
        
        // Guardar en archivo local
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_league_data.json');
        await file.writeAsString(response.body);
        print('💾 Guardado en: ${file.path}');
        
        // Parsear JSON
        final jsonData = json.decode(response.body);
        
        List<Player> players = [];
        List<Team> teams = [];
        List<Competition> competitions = [];
        
        if (jsonData['players'] != null) {
          players = (jsonData['players'] as List)
              .map((playerJson) => Player.fromMap(playerJson))
              .toList();
          print('⚽ Jugadores parseados: ${players.length}');
        }
        
        if (jsonData['teams'] != null) {
          teams = (jsonData['teams'] as List)
              .map((teamJson) => Team.fromMap(teamJson))
              .toList();
          print('🏟️ Equipos parseados: ${teams.length}');
        }
        
        if (jsonData['competitions'] != null) {
          competitions = (jsonData['competitions'] as List)
              .map((compJson) => Competition.fromMap(compJson))
              .toList();
          print('🏆 Competiciones parseadas: ${competitions.length}');
        }
        
        return {
          'players': players,
          'teams': teams,
          'competitions': competitions,
        };
      } else {
        throw Exception('❌ Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error de descarga: $e');
      
      // Intentar cargar archivo local como respaldo
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_league_data.json');
        
        if (await file.exists()) {
          print('📂 Cargando desde archivo local...');
          final content = await file.readAsString();
          final jsonData = json.decode(content);
          
          List<Player> players = [];
          List<Team> teams = [];
          List<Competition> competitions = [];
          
          if (jsonData['players'] != null) {
            players = (jsonData['players'] as List)
                .map((playerJson) => Player.fromMap(playerJson))
                .toList();
          }
          
          if (jsonData['teams'] != null) {
            teams = (jsonData['teams'] as List)
                .map((teamJson) => Team.fromMap(teamJson))
                .toList();
          }
          
          if (jsonData['competitions'] != null) {
            competitions = (jsonData['competitions'] as List)
                .map((compJson) => Competition.fromMap(compJson))
                .toList();
          }
          
          return {
            'players': players,
            'teams': teams,
            'competitions': competitions,
          };
        }
      } catch (localError) {
        print('❌ Error con archivo local: $localError');
      }
      
      throw Exception('Error de descarga y sin archivo local disponible: $e');
    }
  }
}