import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/file_import_service_simple.dart';
import '../services/database_service.dart';

class TeamProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Team> _teams = [];
  bool _isLoading = false;
  String? _error;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addTeam(Team team) {
    _teams.add(team);
    notifyListeners();
  }

  void updateTeam(Team updatedTeam) {
    final index = _teams.indexWhere((team) => team.id == updatedTeam.id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      notifyListeners();
    }
  }

  void removeTeam(String teamId) {
    _teams.removeWhere((team) => team.id == teamId);
    notifyListeners();
  }

  Team? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  void addPlayerToTeam(String teamId, String playerId) {
    final team = getTeamById(teamId);
    if (team != null) {
      if (!team.playerIds.contains(playerId)) {
        final updatedPlayerIds = List<String>.from(team.playerIds)..add(playerId);
        final updatedTeam = team.copyWith(playerIds: updatedPlayerIds);
        updateTeam(updatedTeam);
      }
    }
  }

  void removePlayerFromTeam(String teamId, String playerId) {
    final team = getTeamById(teamId);
    if (team != null) {
      final updatedPlayerIds = List<String>.from(team.playerIds)..remove(playerId);
      final updatedTeam = team.copyWith(playerIds: updatedPlayerIds);
      updateTeam(updatedTeam);
    }
  }

  void updateTeamBudget(String teamId, double newBudget) {
    final team = getTeamById(teamId);
    if (team != null) {
      final updatedTeam = team.copyWith(budget: newBudget);
      updateTeam(updatedTeam);
    }
  }

  double getTotalTeamValue(String teamId, List<double> playerPrices) {
    final team = getTeamById(teamId);
    if (team == null) return 0.0;

    double totalValue = 0.0;
    for (int i = 0; i < team.playerIds.length && i < playerPrices.length; i++) {
      totalValue += playerPrices[i];
    }
    return totalValue;
  }

  List<Team> getTeamsSortedByBudget({bool ascending = false}) {
    final sortedTeams = List<Team>.from(_teams);
    sortedTeams.sort((a, b) => ascending 
        ? a.budget.compareTo(b.budget) 
        : b.budget.compareTo(a.budget));
    return sortedTeams;
  }

  List<Team> getTeamsSortedByPlayerCount({bool ascending = false}) {
    final sortedTeams = List<Team>.from(_teams);
    sortedTeams.sort((a, b) => ascending 
        ? a.playerCount.compareTo(b.playerCount) 
        : b.playerCount.compareTo(a.playerCount));
    return sortedTeams;
  }

  void clearTeams() {
    _teams.clear();
    notifyListeners();
  }

  Future<void> loadDataFromJsonUrl() async {
    // Google Sheets URL (se exporta automaticamente a Excel)
    const String excelUrl = 'https://docs.google.com/spreadsheets/d/1aLosZuNxbrDmMC0Jialz0ahInZDZsmlZ/edit?usp=drive_link&rtpof=true&sd=true';
    
    try {
      setLoading(true);
      setError(null);
      
      // Clear existing teams before loading new data
      _teams.clear();
      notifyListeners();
      
      print('🏟️ Cargando equipos...');
      
      try {
        Map<String, dynamic> data = await FileImportService.downloadAndLoadExcelData(excelUrl);
        
        // Load teams
        List<Team> importedTeams = data['teams'] ?? [];
        _teams.addAll(importedTeams);
        
        // Guardar en cache local
        await saveTeamsToCache(_teams);
        
        print('✅ Equipos cargados: ${importedTeams.length}');
        
        if (_teams.isEmpty) {
          setError('No se encontraron equipos en los datos');
        }
      } catch (downloadError) {
        print('❌ Error cargando equipos desde Excel: $downloadError');
        
        // Intentar cargar desde cache local como respaldo
        print('🔄 Intentando cargar desde cache local...');
        await loadTeamsFromCache();
        
        if (_teams.isEmpty) {
          setError('Error cargando equipos y no hay datos en cache: $downloadError');
        } else {
          setError('Cargado desde cache local (sin conexión)');
          print('✅ Equipos cargados desde cache: ${_teams.length}');
        }
      }
      
    } catch (e) {
      print('❌ Error general cargando equipos: $e');
      setError('Error cargando equipos: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Carga equipos desde el cache local
  Future<void> loadTeamsFromCache() async {
    try {
      setLoading(true);
      setError(null);
      
      final cachedTeams = await _db.getCachedTeams();
      _teams = cachedTeams;
      
      print('💾 Equipos cargados desde cache: ${_teams.length}');
      
      if (_teams.isEmpty) {
        setError('No hay equipos en el cache local');
      }
    } catch (e) {
      setError('Error cargando cache: $e');
      print('❌ Error cargando cache: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Guarda equipos en el cache local
  Future<void> saveTeamsToCache(List<Team> teams) async {
    try {
      await _db.cacheTeams(teams);
      print('💾 ${teams.length} equipos guardados en cache');
    } catch (e) {
      print('❌ Error guardando equipos en cache: $e');
    }
  }

  /// Verifica si hay datos en cache
  Future<bool> hasCachedData() async {
    try {
      final cachedTeams = await _db.getCachedTeams();
      return cachedTeams.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la fecha de la última actualización del cache
  Future<DateTime?> getLastCacheUpdate() async {
    try {
      return await _db.getLastCacheUpdate();
    } catch (e) {
      return null;
    }
  }

  /// Limpia el cache local
  Future<void> clearCache() async {
    try {
      await _db.clearAllCache();
      print('🗑️ Cache de equipos limpiado');
    } catch (e) {
      print('❌ Error limpiando cache: $e');
    }
  }
}