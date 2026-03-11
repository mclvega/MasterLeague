import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // URLs de las imágenes a descargar
  static const String logoUrl = 'https://mrrichar.netlify.app/logo.png';
  static const String backgroundUrl = 'https://mrrichar.netlify.app/fondo-default.png';
  
  // Nombres de archivos locales
  static const String logoFileName = 'app_logo.png';
  static const String backgroundFileName = 'background_image.png';

  bool _isInitialized = false;
  String? _logoPath;
  String? _backgroundPath;
  
  // Getters para las rutas locales
  String? get logoPath => _logoPath;
  String? get backgroundPath => _backgroundPath;
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio descargando las imágenes si es necesario
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🖼️ Inicializando cache de imágenes...');
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      // Crear directorio si no existe
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final logoFile = File('${imagesDir.path}/$logoFileName');
      final backgroundFile = File('${imagesDir.path}/$backgroundFileName');

      // Descargar logo si no existe localmente
      if (!await logoFile.exists()) {
        print('📥 Descargando logo...');
        await _downloadImage(logoUrl, logoFile);
      } else {
        print('✅ Logo ya existe localmente');
      }
      
      // Descargar fondo si no existe localmente
      if (!await backgroundFile.exists()) {
        print('📥 Descargando imagen de fondo...');
        await _downloadImage(backgroundUrl, backgroundFile);
      } else {
        print('✅ Fondo ya existe localmente');
      }

      _logoPath = logoFile.path;
      _backgroundPath = backgroundFile.path;
      _isInitialized = true;
      
      print('✅ Cache de imágenes inicializado correctamente');
      
    } catch (e) {
      print('❌ Error inicializando cache de imágenes: $e');
      // En caso de error, usar imágenes por defecto o assets
      await _setupFallbackAssets();
    }
  }

  /// Descarga una imagen desde URL y la guarda localmente
  Future<void> _downloadImage(String url, File destinationFile) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Master League App/1.0.0',
        },
      );

      if (response.statusCode == 200) {
        await destinationFile.writeAsBytes(response.bodyBytes);
        print('✅ Imagen descargada: ${destinationFile.path}');
      } else {
        throw Exception('Error HTTP ${response.statusCode} descargando $url');
      }
    } catch (e) {
      print('❌ Error descargando imagen $url: $e');
      rethrow;
    }
  }

  /// Configura assets de respaldo si falla la descarga
  Future<void> _setupFallbackAssets() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Crear imagen de logo por defecto (placeholder)
      final logoFile = File('${imagesDir.path}/$logoFileName');
      if (!await logoFile.exists()) {
        await _createPlaceholderLogo(logoFile);
      }

      _logoPath = logoFile.path;
      _isInitialized = true;
      
      print('🚧 Configurados assets de respaldo');
      
    } catch (e) {
      print('❌ Error configurando assets de respaldo: $e');
    }
  }

  /// Crea un logo placeholder simple
  Future<void> _createPlaceholderLogo(File logoFile) async {
    try {
      // Crear una imagen simple programáticamente (pixel transparente)
      final Uint8List pngBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
        0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84,
        120, 156, 99, 248, 15, 0, 0, 1, 0, 1, 0, 24, 221, 141, 219, 0, 0, 0, 0,
        73, 69, 78, 68, 174, 66, 96, 130
      ]);
      
      await logoFile.writeAsBytes(pngBytes);
      print('🖼️ Logo placeholder creado');
    } catch (e) {
      print('❌ Error creando logo placeholder: $e');
    }
  }

  /// Actualiza las imágenes descargándolas nuevamente
  Future<void> updateImages() async {
    print('🔄 Actualizando imágenes...');
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      final logoFile = File('${imagesDir.path}/$logoFileName');
      final backgroundFile = File('${imagesDir.path}/$backgroundFileName');

      // Eliminar archivos existentes
      if (await logoFile.exists()) {
        await logoFile.delete();
      }
      if (await backgroundFile.exists()) {
        await backgroundFile.delete();
      }

      // Descargar nuevamente
      await _downloadImage(logoUrl, logoFile);
      await _downloadImage(backgroundUrl, backgroundFile);

      _logoPath = logoFile.path;
      _backgroundPath = backgroundFile.path;
      
      print('✅ Imágenes actualizadas correctamente');
      
    } catch (e) {
      print('❌ Error actualizando imágenes: $e');
    }
  }

  /// Limpia el cache de imágenes
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
        print('🗑️ Cache de imágenes limpiado');
      }
      
      _logoPath = null;
      _backgroundPath = null;
      _isInitialized = false;
      
    } catch (e) {
      print('❌ Error limpiando cache de imágenes: $e');
    }
  }

  /// Obtiene el tamaño total del cache en bytes
  Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      if (!await imagesDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
      
    } catch (e) {
      print('❌ Error calculando tamaño del cache: $e');
      return 0;
    }
  }

  /// Verifica si las imágenes están disponibles localmente
  Future<bool> areImagesAvailable() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      
      final logoFile = File('${imagesDir.path}/$logoFileName');
      final backgroundFile = File('${imagesDir.path}/$backgroundFileName');
      
      return await logoFile.exists() && await backgroundFile.exists();
      
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información del cache
  Future<Map<String, dynamic>> getCacheInfo() async {
    final size = await getCacheSize();
    final available = await areImagesAvailable();
    
    return {
      'isInitialized': _isInitialized,
      'logoPath': _logoPath,
      'backgroundPath': _backgroundPath,
      'cacheSize': size,
      'cacheSizeFormatted': '${(size / 1024).toStringAsFixed(1)} KB',
      'imagesAvailable': available,
    };
  }
}