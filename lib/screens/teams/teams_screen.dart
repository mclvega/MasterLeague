import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player.dart';
import '../../providers/team_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/team.dart';
import '../../utils/number_format_utils.dart';
import '../../utils/position_utils.dart';
import '../../utils/theme.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TeamProvider, PlayerProvider>(
      builder: (context, teamProvider, playerProvider, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.group,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Equipos',
                    style: AppTheme.headlineStyle.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceColor),
                    ),
                    child: Text(
                      teamProvider.teams.length.toString(),
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildTeamsList(teamProvider.teams, playerProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamsList(List<Team> teams, PlayerProvider playerProvider) {
    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay equipos registrados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los equipos aparecerán aquí cuando importes datos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        return TeamCard(
          team: teams[index], 
          playerProvider: playerProvider,
        );
      },
    );
  }
}

class TeamCard extends StatelessWidget {
  final Team team;
  final PlayerProvider playerProvider;

  const TeamCard({
    super.key,
    required this.team,
    required this.playerProvider,
  });

  @override
  Widget build(BuildContext context) {
    final teamPlayers = playerProvider.getPlayersByTeam(team.id);
    final totalValue = teamPlayers.fold<double>(
      0, 
      (sum, player) => sum + player.price,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showTeamDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTeamAvatar(radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: AppTheme.titleStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Propietario: ${team.ownerName}',
                          style: AppTheme.subtitleStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (team.homeStadium != null)
                          Text(
                            '🏟️ ${team.homeStadium}',
                            style: AppTheme.captionStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (team.stats?.position != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPositionColor(team.stats!.position!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${team.stats!.position}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (team.stats?.points != null)
                        Text(
                          '${team.stats!.points} pts',
                          style: AppTheme.titleStyle.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información financiera
              Row(
                children: [
                  Expanded(
                    child: _buildFinanceCard(
                      'Presupuesto',
                      '\$${NumberFormatUtils.money(team.finances?.budgetRemaining ?? team.budget)}',
                      Icons.account_balance_wallet,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFinanceCard(
                      'Valor Plantilla',
                      '\$${NumberFormatUtils.money(totalValue)}',
                      Icons.trending_up,
                      AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.people,
                    '${teamPlayers.length} jugadores',
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  if (team.trophies != null && team.trophies!.isNotEmpty)
                    _buildInfoChip(
                      Icons.emoji_events,
                      '${team.trophies!.length} trofeos',
                      Colors.amber,
                    ),
                ],
              ),
              if (team.stats != null) ...[
                const SizedBox(height: 12),
                _buildStatsRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = team.stats!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('PJ', '${stats.matchesPlayed}'),
        _buildStatItem('G', '${stats.wins}'),
        _buildStatItem('E', '${stats.draws}'),
        _buildStatItem('P', '${stats.losses}'),
        _buildStatItem('GF/GC', '${stats.goalsFor}/${stats.goalsAgainst}'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: AppTheme.captionStyle,
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 2) return Colors.green;
    if (position <= 4) return Colors.blue;
    if (position <= 6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAvatar({required double radius}) {
    final logo = _normalizeLogoUrl(team.logoUrl);
    if (logo != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            logo,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildTeamInitialAvatar(radius),
          ),
        ),
      );
    }

    return _buildTeamInitialAvatar(radius);
  }

  String? _normalizeLogoUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final value = rawUrl.trim();
    if (value.isEmpty) return null;

    // Convert common Google Drive share links to direct-view links.
    final driveMatch = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)').firstMatch(value);
    if (driveMatch != null) {
      final fileId = driveMatch.group(1);
      if (fileId != null && fileId.isNotEmpty) {
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    return value;
  }

  Widget _buildTeamInitialAvatar(double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        team.name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius >= 24 ? 20 : 14,
        ),
      ),
    );
  }

  void _showTeamDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeamDetailsScreen(team: team),
      ),
    );
  }

  Widget _buildSquadTab(List<Player> teamPlayers) {
    return TeamSquadTab(teamPlayers: teamPlayers);
  }

  Widget _buildFinancesTab(List<dynamic> teamPlayers) {
    final squadValue = teamPlayers.fold<double>(
      0,
      (sum, player) => sum + player.price,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Financiera',
            style: AppTheme.titleStyle,
          ),
          const SizedBox(height: 16),
          
          if (team.finances != null) ...[
            _buildFinanceDetailCard(
              'Presupuesto Disponible',
              '\$${NumberFormatUtils.money(team.finances!.budgetRemaining)}',
              Icons.account_balance_wallet,
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Valor de la Plantilla',
              '\$${NumberFormatUtils.money(squadValue)}',
              Icons.trending_up,
              AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Salarios Totales',
              '\$${NumberFormatUtils.money(team.finances!.totalSalaries)}',
              Icons.payment,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Presupuesto de Transfers',
              '\$${NumberFormatUtils.money(team.finances!.transferBudget)}',
              Icons.swap_horiz,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Ingresos por Patrocinio',
              '\$${NumberFormatUtils.money(team.finances!.sponsorshipIncome)}',
              Icons.business,
              Colors.purple,
            ),
          ] else ...[
            const Text('No hay información financiera detallada disponible'),
          ],

          const SizedBox(height: 20),
          
          if (team.trophies != null && team.trophies!.isNotEmpty) ...[
            Text(
              'Trofeos (${team.trophies!.length})',
              style: AppTheme.titleStyle,
            ),
            const SizedBox(height: 8),
            ...team.trophies!.map((trophy) => ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: Text(trophy),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (team.stats != null) ...[
            const Text(
              'Estadísticas Generales',
              style: AppTheme.titleStyle,
            ),
            const SizedBox(height: 16),
            
            _buildStatsCard('Liga Principal', {
              'Posición': '${team.stats!.position ?? '-'}',
              'Puntos': '${team.stats!.points}',
              'Partidos Jugados': '${team.stats!.matchesPlayed}',
              'Ganados': '${team.stats!.wins}',
              'Empatados': '${team.stats!.draws}',
              'Perdidos': '${team.stats!.losses}',
              'Goles a Favor': '${team.stats!.goalsFor}',
              'Goles en Contra': '${team.stats!.goalsAgainst}',
              'Diferencia de Goles': '${team.stats!.goalDifference}',
            }),
            
            if (team.stats!.form != null) ...[
              const SizedBox(height: 16),
              _buildFormSection(team.stats!.form!),
            ],
          ],

          const SizedBox(height: 20),
          
          if (team.competitionStats != null && team.competitionStats!.isNotEmpty) ...[
            Text(
              'Estadísticas por Evento',
              style: AppTheme.titleStyle,
            ),
            const SizedBox(height: 16),
            ...team.competitionStats!.entries.map((entry) => 
              _buildCompetitionStatsCard(entry.key, entry.value)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinanceDetailCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, Map<String, String> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.titleStyle.copyWith(color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),
            ...stats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    entry.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(String form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forma Reciente',
          style: AppTheme.titleStyle,
        ),
        const SizedBox(height: 8),
        Row(
          children: form.split('').map((result) {
            Color color;
            switch (result) {
              case 'W':
                color = Colors.green;
                break;
              case 'D':
                color = Colors.orange;
                break;
              case 'L':
                color = Colors.red;
                break;
              default:
                color = Colors.grey;
            }
            
            return Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Text(
                result,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompetitionStatsCard(String competitionId, dynamic stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCompetitionName(competitionId),
              style: AppTheme.titleStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (stats is Map<String, dynamic>) ...[
              ...stats.entries.where((e) => e.value != null).map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatStatKey(entry.key),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCompetitionName(String competitionId) {
    switch (competitionId) {
      case 'comp_1': return 'Liga Master 2026';
      case 'comp_2': return 'Copa del Rey Master';
      case 'comp_3': return 'Champions League Master';
      case 'comp_4': return 'Supercopa Master';
      case 'comp_5': return 'Evento de Verano';
      case 'comp_6': return 'Copa de Invierno';
      default: return competitionId;
    }
  }

  String _formatStatKey(String key) {
    switch (key) {
      case 'points': return 'Puntos';
      case 'matchesPlayed': return 'PJ';
      case 'wins': return 'G';
      case 'draws': return 'E';
      case 'losses': return 'P';
      case 'goalsFor': return 'GF';
      case 'goalsAgainst': return 'GC';
      case 'position': return 'Posición';
      case 'phase': return 'Fase';
      case 'groupStagePosition': return 'Pos. Grupo';
      default: return key;
    }
  }
}

class TeamDetailsScreen extends StatelessWidget {
  final Team team;

  const TeamDetailsScreen({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final teamPlayers = playerProvider.getPlayersByTeam(team.id);
    final detailDelegate = TeamCard(team: team, playerProvider: playerProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(team.name),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Plantilla'),
              Tab(text: 'Finanzas'),
              Tab(text: 'Estadísticas'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  detailDelegate._buildTeamAvatar(radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.name, style: AppTheme.headlineStyle),
                        Text(team.ownerName, style: AppTheme.subtitleStyle),
                        if (team.homeStadium != null)
                          Text('🏟️ ${team.homeStadium}', style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    detailDelegate._buildSquadTab(teamPlayers),
                    detailDelegate._buildFinancesTab(teamPlayers),
                    detailDelegate._buildStatsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamSquadTab extends StatefulWidget {
  final List<Player> teamPlayers;

  const TeamSquadTab({
    super.key,
    required this.teamPlayers,
  });

  @override
  State<TeamSquadTab> createState() => _TeamSquadTabState();
}

class _TeamSquadTabState extends State<TeamSquadTab> {
  static const Map<String, int> _positionSortOrder = {
    'PT': 1,
    'DEC': 2,
    'LI': 3,
    'LD': 4,
    'MCD': 5,
    'MC': 6,
    'MDI': 7,
    'MDD': 8,
    'MO': 9,
    'EXI': 10,
    'EXD': 11,
    'SD': 12,
    'DC': 13,
  };

  final TextEditingController _searchController = TextEditingController();

  String? _selectedPosition;
  String? _selectedCountry;
  double? _selectedMinPrice;
  double? _selectedMaxPrice;
  String _sortBy = 'name';
  bool _sortAscending = true;

  final List<String> _positions = const [
    'Todas',
    'PT',
    'DEC',
    'LI',
    'LD',
    'MCD',
    'MC',
    'MDI',
    'MDD',
    'MO',
    'EXI',
    'EXD',
    'SD',
    'DC',
  ];

  final List<Map<String, String>> _sortOptions = const [
    {'label': 'Nombre', 'value': 'name'},
    {'label': 'Posicion', 'value': 'position'},
    {'label': 'Precio', 'value': 'price'},
    {'label': 'Media', 'value': 'overall'},
    {'label': 'Edad', 'value': 'age'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = _getFilteredPlayers(widget.teamPlayers);
    final countries = widget.teamPlayers
        .map((p) => p.nationality.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final activeFilters = [
      if (_selectedPosition != null) 'Posición: $_selectedPosition',
      if (_selectedCountry != null) 'País: $_selectedCountry',
      if (_selectedMinPrice != null) 'Min: ${_selectedMinPrice!.toStringAsFixed(0)}',
      if (_selectedMaxPrice != null) 'Max: ${_selectedMaxPrice!.toStringAsFixed(0)}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plantilla (${filteredPlayers.length} jugadores)',
          style: AppTheme.titleStyle,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar jugadores del equipo...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.filter_list),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openFiltersModal(countries),
                icon: const Icon(Icons.tune),
                label: const Text('Filtros'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Limpiar filtros',
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredPlayers.isEmpty
              ? const Center(
                  child: Text('No hay jugadores que coincidan con los filtros'),
                )
              : ListView.builder(
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    final contractPeriod = _buildContractPeriod(
                      player.contractStart,
                      player.contractEnd,
                    );
                    final contractDuration = player.contractDurationFormatted;

                    final subtitle = StringBuffer('${player.club} • OVR ${player.overall}');
                    if (contractPeriod != null || contractDuration != null) {
                      subtitle.write('\nContrato: ${contractPeriod ?? 'Sin fechas'}');
                      if (contractDuration != null) {
                        subtitle.write(' • $contractDuration');
                      }
                    }

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getPositionColor(player.position),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          PositionUtils.normalize(player.position),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(player.name),
                      subtitle: Text(subtitle.toString()),
                      trailing: Text(
                        '\$${NumberFormatUtils.money(player.price)}',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Player> _getFilteredPlayers(List<Player> players) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = players.where((player) {
      final matchesSearch = query.isEmpty ||
          player.name.toLowerCase().contains(query) ||
          player.position.toLowerCase().contains(query) ||
          player.club.toLowerCase().contains(query) ||
          player.nationality.toLowerCase().contains(query);

      final matchesPosition = _selectedPosition == null ||
          PositionUtils.normalize(player.position).toLowerCase() ==
              _selectedPosition!.toLowerCase();

      final matchesCountry = _selectedCountry == null ||
          player.nationality.toLowerCase() == _selectedCountry!.toLowerCase();

      final matchesMinPrice = _selectedMinPrice == null || player.price >= _selectedMinPrice!;
      final matchesMaxPrice = _selectedMaxPrice == null || player.price <= _selectedMaxPrice!;

      return matchesSearch &&
          matchesPosition &&
          matchesCountry &&
          matchesMinPrice &&
          matchesMaxPrice;
    }).toList();

    switch (_sortBy) {
      case 'position':
        filtered.sort((a, b) {
          final posA = _positionOrderForPlayer(a);
          final posB = _positionOrderForPlayer(b);
          if (posA != posB) {
            return _sortAscending ? posA.compareTo(posB) : posB.compareTo(posA);
          }

          final nameCompare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return _sortAscending ? nameCompare : -nameCompare;
        });
        break;
      case 'price':
        filtered.sort((a, b) =>
            _sortAscending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
        break;
      case 'overall':
        filtered.sort((a, b) =>
            _sortAscending ? a.overall.compareTo(b.overall) : b.overall.compareTo(a.overall));
        break;
      case 'age':
        filtered.sort((a, b) => _sortAscending ? a.age.compareTo(b.age) : b.age.compareTo(a.age));
        break;
      case 'name':
      default:
        filtered.sort((a, b) {
          final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return _sortAscending ? cmp : -cmp;
        });
        break;
    }

    return filtered;
  }

  int _positionOrderForPlayer(Player player) {
    final normalized = PositionUtils.normalize(player.position).toUpperCase();
    return _positionSortOrder[normalized] ?? 999;
  }

  Future<void> _openFiltersModal(List<String> countries) async {
    String tempSortBy = _sortBy;
    bool tempSortAscending = _sortAscending;
    String? tempPosition = _selectedPosition;
    String? tempCountry = _selectedCountry;

    final minController = TextEditingController(
      text: _selectedMinPrice != null ? _selectedMinPrice!.toStringAsFixed(0) : '',
    );
    final maxController = TextEditingController(
      text: _selectedMaxPrice != null ? _selectedMaxPrice!.toStringAsFixed(0) : '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtros de jugadores', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempPosition ?? 'Todas',
                      decoration: const InputDecoration(labelText: 'Posición'),
                      items: _positions
                          .map((position) =>
                              DropdownMenuItem(value: position, child: Text(position)))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempPosition = value == 'Todas' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempCountry,
                      decoration: const InputDecoration(labelText: 'País'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...countries.map(
                          (country) => DropdownMenuItem<String>(
                            value: country,
                            child: Text(country),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempCountry = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Precio mín.'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Precio máx.'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempSortBy,
                      decoration: const InputDecoration(labelText: 'Ordenar por'),
                      items: _sortOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            tempSortBy = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: tempSortAscending,
                      title: const Text('Orden ascendente'),
                      onChanged: (value) {
                        setModalState(() {
                          tempSortAscending = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _sortBy = tempSortBy;
                                _sortAscending = tempSortAscending;
                                _selectedPosition = tempPosition;
                                _selectedCountry = tempCountry;
                                _selectedMinPrice =
                                    double.tryParse(minController.text.replaceAll(',', '.'));
                                _selectedMaxPrice =
                                    double.tryParse(maxController.text.replaceAll(',', '.'));
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    minController.dispose();
    maxController.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedPosition = null;
      _selectedCountry = null;
      _selectedMinPrice = null;
      _selectedMaxPrice = null;
      _sortBy = 'name';
      _sortAscending = true;
    });
  }

  String? _buildContractPeriod(String? start, String? end) {
    final startFormatted = _formatDate(start);
    final endFormatted = _formatDate(end);

    if (startFormatted == null && endFormatted == null) return null;
    if (startFormatted != null && endFormatted != null) {
      return '$startFormatted - $endFormatted';
    }
    return startFormatted ?? endFormatted;
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return raw;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    return '$day/$month/$year';
  }
}