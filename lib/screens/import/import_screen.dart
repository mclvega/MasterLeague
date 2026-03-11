import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/player_provider.dart';
import '../../utils/theme.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Datos'),
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Importar desde Archivo Local',
                          style: AppTheme.titleStyle,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Selecciona un archivo Excel (.xlsx, .xls) o texto (.txt, .csv) desde tu dispositivo.',
                          style: AppTheme.bodyStyle,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isImporting ? null : _pickFile,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Seleccionar Archivo'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Importar desde URL',
                          style: AppTheme.titleStyle,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Introduce la URL de un archivo Excel o texto disponible en internet.',
                          style: AppTheme.bodyStyle,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            hintText: 'https://ejemplo.com/jugadores.xlsx',
                            labelText: 'URL del archivo',
                            prefixIcon: Icon(Icons.link),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isImporting || _urlController.text.isEmpty 
                              ? null 
                              : _importFromUrl,
                          icon: const Icon(Icons.cloud_download),
                          label: const Text('Importar desde URL'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Formato de Archivo Esperado',
                          style: AppTheme.titleStyle,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Los archivos deben incluir las siguientes columnas (el orden no importa):',
                          style: AppTheme.bodyStyle,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Name/Nombre: Nombre del jugador\n'
                          '• Position/Posición: Posición del jugador\n'
                          '• Price/Precio: Precio del jugador\n'
                          '• Overall/OVR: Valoración general\n'
                          '• Club/Equipo: Club actual\n'
                          '• Nationality/Nacionalidad: Nacionalidad\n'
                          '• Age/Edad: Edad del jugador',
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (playerProvider.isLoading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Importando jugadores...'),
                      ],
                    ),
                  ),
                if (playerProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: AppTheme.errorColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            playerProvider.error!,
                            style: const TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      setState(() => _isImporting = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'txt', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        
        if (mounted) {
          await context.read<PlayerProvider>().importPlayersFromFile(filePath);
          
          if (context.read<PlayerProvider>().error == null) {
            _showSuccessDialog();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<PlayerProvider>().setError('Error al seleccionar archivo: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _importFromUrl() async {
    try {
      setState(() => _isImporting = true);
      
      await context.read<PlayerProvider>().importPlayersFromFile(
        _urlController.text.trim(),
        isUrl: true,
      );
      
      if (context.read<PlayerProvider>().error == null) {
        _urlController.clear();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        context.read<PlayerProvider>().setError('Error al importar desde URL: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showSuccessDialog() {
    final playerCount = context.read<PlayerProvider>().players.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('Importación Exitosa'),
          ],
        ),
        content: Text('Se importaron $playerCount jugadores correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a la pantalla anterior
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}