import 'package:flutter/material.dart';
import 'package:master_league/utils/theme.dart';
import 'package:provider/provider.dart';

import '../../providers/competition_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/team_provider.dart';
import '../../services/canjes_pdf_cache_service.dart';
import '../../services/file_import_service_simple.dart';
import '../../services/image_cache_service.dart';
import '../../services/reglamento_pdf_cache_service.dart';
import '../../utils/app_links.dart';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText = 'Iniciando...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.15, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startInitialization();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    _logoController.forward();

    try {
      final settingsProvider = context.read<SettingsProvider>();

      _updateProgress('Cargando configuraciones...', 0.1);
      await _yieldToUi();
      await settingsProvider.loadSettings();

      _updateProgress('Preparando recursos locales...', 0.3);
      await _yieldToUi();
      await Future.wait([
        ImageCacheService().initialize(),
        ReglamentoPdfCacheService().initialize(),
        CanjesPdfCacheService().initialize(),
      ]);

      _updateProgress('Descargando datos...', 0.55);
      await _yieldToUi();
      final data = await FileImportService.downloadAndLoadExcelData(
        AppLinks.masterLeagueExcelExport,
      );

      final playerProvider = context.read<PlayerProvider>();
      final teamProvider = context.read<TeamProvider>();
      final competitionProvider = context.read<CompetitionProvider>();

      await settingsProvider.applyRemoteBranding(
        Map<String, String>.from(data['configurations'] ?? const {}),
      );

      playerProvider.applyImportedPlayers(List.of(data['players'] ?? const []));

      _updateProgress('Actualizando equipos...', 0.72);
      await _yieldToUi();
      await teamProvider.applyImportedTeams(List.of(data['teams'] ?? const []));

      _updateProgress('Actualizando eventos...', 0.88);
      await _yieldToUi();
      competitionProvider.applyImportedData(
        List.of(data['competitions'] ?? const []),
        List.of(data['fixtures'] ?? const []),
      );

      _updateProgress('Finalizando...', 1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }

    } catch (e) {
      _updateProgress('Continuando...', 1.0);

      print('Error en splash: $e');

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }

  void _updateProgress(String statusText, double progress) {
    if (!mounted) return;
    setState(() {
      _statusText = statusText;
      _progress = progress;
    });
  }

  Future<void> _yieldToUi() async {
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo animado
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                settingsProvider.brandingLogoUrl ?? AppLinks.splashLogoImage,
                                width: 104,
                                height: 104,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.sports_soccer,
                                    size: 56,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Título de la app
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        settingsProvider.splashTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Subtítulo
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value * 0.8,
                      child: Text(
                        settingsProvider.splashSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // Progreso de carga
                Column(
                  children: [
                    // Barra de progreso
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Indicador de carga
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                    const SizedBox(height: 8),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        _statusText,
                        key: ValueKey(_statusText),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Porcentaje
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (settingsProvider.appVersion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Version ${settingsProvider.appVersion}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}