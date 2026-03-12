import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/competition.dart';
import '../../models/match_fixture.dart';
import '../../providers/competition_provider.dart';
import '../../providers/team_provider.dart';
import '../../utils/theme.dart';

class CompetitionFixtureScreen extends StatelessWidget {
  final Competition competition;

  const CompetitionFixtureScreen({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixture'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<CompetitionProvider, TeamProvider>(
        builder: (context, competitionProvider, teamProvider, child) {
          final fixtures = competitionProvider.getFixturesByEvent(competition.id);

          if (fixtures.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No hay cruces para este evento',
                      style: AppTheme.titleStyle.copyWith(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final grouped = _groupByMatchday(fixtures);
          final sortedMatchdays = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedMatchdays.length,
            itemBuilder: (context, index) {
              final matchday = sortedMatchdays[index];
              final dayFixtures = grouped[matchday] ?? const <MatchFixture>[];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jornada $matchday',
                        style: AppTheme.titleStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...dayFixtures.map(
                        (fixture) => _FixtureRow(
                          fixture: fixture,
                          homeTeamName: _teamName(teamProvider, fixture.homeTeamId),
                          awayTeamName: _teamName(teamProvider, fixture.awayTeamId),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<int, List<MatchFixture>> _groupByMatchday(List<MatchFixture> fixtures) {
    final grouped = <int, List<MatchFixture>>{};
    for (final fixture in fixtures) {
      grouped.putIfAbsent(fixture.matchday, () => <MatchFixture>[]).add(fixture);
    }
    return grouped;
  }

  String _teamName(TeamProvider teamProvider, String teamId) {
    final team = teamProvider.getTeamById(teamId);
    return team?.name ?? teamId;
  }
}

class _FixtureRow extends StatelessWidget {
  final MatchFixture fixture;
  final String homeTeamName;
  final String awayTeamName;

  const _FixtureRow({
    required this.fixture,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final scoreText = fixture.isPlayed
        ? '${fixture.homeGoals} - ${fixture.awayGoals}'
        : 'vs';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  homeTeamName,
                  style: AppTheme.bodyStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scoreText,
                  style: AppTheme.subtitleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  awayTeamName,
                  style: AppTheme.bodyStyle,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                DateFormat('dd/MM/yyyy').format(fixture.kickoffDate),
                style: AppTheme.captionStyle,
              ),
              const SizedBox(width: 12),
              Icon(Icons.flag, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                fixture.status.isEmpty ? 'sin estado' : fixture.status,
                style: AppTheme.captionStyle,
              ),
            ],
          ),
          if (fixture.venue != null || fixture.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              [fixture.venue, fixture.notes].whereType<String>().join(' | '),
              style: AppTheme.captionStyle,
            ),
          ],
        ],
      ),
    );
  }
}
