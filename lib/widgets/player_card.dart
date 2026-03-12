import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/team_provider.dart';
import '../utils/number_format_utils.dart';
import '../utils/position_utils.dart';
import '../utils/theme.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final team = player.teamId != null 
            ? teamProvider.getTeamById(player.teamId!)
            : null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () => _showPlayerDetails(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPositionChip(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: AppTheme.titleStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${player.club} • ${player.nationality}',
                              style: AppTheme.subtitleStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${NumberFormatUtils.money(player.price)}',
                            style: AppTheme.titleStyle.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Media ${player.overall}',
                            style: AppTheme.captionStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${player.age} años',
                        style: AppTheme.captionStyle,
                      ),
                      const Spacer(),
                      if (team != null) ...[
                        const Icon(
                          Icons.group,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          team.name,
                          style: AppTheme.captionStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.warningColor),
                          ),
                          child: Text(
                            'LIBRE',
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionChip() {
    final color = AppTheme.getPositionColor(player.position);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        PositionUtils.normalize(player.position),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPlayerDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerDetailsScreen(player: player),
      ),
    );
  }
}

class PlayerDetailsScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailsScreen({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Jugador'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getPositionColor(player.position),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  PositionUtils.normalize(player.position),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                player.name,
                style: AppTheme.headlineStyle,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Club', player.club),
              _buildDetailRow('Nacionalidad', player.nationality),
              _buildDetailRow('Edad', '${player.age} años'),
              _buildDetailRow('Media', player.overall.toString()),
              _buildDetailRow('Precio', '\$${NumberFormatUtils.money(player.price)}'),
              const SizedBox(height: 20),
              Consumer<TeamProvider>(
                builder: (context, teamProvider, child) {
                  final team = player.teamId != null
                      ? teamProvider.getTeamById(player.teamId!)
                      : null;

                  if (team != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Equipo Actual',
                            style: AppTheme.titleStyle.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            team.name,
                            style: AppTheme.bodyStyle,
                          ),
                          Text(
                            'Propietario: ${team.ownerName}',
                            style: AppTheme.captionStyle,
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warningColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_add_disabled,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Jugador Libre',
                          style: AppTheme.titleStyle.copyWith(
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label:',
              style: AppTheme.subtitleStyle,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

}