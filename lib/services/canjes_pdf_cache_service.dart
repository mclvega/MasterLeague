import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/app_links.dart';

class CanjesPdfCacheService {
  static final CanjesPdfCacheService _instance =
      CanjesPdfCacheService._internal();
  factory CanjesPdfCacheService() => _instance;
  CanjesPdfCacheService._internal();

  static const String _fileName = 'canjes.pdf';

  bool _isInitialized = false;
  String? _pdfPath;

  bool get isInitialized => _isInitialized;
  String? get pdfPath => _pdfPath;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final file = await _getPdfFile();

      if (!await file.exists()) {
        await _downloadPdf(file);
      }

      _pdfPath = file.path;
      _isInitialized = true;
    } catch (e) {
      print('Error inicializando cache de canjes: $e');
      rethrow;
    }
  }

  Future<void> updatePdf() async {
    try {
      final file = await _getPdfFile();
      await _downloadPdf(file);
      _pdfPath = file.path;
      _isInitialized = true;
    } catch (e) {
      print('Error actualizando PDF de canjes: $e');
      rethrow;
    }
  }

  Future<Uint8List?> getPdfBytes() async {
    try {
      final file = await _getPdfFile();
      if (!await file.exists()) {
        return null;
      }
      return await file.readAsBytes();
    } catch (e) {
      print('Error leyendo PDF de canjes: $e');
      return null;
    }
  }

  Future<File> _getPdfFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/documents');

    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    return File('${pdfDir.path}/$_fileName');
  }

  Future<void> _downloadPdf(File destinationFile) async {
    final response = await http.get(
      Uri.parse(AppLinks.canjesPdf),
      headers: {
        'User-Agent': 'Master League App/1.0.0',
        'Accept': 'application/pdf,*/*',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error HTTP ${response.statusCode} al descargar canjes');
    }

    await destinationFile.writeAsBytes(response.bodyBytes);
  }
}
