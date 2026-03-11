import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ThemeShowcaseScreen extends StatelessWidget {
  const ThemeShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Nuevo Tema - Showcase'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con fondo prominente
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.prominentBackgroundDecoration,
                child: const Text(
                  '🎨 Nuevo Tema Aplicado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Tarjetas de colores
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Color Principal: Azul Moderno',
                        style: AppTheme.titleStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ColorSample('Primario', AppTheme.primaryColor, Colors.white),
                          _ColorSample('Secundario', AppTheme.secondaryColor, Colors.white),
                          _ColorSample('Acento', AppTheme.accentColor, Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botones de ejemplo
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Botones con Letras Blancas',
                        style: AppTheme.titleStyle,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.star),
                              label: const Text('Botón Primario'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite),
                              label: const Text('Outlined'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Colores de posiciones
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Colores por Posición',
                        style: AppTheme.titleStyle,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: AppTheme.positionColors.entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: entry.value.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: entry.key == 'GK' ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Información del fondo
              Card(
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.image, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Fondo de Imagen',
                            style: AppTheme.titleStyle.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'URL: ${AppTheme.backgroundImageUrl}',
                        style: AppTheme.captionStyle,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '✅ Imagen de fondo aplicada con transparencia\n'
                        '✅ Gradiente azul suave superpuesto\n'
                        '✅ Compatible con contenido legible',
                        style: TextStyle(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón de prueba FAB
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Nuevo tema aplicado con éxito!'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Probar Tema'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSample extends StatelessWidget {
  final String name;
  final Color color;
  final Color textColor;

  const _ColorSample(this.name, this.color, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.palette,
              color: textColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}