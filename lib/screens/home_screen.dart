import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/team_provider.dart';
import '../providers/competition_provider.dart';
import '../utils/theme.dart';
import 'players/players_screen.dart';
import 'teams/teams_screen.dart';
import 'competitions/competitions_screen.dart';
import 'free_agents/free_agents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const PlayersScreen(),
    const TeamsScreen(),
    const CompetitionsScreen(),
    const FreeAgentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master League Football'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PlayerProvider>().loadDataFromJsonUrl();
              context.read<TeamProvider>().loadDataFromJsonUrl();
              context.read<CompetitionProvider>().loadDataFromJsonUrl();
            },
            tooltip: 'Recargar Datos',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
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
            label: 'Competiciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_disabled),
            label: 'Libres',
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(); // Make the animation repeat continuously
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Load data automatically when the dashboard initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final playerProvider = context.read<PlayerProvider>();
    final teamProvider = context.read<TeamProvider>();
    final competitionProvider = context.read<CompetitionProvider>();
    
    // Only load if no data exists yet
    if (playerProvider.players.isEmpty || teamProvider.teams.isEmpty || competitionProvider.competitions.isEmpty) {
      await Future.wait([
        playerProvider.loadDataFromJsonUrl(),
        teamProvider.loadDataFromJsonUrl(),
        competitionProvider.loadDataFromJsonUrl(),
      ]);
      
      if (mounted && playerProvider.error == null) {
        // Stop the repeating animation and play the entrance animation
        _animationController.stop();
        _animationController.reset();
        _animationController.forward();
      } else {
        // Keep the loading animation if there's an error
        _animationController.repeat();
      }
    } else {
      // Data already loaded, just play the entrance animation
      _animationController.stop();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayerProvider, TeamProvider, CompetitionProvider>(
      builder: (context, playerProvider, teamProvider, competitionProvider, child) {
        
        // Show loading screen while importing data
        if (playerProvider.isLoading && playerProvider.players.isEmpty) {
          return _buildLoadingScreen();
        }
        
        // Show error screen if there's an error
        if (playerProvider.error != null && playerProvider.players.isEmpty) {
          return _buildErrorScreen(playerProvider.error!, () => _loadData());
        }
        
        // Show main dashboard with animations
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMainDashboard(context, playerProvider, teamProvider, competitionProvider),
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
            '⚽ Importando jugadores, equipos y competiciones',
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Animated dots
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
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Resumen de la Liga',
            style: AppTheme.headlineStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatsCard(
                  'Total Jugadores',
                  playerProvider.players.length.toString(),
                  Icons.people,
                  AppTheme.primaryColor,
                ),
                _buildStatsCard(
                  'Jugadores Libres',
                  playerProvider.freeAgents.length.toString(),
                  Icons.person_add_disabled,
                  AppTheme.warningColor,
                ),
                _buildStatsCard(
                  'Equipos',
                  teamProvider.teams.length.toString(),
                  Icons.group,
                  AppTheme.secondaryColor,
                ),
                _buildStatsCard(
                  'Competiciones',
                  competitionProvider.competitions.length.toString(),
                  Icons.emoji_events,
                  AppTheme.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildRecentActivity(context, playerProvider, teamProvider, competitionProvider),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headlineStyle.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.subtitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    PlayerProvider playerProvider,
    TeamProvider teamProvider,
    CompetitionProvider competitionProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividad Reciente',
              style: AppTheme.titleStyle,
            ),
            const SizedBox(height: 12),
            if (competitionProvider.ongoingCompetitions.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.sports_soccer, color: AppTheme.successColor),
                title: Text('${competitionProvider.ongoingCompetitions.length} competiciones activas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToTab(context, 3),
              ),
            ],
            if (playerProvider.freeAgents.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.person_add, color: AppTheme.warningColor),
                title: Text('${playerProvider.freeAgents.length} jugadores libres disponibles'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToTab(context, 4),
              ),
            ],
            if (teamProvider.teams.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.group, color: AppTheme.infoColor),
                title: Text('${teamProvider.teams.length} equipos registrados'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToTab(context, 2),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    // Find the ancestor state using the context
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.setState(() {
        homeState._selectedIndex = tabIndex;
      });
    }
  }
}