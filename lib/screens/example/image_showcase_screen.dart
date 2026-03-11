import 'package:flutter/material.dart';
import '../../services/image_cache_service.dart';
import '../../utils/theme.dart';

class ImageShowcaseScreen extends StatefulWidget {
  const ImageShowcaseScreen({Key? key}) : super(key: key);

  @override
  State<ImageShowcaseScreen> createState() => _ImageShowcaseScreenState();
}

class _ImageShowcaseScreenState extends State<ImageShowcaseScreen> {
  final ImageCacheService _imageService = ImageCacheService();
  Map<String, dynamic>? _cacheInfo;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    final info = await _imageService.getCacheInfo();
    setState(() {
      _cacheInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Imágenes de la App'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              setState(() {
                _cacheInfo = null;
              });
              await _imageService.updateImages();
              await _loadCacheInfo();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Imágenes actualizadas'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: _cacheInfo == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header informativo
                    Card(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📱 Imágenes de la Aplicación',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Estado del cache: ${_cacheInfo!['isInitialized'] ? 'Inicializado' : 'No inicializado'}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text('Tamaño total: ${_cacheInfo!['cacheSizeFormatted']}'),
                            Text(
                              'Imágenes disponibles: ${_cacheInfo!['imagesAvailable'] ? '✅' : '❌'}',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logo de la app
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              '🎯 Logo de la Aplicación',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Logo grande
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: AppTheme.buildAppLogo(
                                width: 120,
                                height: 120,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Diferentes tamaños del logo
                            const Text(
                              'Diferentes tamaños:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _LogoSample('16x16', 16),
                                _LogoSample('24x24', 24),
                                _LogoSample('32x32', 32),
                                _LogoSample('48x48', 48),
                                _LogoSample('64x64', 64),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Vista previa del fondo
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              '🖼️ Imagen de Fondo',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Muestra del fondo con diferentes opacidades
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Fondo completo
                                    Container(
                                      decoration: AppTheme.prominentBackgroundDecoration,
                                    ),
                                    
                                    // Overlay con información
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black54,
                                            Colors.transparent,
                                            Colors.black54,
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    // Texto informativo
                                    const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Vista previa del fondo',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 3,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Opacidad: 30%',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 3,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Información técnica
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚙️ Información Técnica',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            _TechnicalInfo('URLs de origen'),
                            const SizedBox(height: 8),
                            _TechnicalDetail('Logo', 'https://mrrichar.netlify.app/logo.png'),
                            _TechnicalDetail('Fondo', 'https://mrrichar.netlify.app/fondo-default.png'),
                            
                            const SizedBox(height: 16),
                            _TechnicalInfo('Rutas locales'),
                            const SizedBox(height: 8),
                            _TechnicalDetail(
                              'Logo', 
                              _cacheInfo!['logoPath']?.toString() ?? 'No disponible'
                            ),
                            _TechnicalDetail(
                              'Fondo', 
                              _cacheInfo!['backgroundPath']?.toString() ?? 'No disponible'
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LogoSample extends StatelessWidget {
  final String label;
  final double size;

  const _LogoSample(this.label, this.size);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size + 8,
          height: size + 8,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: AppTheme.buildAppLogo(
              width: size,
              height: size,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class _TechnicalInfo extends StatelessWidget {
  final String title;

  const _TechnicalInfo(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }
}

class _TechnicalDetail extends StatelessWidget {
  final String label;
  final String value;

  const _TechnicalDetail(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}