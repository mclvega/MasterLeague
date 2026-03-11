import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/file_import_service_simple.dart';

class PlayerProvider with ChangeNotifier {
  final List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _positionFilter;
  String? _teamFilter;

  List<Player> get players => _players;
  List<Player> get filteredPlayers => _filteredPlayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Player> get freeAgents => _players.where((player) => player.isFreeAgent).toList();

  List<Player> getPlayersByTeam(String teamId) {
    return _players.where((player) => player.teamId == teamId).toList();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addPlayer(Player player) {
    _players.add(player);
    _filteredPlayers = List.from(_players);
    notifyListeners();
  }

  void updatePlayer(Player updatedPlayer) {
    final index = _players.indexWhere((player) => player.id == updatedPlayer.id);
    if (index != -1) {
      _players[index] = updatedPlayer;
      _filteredPlayers = List.from(_players);
      notifyListeners();
    }
  }

  void removePlayer(String playerId) {
    _players.removeWhere((player) => player.id == playerId);
    _filteredPlayers = List.from(_players);
    notifyListeners();
  }

  void assignPlayerToTeam(String playerId, String teamId) {
    final player = _players.firstWhere((p) => p.id == playerId);
    final updatedPlayer = player.copyWith(teamId: teamId);
    updatePlayer(updatedPlayer);
  }

  void releasePlayerFromTeam(String playerId) {
    final player = _players.firstWhere((p) => p.id == playerId);
    final updatedPlayer = player.copyWith(teamId: null);
    updatePlayer(updatedPlayer);
  }

  void searchPlayers(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByPosition(String? position) {
    _positionFilter = (position == null || position.isEmpty) ? null : position.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByTeam(String? teamId) {
    _teamFilter = (teamId == null || teamId.isEmpty) ? null : teamId;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPlayers = _players.where((player) {
      final matchesSearch = _searchQuery.isEmpty ||
          player.name.toLowerCase().contains(_searchQuery) ||
          player.position.toLowerCase().contains(_searchQuery) ||
          player.club.toLowerCase().contains(_searchQuery) ||
          player.nationality.toLowerCase().contains(_searchQuery);

      final matchesPosition = _positionFilter == null ||
          player.position.toLowerCase() == _positionFilter;

      final matchesTeam = _teamFilter == null ||
          ((player.teamId ?? '') == _teamFilter);

      return matchesSearch && matchesPosition && matchesTeam;
    }).toList();
  }

  void sortPlayers(String sortBy, {bool ascending = true}) {
    switch (sortBy) {
      case 'name':
        _filteredPlayers.sort((a, b) => ascending 
            ? a.name.compareTo(b.name) 
            : b.name.compareTo(a.name));
        break;
      case 'price':
        _filteredPlayers.sort((a, b) => ascending 
            ? a.price.compareTo(b.price) 
            : b.price.compareTo(a.price));
        break;
      case 'overall':
        _filteredPlayers.sort((a, b) => ascending 
            ? a.overall.compareTo(b.overall) 
            : b.overall.compareTo(a.overall));
        break;
      case 'age':
        _filteredPlayers.sort((a, b) => ascending 
            ? a.age.compareTo(b.age) 
            : b.age.compareTo(a.age));
        break;
    }
    notifyListeners();
  }

  Future<void> importPlayersFromFile(String filePath, {bool isUrl = false}) async {
    // Método simplificado - usar loadDataFromJsonUrl para toda importación
    await loadDataFromJsonUrl();
  }

  Future<void> loadDataFromJsonUrl() async {
    // Google Sheets URL (se exporta automaticamente a Excel)
    const String excelUrl = 'https://docs.google.com/spreadsheets/d/1aLosZuNxbrDmMC0Jialz0ahInZDZsmlZ/edit?usp=drive_link&rtpof=true&sd=true';
    
    try {
      setLoading(true);
      setError(null);
      
      // Clear existing players before loading new data
      _players.clear();
      _filteredPlayers.clear();
      notifyListeners();
      
      print('Iniciando carga de datos...');
      
      try {
        Map<String, dynamic> data = await FileImportService.downloadAndLoadExcelData(excelUrl);
        
        // Load players
        List<Player> importedPlayers = data['players'] ?? [];
        _players.addAll(importedPlayers);
        _searchQuery = '';
        _positionFilter = null;
        _teamFilter = null;
        _filteredPlayers = List.from(_players);
        
        print('✅ Carga exitosa: ${importedPlayers.length} jugadores');
        
        if (_players.isEmpty) {
          setError('No se encontraron jugadores en los datos');
        }
      } catch (downloadError) {
        print('❌ Error de descarga: $downloadError');
        
        // Fallback: cargar datos mínimos locales
        print('Cargando datos de emergencia...');
        _loadEmergencyData();
        
        setError('Descarga falló, usando datos locales. Error: $downloadError');
      }
      
    } catch (e) {
      print('❌ Error general: $e');
      setError('Error cargando datos: $e');
      
      // Load emergency local data
      _loadEmergencyData();
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }
  
  void _loadEmergencyData() {
    // Datos mínimos de emergencia
    final emergencyPlayers = [
      Player(
        id: '1',
        name: 'Kylian Mbappé',
        position: 'DEL',
        price: 85000000,
        overall: 92,
        club: 'Paris Saint-Germain',
        nationality: 'Francia',
        age: 24,
      ),
      Player(
        id: '2',
        name: 'Lionel Messi',
        position: 'DEL',
        price: 70000000,
        overall: 93,
        club: 'Inter Miami',
        nationality: 'Argentina',
        age: 36,
      ),
      Player(
        id: '3',
        name: 'Erling Haaland',
        position: 'DEL',
        price: 80000000,
        overall: 91,
        club: 'Manchester City',
        nationality: 'Noruega',
        age: 23,
      ),
    ];
    
    _players.clear();
    _players.addAll(emergencyPlayers);
    _searchQuery = '';
    _positionFilter = null;
    _teamFilter = null;
    _filteredPlayers = List.from(_players);
    
    print('Datos de emergencia cargados: ${_players.length} jugadores');
  }

  void clearPlayers() {
    _players.clear();
    _filteredPlayers.clear();
    notifyListeners();
  }
}