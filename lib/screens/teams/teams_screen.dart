import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/team.dart';
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
                  Icon(
                    Icons.group,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Equipos',
                    style: AppTheme.headlineStyle,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      teamProvider.teams.length.toString(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
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
    final totalValue = team.teamValue ?? teamPlayers.fold<double>(
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
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      team.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      '\$${_formatPrice(team.finances?.budgetRemaining ?? team.budget)}',
                      Icons.account_balance_wallet,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFinanceCard(
                      'Valor Plantilla',
                      '\$${_formatPrice(totalValue)}',
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
                  if (team.formation != null)
                    _buildInfoChip(
                      Icons.grid_3x3,
                      team.formation!,
                      AppTheme.secondaryColor,
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

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }

  void _showTeamDetails(BuildContext context) {
    final teamPlayers = playerProvider.getPlayersByTeam(team.id);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
          child: DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del equipo
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 24,
                      child: Text(
                        team.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: AppTheme.headlineStyle,
                          ),
                          Text(
                            team.ownerName,
                            style: AppTheme.subtitleStyle,
                          ),
                          if (team.homeStadium != null)
                            Text(
                              '🏟️ ${team.homeStadium}',
                              style: AppTheme.captionStyle,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tabs
                const TabBar(
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: [
                    Tab(text: 'Plantilla'),
                    Tab(text: 'Finanzas'),
                    Tab(text: 'Estadísticas'),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab views
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Plantilla
                      _buildSquadTab(teamPlayers),

                      // Tab 2: Finanzas
                      _buildFinancesTab(),

                      // Tab 3: Estadísticas
                      _buildStatsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquadTab(List<dynamic> teamPlayers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Plantilla (${teamPlayers.length} jugadores)',
              style: AppTheme.titleStyle,
            ),
            if (team.formation != null)
              Text(
                team.formation!,
                style: AppTheme.titleStyle.copyWith(color: AppTheme.primaryColor),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: teamPlayers.isEmpty
              ? const Center(
                  child: Text('No hay jugadores en este equipo'),
                )
              : ListView.builder(
                  itemCount: teamPlayers.length,
                  itemBuilder: (context, index) {
                    final player = teamPlayers[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getPositionColor(player.position),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          player.position,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(player.name),
                      subtitle: Text('${player.club} • OVR ${player.overall}'),
                      trailing: Text(
                        '\$${_formatPrice(player.price)}',
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

  Widget _buildFinancesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Financiera',
            style: AppTheme.titleStyle,
          ),
          const SizedBox(height: 16),
          
          if (team.finances != null) ...[
            _buildFinanceDetailCard(
              'Presupuesto Disponible',
              '\$${_formatPrice(team.finances!.budgetRemaining)}',
              Icons.account_balance_wallet,
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Valor de la Plantilla',
              '\$${_formatPrice(team.finances!.squadValue)}',
              Icons.trending_up,
              AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Salarios Totales',
              '\$${_formatPrice(team.finances!.totalSalaries)}',
              Icons.payment,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Presupuesto de Transfers',
              '\$${_formatPrice(team.finances!.transferBudget)}',
              Icons.swap_horiz,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildFinanceDetailCard(
              'Ingresos por Patrocinio',
              '\$${_formatPrice(team.finances!.sponsorshipIncome)}',
              Icons.business,
              Colors.purple,
            ),
          ] else ...[
            Text('No hay información financiera detallada disponible'),
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
            Text(
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
              'Estadísticas por Competición',
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
        Text(
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
      case 'comp_5': return 'Torneo de Verano';
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