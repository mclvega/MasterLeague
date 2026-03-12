import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/file_import_service_simple.dart';
import '../utils/position_utils.dart';

class PlayerProvider with ChangeNotifier {
  static const Map<String, int> _positionSortOrder = {
    'PT': 1,
    'DEC': 2,
    'LI': 3,
    'LD': 4,
    'MCD': 5,
    'MC': 6,
    'MDI': 7,
    'MDD': 8,
    'MO': 9,
    'EXI': 10,
    'EXD': 11,
    'SD': 12,
    'DC': 13,
  };

  final List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _positionFilter;
  String? _teamFilter;
  String? _countryFilter;
  double? _minPriceFilter;
  double? _maxPriceFilter;

  List<Player> get players => _players;
  List<Player> get filteredPlayers => _filteredPlayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Player> get freeAgents {
    final agents = _players.where((player) => player.isFreeAgent).toList();
    agents.sort((a, b) => a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));
    return agents;
  }

  List<Player> getPlayersByTeam(String teamId) {
    final teamPlayers = _players.where((player) => player.teamId == teamId).toList();
    teamPlayers.sort((a, b) => a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));
    return teamPlayers;
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
    _sortPlayersAlphabetically();
    _filteredPlayers = List.from(_players);
    notifyListeners();
  }

  void updatePlayer(Player updatedPlayer) {
    final index = _players.indexWhere((player) => player.id == updatedPlayer.id);
    if (index != -1) {
      _players[index] = updatedPlayer;
      _sortPlayersAlphabetically();
      _filteredPlayers = List.from(_players);
      notifyListeners();
    }
  }

  void removePlayer(String playerId) {
    _players.removeWhere((player) => player.id == playerId);
    _sortPlayersAlphabetically();
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
    _positionFilter = (position == null || position.isEmpty)
        ? null
        : PositionUtils.normalize(position).toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByTeam(String? teamId) {
    _teamFilter = (teamId == null || teamId.isEmpty) ? null : teamId;
    _applyFilters();
    notifyListeners();
  }

  void filterByCountry(String? country) {
    _countryFilter = (country == null || country.isEmpty) ? null : country.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByPriceRange(double? minPrice, double? maxPrice) {
    _minPriceFilter = minPrice;
    _maxPriceFilter = maxPrice;
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
          PositionUtils.normalize(player.position).toLowerCase() == _positionFilter;

      final matchesTeam = _teamFilter == null ||
          ((player.teamId ?? '') == _teamFilter);

        final matchesCountry = _countryFilter == null ||
          player.nationality.toLowerCase() == _countryFilter;

        final matchesMinPrice = _minPriceFilter == null || player.price >= _minPriceFilter!;
        final matchesMaxPrice = _maxPriceFilter == null || player.price <= _maxPriceFilter!;

        return matchesSearch &&
          matchesPosition &&
          matchesTeam &&
          matchesCountry &&
          matchesMinPrice &&
          matchesMaxPrice;
    }).toList();
    _sortFilteredPlayersAlphabetically();
  }

  void _sortPlayersAlphabetically() {
    _players.sort((a, b) => a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));
  }

  void _sortFilteredPlayersAlphabetically() {
    _filteredPlayers.sort((a, b) => a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));
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
      case 'position':
        _filteredPlayers.sort((a, b) {
          final posA = _positionOrderForPlayer(a);
          final posB = _positionOrderForPlayer(b);
          if (posA != posB) {
            return ascending ? posA.compareTo(posB) : posB.compareTo(posA);
          }

          final nameCompare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return ascending ? nameCompare : -nameCompare;
        });
        break;
    }
    notifyListeners();
  }

  int _positionOrderForPlayer(Player player) {
    final normalized = PositionUtils.normalize(player.position).toUpperCase();
    return _positionSortOrder[normalized] ?? 999;
  }

  Future<void> importPlayersFromFile(String filePath, {bool isUrl = false}) async {
    // Método simplificado - usar loadDataFromJsonUrl para toda importación
    await loadDataFromJsonUrl();
  }

  Future<void> loadDataFromJsonUrl() async {
    // Google Sheets URL (se exporta automaticamente a Excel)
    const String excelUrl =
        'https://docs.google.com/spreadsheets/d/1QwBnvXQpDXIb5q4AUd3Sh4PI1zjmTQ03/export?format=xlsx';
    
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
        _sortPlayersAlphabetically();
        _searchQuery = '';
        _positionFilter = null;
        _teamFilter = null;
        _countryFilter = null;
        _minPriceFilter = null;
        _maxPriceFilter = null;
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
    _sortPlayersAlphabetically();
    _searchQuery = '';
    _positionFilter = null;
    _teamFilter = null;
    _countryFilter = null;
    _minPriceFilter = null;
    _maxPriceFilter = null;
    _filteredPlayers = List.from(_players);
    
    print('Datos de emergencia cargados: ${_players.length} jugadores');
  }

  void clearPlayers() {
    _players.clear();
    _filteredPlayers.clear();
    notifyListeners();
  }
}