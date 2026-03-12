import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/team_provider.dart';
import '../providers/competition_provider.dart';
import '../providers/settings_provider.dart';
import '../models/competition.dart';
import '../utils/theme.dart';
import '../utils/number_format_utils.dart';
import 'package:intl/intl.dart';
import 'players/players_screen.dart';
import 'teams/teams_screen.dart';
import 'competitions/competitions_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _eventsInitialTab = 0;

  List<Widget> get _screens => [
        const DashboardTab(),
        const PlayersScreen(),
        const TeamsScreen(),
        CompetitionsScreen(initialTabIndex: _eventsInitialTab),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Fondo transparente para mostrar la imagen
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Row(
          children: [
            // Logo de la app
            AppTheme.buildAppLogo(width: 96, height: 96),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('MRRICHAR'),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<PlayerProvider>().loadDataFromJsonUrl();
              context.read<TeamProvider>().loadDataFromJsonUrl();
              context.read<CompetitionProvider>().loadDataFromJsonUrl();
            },
            tooltip: 'Recargar Datos',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Configuraciones',
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration, // Aplicar fondo con imagen
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        onTap: (index) => setState(() {
          _selectedIndex = index;
          if (index == 3) {
            _eventsInitialTab = 0;
          }
        }),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Jugadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Equipos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Eventos',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with TickerProviderStateMixin {
  double _dashboardPrimaryCardMinHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) return 190;
    if (width < 700) return 220;
    return 250;
  }

  double _eventPreviewCardMinHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) return 84;
    if (width < 700) return 96;
    return 104;
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Cargar configuración y datos automáticamente al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
      _animationController.forward(); // Iniciar animación una sola vez
    });
  }

  Future<void> _initializeApp() async {
    // Primero, cargar configuración
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.loadSettings();
    
    // Luego cargar datos según la configuración
    if (settingsProvider.autoLoadData || 
        (!settingsProvider.offlineMode && _shouldLoadData())) {
      await _loadData();
    } else if (settingsProvider.offlineMode) {
      await _loadDataFromCache();
    }
  }

  bool _shouldLoadData() {
    final playerProvider = context.read<PlayerProvider>();
    final teamProvider = context.read<TeamProvider>();
    final competitionProvider = context.read<CompetitionProvider>();
    
    return playerProvider.players.isEmpty || 
           teamProvider.teams.isEmpty || 
           competitionProvider.competitions.isEmpty;
  }

  Future<void> _loadDataFromCache() async {
    final teamProvider = context.read<TeamProvider>();
    
    try {
      await teamProvider.loadTeamsFromCache();
    } catch (e) {
      print('Error al cargar desde caché: $e');
    }
  }

  Future<void> _loadData() async {
    final playerProvider = context.read<PlayerProvider>();
    final teamProvider = context.read<TeamProvider>();
    final competitionProvider = context.read<CompetitionProvider>();
    
    // Solo cargar si no hay datos o si se fuerza actualización
    if (_shouldLoadData()) {
      await Future.wait([
        playerProvider.loadDataFromJsonUrl(),
        teamProvider.loadDataFromJsonUrl(),
        competitionProvider.loadDataFromJsonUrl(),
      ]);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<PlayerProvider, TeamProvider, CompetitionProvider, SettingsProvider>(
      builder: (context, playerProvider, teamProvider, competitionProvider, settingsProvider, child) {
        
        // Mostrar pantalla de carga mientras se importan datos
        if (playerProvider.isLoading && playerProvider.players.isEmpty) {
          return _buildLoadingScreen();
        }
        
        // Mostrar pantalla de error si ocurre un problema
        if (playerProvider.error != null && playerProvider.players.isEmpty) {
          return _buildErrorScreen(playerProvider.error!, () => _loadData());
        }
        
        // Mostrar tablero principal con animaciones
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMainDashboard(context, playerProvider, teamProvider, competitionProvider, settingsProvider),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando datos desde Google Sheets...',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '⚽ Importando jugadores, equipos y eventos',
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Puntos animados
          _buildAnimatedDots(),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.3;
            final animationValue = ((_animationController.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 8 + (4 * scale),
              height: 8 + (4 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.4 + 0.6 * scale),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildErrorScreen(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar datos',
              style: AppTheme.titleStyle.copyWith(
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboard(
    BuildContext context,
    PlayerProvider playerProvider,
    TeamProvider teamProvider,
    CompetitionProvider competitionProvider,
    SettingsProvider settingsProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inicio',
                  style: AppTheme.headlineStyle.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (settingsProvider.hasDefaultTeam) ...[
                  _buildDefaultTeamDetails(context, settingsProvider, teamProvider, playerProvider),
                  const SizedBox(height: 20),
                ] else ...[
                  Card(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: _dashboardPrimaryCardMinHeight(context)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 32),
                            const SizedBox(height: 10),
                            const Text(
                              'Selecciona tu equipo en configuración para mostrar estadísticas personalizadas.',
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyStyle,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings),
                              label: const Text('Ir a configuración'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _buildEventsSummary(context, competitionProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsSummary(
    BuildContext context,
    CompetitionProvider competitionProvider,
  ) {
    final activeEvents = competitionProvider.ongoingCompetitions;
    final upcomingEvents = competitionProvider.upcomingCompetitions;

    return Card(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: _dashboardPrimaryCardMinHeight(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToEventsTab(context, 0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Eventos',
                  style: AppTheme.titleStyle,
                ),
                const SizedBox(height: 12),
                _buildEventPreviewList(
                  context: context,
                  title: 'Activos ahora',
                  events: activeEvents,
                  color: AppTheme.successColor,
                  emptyText: 'No hay eventos activos en este momento.',
                  targetTabIndex: 1,
                ),
                const SizedBox(height: 10),
                _buildEventPreviewList(
                  context: context,
                  title: 'Próximos eventos',
                  events: upcomingEvents,
                  color: AppTheme.infoColor,
                  emptyText: 'No hay eventos próximos.',
                  targetTabIndex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventPreviewList({
    required BuildContext context,
    required String title,
    required List<Competition> events,
    required Color color,
    required String emptyText,
    required int targetTabIndex,
  }) {
    final visibleItems = events.take(3).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _navigateToEventsTab(context, targetTabIndex),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: _eventPreviewCardMinHeight(context)),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.subtitleStyle.copyWith(color: color),
            ),
            const SizedBox(height: 6),
            if (visibleItems.isEmpty)
              Text(
                emptyText,
                style: AppTheme.captionStyle,
              )
            else
              ...visibleItems.map(
                (event) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.name,
                          style: AppTheme.bodyStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(event.startDate),
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultTeamDetails(
    BuildContext context,
    SettingsProvider settingsProvider,
    TeamProvider teamProvider,
    PlayerProvider playerProvider,
  ) {
    final defaultTeam = teamProvider.getTeamById(settingsProvider.defaultTeamId!);

    if (defaultTeam == null) {
      return Card(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: _dashboardPrimaryCardMinHeight(context)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No se encontró el equipo por defecto en la lista actual.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(color: Colors.grey[700]),
              ),
            ),
          ),
        ),
      );
    }

    final teamPlayers = playerProvider.players.where((player) {
      final isByTeamId = player.teamId != null && player.teamId == defaultTeam.id;
      final isByPlayerList = defaultTeam.playerIds.contains(player.id);
      return isByTeamId || isByPlayerList;
    }).toList();

    final avgOverall = teamPlayers.isEmpty
        ? 0.0
        : teamPlayers.map((p) => p.overall).reduce((a, b) => a + b) / teamPlayers.length;

    final totalValue = teamPlayers.fold<double>(0.0, (sum, p) => sum + p.price);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TeamDetailsScreen(team: defaultTeam),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: (defaultTeam.logoUrl != null && defaultTeam.logoUrl!.isNotEmpty)
                          ? Image.network(
                              defaultTeam.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => AppTheme.buildAppLogo(width: 56, height: 56),
                            )
                          : AppTheme.buildAppLogo(width: 56, height: 56),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          defaultTeam.name,
                          style: AppTheme.titleStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DT: ${defaultTeam.ownerName}',
                          style: AppTheme.bodyStyle.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 18),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMiniStat('Jugadores', teamPlayers.length.toString(), Icons.people),
                  _buildMiniStat('Media Plantilla', avgOverall.toStringAsFixed(1), Icons.trending_up),
                  _buildMiniStat('Valor Plantilla', '\$${NumberFormatUtils.money(totalValue)}', Icons.attach_money),
                  _buildMiniStat('Presupuesto', '\$${NumberFormatUtils.money(defaultTeam.budget)}', Icons.account_balance_wallet),
                ],
              ),
              if (defaultTeam.stats != null) ...[
                const SizedBox(height: 14),
                Text('Estadísticas competitivas', style: AppTheme.subtitleStyle),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSmallMetric('PTS', defaultTeam.stats!.points.toString()),
                    _buildSmallMetric('PJ', defaultTeam.stats!.matchesPlayed.toString()),
                    _buildSmallMetric('G', defaultTeam.stats!.wins.toString()),
                    _buildSmallMetric('E', defaultTeam.stats!.draws.toString()),
                    _buildSmallMetric('P', defaultTeam.stats!.losses.toString()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

 
  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.titleStyle.copyWith(color: AppTheme.primaryColor)),
      ],
    );
  }

  
  void _navigateToEventsTab(BuildContext context, int eventsTabIndex) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.setState(() {
        homeState._eventsInitialTab = eventsTabIndex;
        homeState._selectedIndex = 3;
      });
    }
  }
}
