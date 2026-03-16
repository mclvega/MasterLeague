import 'dart:async';
import 'database_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final DatabaseService _db = DatabaseService();

  // Claves de configuraciones
  static const String _defaultTeamIdKey = 'default_team_id';
  static const String _defaultTeamNameKey = 'default_team_name';
  static const String _lastJsonUrlKey = 'last_json_url';
  static const String _autoLoadDataKey = 'auto_load_data';
  static const String _offlineModeKey = 'offline_mode';
  static const String _dataSourceUrlKey = 'data_source_url';
  static const String _brandingLogoUrlKey = 'branding_logo_url';
  static const String _brandingAppTitleKey = 'branding_app_title';
  static const String _brandingSplashTitleKey = 'branding_splash_title';
  static const String _brandingSplashSubtitleKey = 'branding_splash_subtitle';

  // === EQUIPO POR DEFECTO ===

  /// Obtiene el ID del equipo por defecto seleccionado
  Future<String?> getDefaultTeamId() async {
    return await _db.getSetting(_defaultTeamIdKey);
  }

  /// Establece el equipo por defecto
  Future<void> setDefaultTeam(String teamId, String teamName) async {
    await Future.wait([
      _db.setSetting(_defaultTeamIdKey, teamId),
      _db.setSetting(_defaultTeamNameKey, teamName),
    ]);
    print('⚽ Equipo por defecto establecido: $teamName ($teamId)');
  }

  /// Obtiene el nombre del equipo por defecto
  Future<String?> getDefaultTeamName() async {
    return await _db.getSetting(_defaultTeamNameKey);
  }

  /// Remueve la configuración del equipo por defecto
  Future<void> clearDefaultTeam() async {
    await Future.wait([
      _db.deleteSetting(_defaultTeamIdKey),
      _db.deleteSetting(_defaultTeamNameKey),
    ]);
    print('❌ Equipo por defecto eliminado');
  }

  /// Verifica si hay un equipo por defecto configurado
  Future<bool> hasDefaultTeam() async {
    final teamId = await getDefaultTeamId();
    return teamId != null && teamId.isNotEmpty;
  }

  // === CONFIGURACION DE DATOS ===

  /// Obtiene la última URL utilizada para cargar datos JSON
  Future<String?> getLastJsonUrl() async {
    return await _db.getSetting(_lastJsonUrlKey);
  }

  /// Establece la última URL utilizada para cargar datos JSON
  Future<void> setLastJsonUrl(String url) async {
    await _db.setSetting(_lastJsonUrlKey, url);
    print('🌐 URL de datos guardada: $url');
  }

  /// Obtiene la URL de la fuente de datos configurada
  Future<String?> getDataSourceUrl() async {
    return await _db.getSetting(_dataSourceUrlKey);
  }

  /// Establece la URL de la fuente de datos
  Future<void> setDataSourceUrl(String url) async {
    await _db.setSetting(_dataSourceUrlKey, url);
    print('📡 Fuente de datos configurada: $url');
  }

  // === CONFIGURACIONES GLOBALES ===

  /// Obtiene si se debe cargar automáticamente los datos al iniciar
  Future<bool> getAutoLoadData() async {
    final value = await _db.getSetting(_autoLoadDataKey);
    return value?.toLowerCase() == 'true';
  }

  /// Establece la carga automática de datos
  Future<void> setAutoLoadData(bool enabled) async {
    await _db.setSetting(_autoLoadDataKey, enabled.toString());
    print('🔄 Carga automática: ${enabled ? 'activada' : 'desactivada'}');
  }

  /// Obtiene si está activado el modo offline
  Future<bool> getOfflineMode() async {
    final value = await _db.getSetting(_offlineModeKey);
    return value?.toLowerCase() == 'true';
  }

  /// Establece el modo offline
  Future<void> setOfflineMode(bool enabled) async {
    await _db.setSetting(_offlineModeKey, enabled.toString());
    print('📴 Modo offline: ${enabled ? 'activado' : 'desactivado'}');
  }

  Future<String?> getBrandingLogoUrl() async {
    return await _db.getSetting(_brandingLogoUrlKey);
  }

  Future<String?> getBrandingAppTitle() async {
    return await _db.getSetting(_brandingAppTitleKey);
  }

  Future<String?> getBrandingSplashTitle() async {
    return await _db.getSetting(_brandingSplashTitleKey);
  }

  Future<String?> getBrandingSplashSubtitle() async {
    return await _db.getSetting(_brandingSplashSubtitleKey);
  }

  Future<void> setBrandingConfiguration({
    String? logoUrl,
    String? appTitle,
    String? splashTitle,
    String? splashSubtitle,
  }) async {
    await Future.wait([
      _setOrDelete(_brandingLogoUrlKey, logoUrl),
      _setOrDelete(_brandingAppTitleKey, appTitle),
      _setOrDelete(_brandingSplashTitleKey, splashTitle),
      _setOrDelete(_brandingSplashSubtitleKey, splashSubtitle),
    ]);
  }

  // === UTILIDADES ===

  /// Obtiene todas las configuraciones como un mapa
  Future<Map<String, String?>> getAllSettings() async {
    return {
      'defaultTeamId': await getDefaultTeamId(),
      'defaultTeamName': await getDefaultTeamName(),
      'lastJsonUrl': await getLastJsonUrl(),
      'dataSourceUrl': await getDataSourceUrl(),
      'autoLoadData': (await getAutoLoadData()).toString(),
      'offlineMode': (await getOfflineMode()).toString(),
      'brandingLogoUrl': await getBrandingLogoUrl(),
      'brandingAppTitle': await getBrandingAppTitle(),
      'brandingSplashTitle': await getBrandingSplashTitle(),
      'brandingSplashSubtitle': await getBrandingSplashSubtitle(),
    };
  }

  /// Resetea todas las configuraciones
  Future<void> resetAllSettings() async {
    await Future.wait([
      _db.deleteSetting(_defaultTeamIdKey),
      _db.deleteSetting(_defaultTeamNameKey),
      _db.deleteSetting(_lastJsonUrlKey),
      _db.deleteSetting(_autoLoadDataKey),
      _db.deleteSetting(_offlineModeKey),
      _db.deleteSetting(_dataSourceUrlKey),
      _db.deleteSetting(_brandingLogoUrlKey),
      _db.deleteSetting(_brandingAppTitleKey),
      _db.deleteSetting(_brandingSplashTitleKey),
      _db.deleteSetting(_brandingSplashSubtitleKey),
    ]);
    print('🔄 Todas las configuraciones han sido restablecidas');
  }

  /// Exporta las configuraciones como JSON
  Future<Map<String, dynamic>> exportSettings() async {
    final settings = await getAllSettings();
    return {
      'exported_at': DateTime.now().toIso8601String(),
      'settings': settings,
    };
  }

  /// Importa configuraciones desde un mapa
  Future<void> importSettings(Map<String, dynamic> data) async {
    if (data['settings'] is Map<String, dynamic>) {
      final settings = data['settings'] as Map<String, dynamic>;
      
      for (final entry in settings.entries) {
        if (entry.value != null) {
          switch (entry.key) {
            case 'defaultTeamId':
              await _db.setSetting(_defaultTeamIdKey, entry.value.toString());
              break;
            case 'defaultTeamName':
              await _db.setSetting(_defaultTeamNameKey, entry.value.toString());
              break;
            case 'lastJsonUrl':
              await _db.setSetting(_lastJsonUrlKey, entry.value.toString());
              break;
            case 'dataSourceUrl':
              await _db.setSetting(_dataSourceUrlKey, entry.value.toString());
              break;
            case 'autoLoadData':
              await _db.setSetting(_autoLoadDataKey, entry.value.toString());
              break;
            case 'offlineMode':
              await _db.setSetting(_offlineModeKey, entry.value.toString());
              break;
            case 'brandingLogoUrl':
              await _setOrDelete(_brandingLogoUrlKey, entry.value?.toString());
              break;
            case 'brandingAppTitle':
              await _setOrDelete(_brandingAppTitleKey, entry.value?.toString());
              break;
            case 'brandingSplashTitle':
              await _setOrDelete(_brandingSplashTitleKey, entry.value?.toString());
              break;
            case 'brandingSplashSubtitle':
              await _setOrDelete(_brandingSplashSubtitleKey, entry.value?.toString());
              break;
          }
        }
      }
      print('📥 Configuraciones importadas exitosamente');
    }
  }

  Future<void> _setOrDelete(String key, String? value) async {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      await _db.deleteSetting(key);
      return;
    }
    await _db.setSetting(key, normalized);
  }
}