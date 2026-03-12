import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/competition_provider.dart';
import '../../providers/team_provider.dart';
import '../../models/competition.dart';
import '../../models/team.dart';
import '../../utils/number_format_utils.dart';
import '../../utils/theme.dart';
import 'package:intl/intl.dart';

class CompetitionsScreen extends StatelessWidget {
  final int initialTabIndex;

  const CompetitionsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, competitionProvider, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppTheme.accentColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Eventos',
                    style: AppTheme.headlineStyle,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentColor),
                    ),
                    child: Text(
                      competitionProvider.competitions.length.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildCompetitionTabs(competitionProvider),
          ],
        );
      },
    );
  }

  Widget _buildCompetitionTabs(CompetitionProvider competitionProvider) {
    final safeInitialTabIndex = initialTabIndex < 0
        ? 0
        : (initialTabIndex > 3 ? 3 : initialTabIndex);

    return Expanded(
      child: DefaultTabController(
        initialIndex: safeInitialTabIndex,
        length: 4,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: 'Todas'),
                Tab(text: 'Activas'),
                Tab(text: 'Próximas'),
                Tab(text: 'Finalizadas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCompetitionsList(competitionProvider.competitions),
                  _buildCompetitionsList(competitionProvider.ongoingCompetitions),
                  _buildCompetitionsList(competitionProvider.upcomingCompetitions),
                  _buildCompetitionsList(competitionProvider.completedCompetitions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitionsList(List<Competition> competitions) {
    if (competitions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay eventos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los eventos aparecerán aquí',
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
      itemCount: competitions.length,
      itemBuilder: (context, index) {
        return CompetitionCard(competition: competitions[index]);
      },
    );
  }
}

class CompetitionCard extends StatelessWidget {
  final Competition competition;

  const CompetitionCard({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showCompetitionDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeChip(),
                  const SizedBox(width: 8),
                  _buildStatusChip(),
                  const Spacer(),
                  Text(
                    '\$${NumberFormatUtils.money(competition.prizePool)}',
                    style: AppTheme.titleStyle.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                competition.name,
                style: AppTheme.titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
              if (competition.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  competition.description!,
                  style: AppTheme.subtitleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(competition.startDate),
                    style: AppTheme.captionStyle,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.group, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${competition.participantCount} equipos',
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    Color color;
    String label;
    
    switch (competition.type) {
      case CompetitionType.league:
        color = AppTheme.primaryColor;
        label = 'Liga';
        break;
      case CompetitionType.cup:
        color = AppTheme.accentColor;
        label = 'Copa';
        break;
      case CompetitionType.tournament:
        color = AppTheme.secondaryColor;
        label = 'Evento';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    IconData icon;
    
    switch (competition.status) {
      case CompetitionStatus.upcoming:
        color = AppTheme.infoColor;
        label = 'Próxima';
        icon = Icons.schedule;
        break;
      case CompetitionStatus.ongoing:
        color = AppTheme.successColor;
        label = 'En curso';
        icon = Icons.play_circle;
        break;
      case CompetitionStatus.completed:
        color = Colors.grey;
        label = 'Finalizada';
        icon = Icons.check_circle;
        break;
    }

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
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompetitionDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompetitionDetailsScreen(competition: competition),
      ),
    );
  }
}

class CompetitionDetailsScreen extends StatelessWidget {
  final Competition competition;

  const CompetitionDetailsScreen({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Evento'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppTheme.accentColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      competition.name,
                      style: AppTheme.headlineStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (competition.description != null) ...[
                Text(
                  competition.description!,
                  style: AppTheme.bodyStyle,
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showEventDetailsModal(context),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Detalle del evento'),
                  ),
                ],
              ),
              if (_shouldShowStandings()) ...[
                const SizedBox(height: 16),
                Text(
                  'Tabla de Posiciones',
                  style: AppTheme.titleStyle,
                ),
                const SizedBox(height: 8),
                _buildStandingsTable(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetailsModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalle del Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Tipo de evento', _getTypeLabel()),
                _buildDetailRow('Estado', _getStatusLabel()),
                _buildDetailRow('Fecha de inicio', DateFormat('dd/MM/yyyy').format(competition.startDate)),
                if (competition.endDate != null)
                  _buildDetailRow('Fecha de fin', DateFormat('dd/MM/yyyy').format(competition.endDate!)),
                _buildDetailRow('Premio', '\$${NumberFormatUtils.money(competition.prizePool)}'),
                _buildDetailRow('Participantes', '${competition.participantCount} equipos'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTheme.subtitleStyle,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTable(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final teams = _resolveStandingsTeams(teamProvider.teams);

        if (teams.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('No hay datos suficientes para mostrar la tabla.'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Pos')),
              DataColumn(label: Text('Equipo')),
              DataColumn(label: Text('PJ')),
              DataColumn(label: Text('PTS')),
              DataColumn(label: Text('DG')),
            ],
            rows: List<DataRow>.generate(teams.length, (index) {
              final team = teams[index];
              final position = _getTeamPosition(team) ?? (index + 1);
              final played = _getTeamStat(team, 'matchesPlayed', fallback: team.stats?.matchesPlayed ?? 0);
              final points = _getTeamStat(team, 'points', fallback: team.stats?.points ?? 0);
              final goalDiff = _getTeamStat(team, 'goalDifference', fallback: team.stats?.goalDifference ?? 0);

              return DataRow(
                cells: [
                  DataCell(Text(position.toString())),
                  DataCell(SizedBox(width: 140, child: Text(team.name, overflow: TextOverflow.ellipsis))),
                  DataCell(Text('$played')),
                  DataCell(Text('$points')),
                  DataCell(Text('$goalDiff')),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  List<Team> _resolveStandingsTeams(List<Team> allTeams) {
    final participantIds = competition.participantTeamIds.toSet();
    final participants = participantIds.isEmpty
        ? allTeams.where((t) => _getCompetitionStats(t) != null || t.stats != null).toList()
        : allTeams.where((t) => participantIds.contains(t.id)).toList();

    participants.sort((a, b) {
      final ap = _getTeamStat(a, 'points', fallback: a.stats?.points ?? 0);
      final bp = _getTeamStat(b, 'points', fallback: b.stats?.points ?? 0);
      if (bp != ap) return bp.compareTo(ap);
      final ad = _getTeamStat(a, 'goalDifference', fallback: a.stats?.goalDifference ?? 0);
      final bd = _getTeamStat(b, 'goalDifference', fallback: b.stats?.goalDifference ?? 0);
      if (bd != ad) return bd.compareTo(ad);
      return a.name.compareTo(b.name);
    });

    return participants;
  }

  Map<String, dynamic>? _getCompetitionStats(Team team) {
    final source = team.competitionStats;
    if (source == null || source.isEmpty) return null;

    final byId = source[competition.id];
    if (byId is Map<String, dynamic>) return byId;

    final byName = source[competition.name];
    if (byName is Map<String, dynamic>) return byName;

    final byIdLower = source[competition.id.toLowerCase()];
    if (byIdLower is Map<String, dynamic>) return byIdLower;

    final byNameLower = source[competition.name.toLowerCase()];
    if (byNameLower is Map<String, dynamic>) return byNameLower;

    return null;
  }

  int _getTeamStat(Team team, String key, {required int fallback}) {
    final stats = _getCompetitionStats(team);
    if (stats == null) return fallback;

    final aliases = _statAliases(key);
    for (final alias in aliases) {
      if (stats.containsKey(alias)) {
        return _dynamicToInt(stats[alias], fallback: fallback);
      }
    }
    return fallback;
  }

  int? _getTeamPosition(Team team) {
    final stats = _getCompetitionStats(team);
    if (stats != null) {
      for (final alias in const ['position', 'posicion', 'puesto', 'ranking']) {
        if (stats.containsKey(alias)) {
          return _dynamicToInt(stats[alias], fallback: team.stats?.position ?? 0);
        }
      }
    }

    final fallback = team.stats?.position;
    return fallback == null || fallback <= 0 ? null : fallback;
  }

  List<String> _statAliases(String key) {
    switch (key) {
      case 'matchesPlayed':
        return const ['matchesPlayed', 'pj', 'partidosJugados', 'partidos_jugados'];
      case 'points':
        return const ['points', 'puntos', 'pts'];
      case 'goalDifference':
        return const ['goalDifference', 'dg', 'diferenciaDeGoles', 'diferencia_goles'];
      default:
        return [key];
    }
  }

  int _dynamicToInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? fallback;
  }

  String _getTypeLabel() {
    switch (competition.type) {
      case CompetitionType.league:
        return 'Liga';
      case CompetitionType.cup:
        return 'Copa';
      case CompetitionType.tournament:
        return 'Evento';
    }
  }

  String _getStatusLabel() {
    switch (competition.status) {
      case CompetitionStatus.upcoming:
        return 'Próxima';
      case CompetitionStatus.ongoing:
        return 'En curso';
      case CompetitionStatus.completed:
        return 'Finalizada';
    }
  }

  bool _shouldShowStandings() {
    final rules = competition.rules;
    if (rules != null && rules.containsKey('hasStandings')) {
      final value = rules['hasStandings'];
      if (value is bool) return value;
      if (value is num) return value != 0;
      final parsed = value.toString().trim().toLowerCase();
      return parsed == 'true' || parsed == '1' || parsed == 'si' || parsed == 'sí' || parsed == 'yes';
    }

    // Default behavior if option is not provided.
    return competition.type == CompetitionType.league;
  }

}