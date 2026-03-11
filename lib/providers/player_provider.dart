import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/file_import_service_simple.dart';

class PlayerProvider with ChangeNotifier {
  final List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  bool _isLoading = false;
  String? _error;

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
    if (query.isEmpty) {
      _filteredPlayers = List.from(_players);
    } else {
      _filteredPlayers = _players
          .where((player) =>
              player.name.toLowerCase().contains(query.toLowerCase()) ||
              player.position.toLowerCase().contains(query.toLowerCase()) ||
              player.club.toLowerCase().contains(query.toLowerCase()) ||
              player.nationality.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByPosition(String? position) {
    if (position == null || position.isEmpty) {
      _filteredPlayers = List.from(_players);
    } else {
      _filteredPlayers = _players
          .where((player) => player.position.toLowerCase() == position.toLowerCase())
          .toList();
    }
    notifyListeners();
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
    // Google Drive direct download URL
    const String jsonUrl = 'https://drive.google.com/uc?export=download&id=1nsXpZs6FYQ0FfbGwA6CuJCSFWQkgl4AN';
    
    try {
      setLoading(true);
      setError(null);
      
      // Clear existing players before loading new data
      _players.clear();
      _filteredPlayers.clear();
      notifyListeners();
      
      print('Iniciando carga de datos...');
      
      try {
        Map<String, dynamic> data = await FileImportService.downloadAndLoadJsonData(jsonUrl);
        
        // Load players
        List<Player> importedPlayers = data['players'] ?? [];
        _players.addAll(importedPlayers);
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
    _filteredPlayers = List.from(_players);
    
    print('Datos de emergencia cargados: ${_players.length} jugadores');
  }

  void clearPlayers() {
    _players.clear();
    _filteredPlayers.clear();
    notifyListeners();
  }
}