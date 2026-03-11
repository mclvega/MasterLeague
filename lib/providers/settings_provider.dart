import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  // Estados
  bool _isLoading = false;
  String? _error;
  
  // Configuraciones cargadas
  String? _defaultTeamId;
  String? _defaultTeamName;
  String? _lastJsonUrl;
  String? _dataSourceUrl;
  bool _autoLoadData = false;
  bool _offlineMode = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get defaultTeamId => _defaultTeamId;
  String? get defaultTeamName => _defaultTeamName;
  String? get lastJsonUrl => _lastJsonUrl;
  String? get dataSourceUrl => _dataSourceUrl;
  bool get autoLoadData => _autoLoadData;
  bool get offlineMode => _offlineMode;
  bool get hasDefaultTeam => _defaultTeamId != null && _defaultTeamId!.isNotEmpty;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // === INICIALIZACIÓN ===

  /// Carga todas las configuraciones desde la base de datos
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Solo una notificación al principio

    try {
      final settings = await _settingsService.getAllSettings();
      
      _defaultTeamId = settings['defaultTeamId'];
      _defaultTeamName = settings['defaultTeamName'];
      _lastJsonUrl = settings['lastJsonUrl'];
      _dataSourceUrl = settings['dataSourceUrl'];
      _autoLoadData = settings['autoLoadData'] == 'true';
      _offlineMode = settings['offlineMode'] == 'true';
      
      print('⚙️ Configuraciones cargadas');
    } catch (e) {
      _error = 'Error cargando configuraciones: $e';
      print('❌ Error cargando configuraciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Solo una notificación al final
    }
  }

  // === EQUIPO POR DEFECTO ===

  /// Establece el equipo por defecto
  Future<void> setDefaultTeam(Team team) async {
    _error = null;

    try {
      await _settingsService.setDefaultTeam(team.id, team.name);
      _defaultTeamId = team.id;
      _defaultTeamName = team.name;
      print('⚽ Equipo por defecto establecido: ${team.name}');
    } catch (e) {
      _error = 'Error estableciendo equipo por defecto: $e';
      print('❌ Error estableciendo equipo por defecto: $e');
    }
    notifyListeners(); // Solo una notificación al final
  }

  /// Elimina el equipo por defecto
  Future<void> clearDefaultTeam() async {
    _error = null;

    try {
      await _settingsService.clearDefaultTeam();
      _defaultTeamId = null;
      _defaultTeamName = null;
      print('❌ Equipo por defecto eliminado');
    } catch (e) {
      _error = 'Error eliminando equipo por defecto: $e';
      print('❌ Error eliminando equipo por defecto: $e');
    }
    notifyListeners(); // Solo una notificación al final
  }

  // === CONFIGURACIONES DE DATOS ===

  /// Establece la URL de la fuente de datos
  Future<void> setDataSourceUrl(String url) async {
    setError(null);

    try {
      await _settingsService.setDataSourceUrl(url);
      _dataSourceUrl = url;
      notifyListeners();
      print('📡 Fuente de datos configurada: $url');
    } catch (e) {
      setError('Error configurando fuente de datos: $e');
      print('❌ Error configurando fuente de datos: $e');
    }
  }

  /// Guarda la última URL utilizada
  Future<void> setLastJsonUrl(String url) async {
    setError(null);

    try {
      await _settingsService.setLastJsonUrl(url);
      _lastJsonUrl = url;
      notifyListeners();
    } catch (e) {
      setError('Error guardando última URL: $e');
      print('❌ Error guardando última URL: $e');
    }
  }

  // === CONFIGURACIONES GLOBALES ===

  /// Establece la carga automática de datos
  Future<void> setAutoLoadData(bool enabled) async {
    setError(null);

    try {
      await _settingsService.setAutoLoadData(enabled);
      _autoLoadData = enabled;
      notifyListeners();
      print('🔄 Carga automática: ${enabled ? 'activada' : 'desactivada'}');
    } catch (e) {
      setError('Error configurando carga automática: $e');
      print('❌ Error configurando carga automática: $e');
    }
  }

  /// Establece el modo offline
  Future<void> setOfflineMode(bool enabled) async {
    setError(null);

    try {
      await _settingsService.setOfflineMode(enabled);
      _offlineMode = enabled;
      notifyListeners();
      print('📴 Modo offline: ${enabled ? 'activado' : 'desactivado'}');
    } catch (e) {
      setError('Error configurando modo offline: $e');
      print('❌ Error configurando modo offline: $e');
    }
  }

  // === UTILIDADES ===

  /// Resetea todas las configuraciones
  Future<void> resetAllSettings() async {
    setLoading(true);
    setError(null);

    try {
      await _settingsService.resetAllSettings();
      _defaultTeamId = null;
      _defaultTeamName = null;
      _lastJsonUrl = null;
      _dataSourceUrl = null;
      _autoLoadData = false;
      _offlineMode = false;
      notifyListeners();
      print('🔄 Configuraciones restablecidas');
    } catch (e) {
      setError('Error restableciendo configuraciones: $e');
      print('❌ Error restableciendo configuraciones: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Exporta las configuraciones
  Future<Map<String, dynamic>?> exportSettings() async {
    setError(null);

    try {
      return await _settingsService.exportSettings();
    } catch (e) {
      setError('Error exportando configuraciones: $e');
      print('❌ Error exportando configuraciones: $e');
      return null;
    }
  }

  /// Importa configuraciones
  Future<void> importSettings(Map<String, dynamic> data) async {
    setLoading(true);
    setError(null);

    try {
      await _settingsService.importSettings(data);
      await loadSettings(); // Recarga las configuraciones
      print('📥 Configuraciones importadas');
    } catch (e) {
      setError('Error importando configuraciones: $e');
      print('❌ Error importando configuraciones: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Obtiene un resumen de las configuraciones actuales
  Map<String, dynamic> getSettingsSummary() {
    return {
      'hasDefaultTeam': hasDefaultTeam,
      'defaultTeamName': _defaultTeamName ?? 'Ninguno',
      'hasDataSource': _dataSourceUrl != null && _dataSourceUrl!.isNotEmpty,
      'autoLoadEnabled': _autoLoadData,
      'offlineModeEnabled': _offlineMode,
      'lastJsonUrl': _lastJsonUrl ?? 'N/A',
    };
  }
}