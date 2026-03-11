import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/player.dart';
import '../models/team.dart';
import '../models/competition.dart';

class FileImportService {
  // Method to download JSON from URL and save locally, then read it
  static Future<Map<String, dynamic>> downloadAndLoadJsonData(String url) async {
    try {
      print('Iniciando descarga desde: $url');
      
      // Download the JSON file from the URL with proper headers
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Android 13; Master League App)',
          'Accept': 'application/json, text/plain, */*',
        },
      );
      
      print('Código de respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Descarga exitosa, tamaño: ${response.body.length} caracteres');
        
        // Get the app documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_league_data.json');
        
        // Save the downloaded content to local file
        await file.writeAsString(response.body);
        print('Archivo JSON guardado localmente en: ${file.path}');
        
        // Validate the JSON content
        late Map<String, dynamic> jsonData;
        try {
          jsonData = json.decode(response.body);
          print('JSON parseado correctamente');
        } catch (e) {
          print('Error al parsear JSON: $e');
          throw Exception('La respuesta no es un JSON válido: $e');
        }
        
        List<Player> players = [];
        List<Team> teams = [];
        List<Competition> competitions = [];
        
        // Parse players
        if (jsonData['players'] != null) {
          try {
            players = (jsonData['players'] as List)
                .map((playerJson) => Player.fromMap(playerJson))
                .toList();
            print('Jugadores parseados: ${players.length}');
          } catch (e) {
            print('Error al parsear jugadores: $e');
          }
        }
        
        // Parse teams
        if (jsonData['teams'] != null) {
          try {
            teams = (jsonData['teams'] as List)
                .map((teamJson) => Team.fromMap(teamJson))
                .toList();
            print('Equipos parseados: ${teams.length}');
          } catch (e) {
            print('Error al parsear equipos: $e');
          }
        }
        
        // Parse competitions
        if (jsonData['competitions'] != null) {
          try {
            competitions = (jsonData['competitions'] as List)
                .map((compJson) => Competition.fromMap(compJson))
                .toList();
            print('Competiciones parseadas: ${competitions.length}');
          } catch (e) {
            print('Error al parsear competiciones: $e');
          }
        }
        
        return {
          'players': players,
          'teams': teams,
          'competitions': competitions,
        };
      } else {
        print('Error HTTP ${response.statusCode}');
        throw Exception('Error al descargar: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción durante descarga: $e');
      
      // If download fails, try to load from local file as fallback
      try {
        print('Intentando cargar desde archivo local...');
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/master_league_data.json');
        
        if (await file.exists()) {
          print('Archivo local encontrado');
          final content = await file.readAsString();
          final Map<String, dynamic> jsonData = json.decode(content);
          
          List<Player> players = [];
          if (jsonData['players'] != null) {
            players = (jsonData['players'] as List)
                .map((playerJson) => Player.fromMap(playerJson))
                .toList();
          }
          
          return {
            'players': players,
            'teams': <Team>[],
            'competitions': <Competition>[],
          };
        }
      } catch (localError) {
        print('Error con archivo local: $localError');
      }
      throw Exception('Error de descarga y sin archivo local: $e');
    }
  }
}