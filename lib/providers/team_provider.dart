import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/file_import_service_simple.dart';

class TeamProvider with ChangeNotifier {
  final List<Team> _teams = [];
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
    // Google Drive direct download URL
    const String jsonUrl = 'https://drive.google.com/uc?export=download&id=1nsXpZs6FYQ0FfbGwA6CuJCSFWQkgl4AN';
    
    try {
      setLoading(true);
      setError(null);
      
      // Clear existing teams before loading new data
      _teams.clear();
      notifyListeners();
      
      print('🏟️ Cargando equipos...');
      
      try {
        Map<String, dynamic> data = await FileImportService.downloadAndLoadJsonData(jsonUrl);
        
        // Load teams
        List<Team> importedTeams = data['teams'] ?? [];
        _teams.addAll(importedTeams);
        
        print('✅ Equipos cargados: ${importedTeams.length}');
        
        if (_teams.isEmpty) {
          setError('No se encontraron equipos en los datos');
        }
      } catch (downloadError) {
        print('❌ Error cargando equipos: $downloadError');
        setError('Error cargando equipos: $downloadError');
      }
      
    } catch (e) {
      print('❌ Error general cargando equipos: $e');
      setError('Error cargando equipos: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }
}