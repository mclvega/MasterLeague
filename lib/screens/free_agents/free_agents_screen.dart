import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/player_card.dart';

class FreeAgentsScreen extends StatelessWidget {
  const FreeAgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final freeAgents = playerProvider.freeAgents;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_add_disabled,
                    color: AppTheme.warningColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Jugadores Libres',
                    style: AppTheme.headlineStyle,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.warningColor),
                    ),
                    child: Text(
                      freeAgents.length.toString(),
                      style: const TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildFreeAgentsList(freeAgents),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFreeAgentsList(List players) {
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay jugadores libres',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Todos los jugadores están asignados a equipos',
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
      itemCount: players.length,
      itemBuilder: (context, index) {
        return PlayerCard(player: players[index]);
      },
    );
  }
}