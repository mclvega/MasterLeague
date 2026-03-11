import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/player_card.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPosition;
  String _sortBy = 'name';
  bool _sortAscending = true;

  final List<String> _positions = [
    'Todas',
    'GK',
    'DEF',
    'MID',
    'FW',
    'ATT',
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Nombre', 'value': 'name'},
    {'label': 'Precio', 'value': 'price'},
    {'label': 'Overall', 'value': 'overall'},
    {'label': 'Edad', 'value': 'age'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return Column(
            children: [
              _buildSearchAndFilters(playerProvider),
              _buildPlayerStats(playerProvider),
              Expanded(
                child: _buildPlayerList(playerProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(PlayerProvider playerProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar jugadores...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.filter_list),
            ),
            onChanged: (value) {
              playerProvider.searchPlayers(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPosition ?? 'Todas',
                  decoration: const InputDecoration(
                    labelText: 'Posición',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _positions.map((position) {
                    return DropdownMenuItem<String>(
                      value: position,
                      child: Text(position),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value == 'Todas' ? null : value;
                    });
                    playerProvider.filterByPosition(_selectedPosition);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Ordenar por',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                      playerProvider.sortPlayers(value, ascending: _sortAscending);
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  playerProvider.sortPlayers(_sortBy, ascending: _sortAscending);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(PlayerProvider playerProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip(
            'Total',
            playerProvider.players.length.toString(),
            AppTheme.primaryColor,
          ),
          _buildStatChip(
            'Mostrando',
            playerProvider.filteredPlayers.length.toString(),
            AppTheme.secondaryColor,
          ),
          _buildStatChip(
            'Libres',
            playerProvider.freeAgents.length.toString(),
            AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            value,
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

  Widget _buildPlayerList(PlayerProvider playerProvider) {
    if (playerProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (playerProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              playerProvider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                playerProvider.setError(null);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final players = playerProvider.filteredPlayers;

    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay jugadores disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Importa un archivo para comenzar',
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

  void _clearFilters(PlayerProvider playerProvider) {
    setState(() {
      _selectedPosition = null;
      _sortBy = 'name';
      _sortAscending = true;
    });
    _searchController.clear();
    playerProvider.searchPlayers('');
    playerProvider.filterByPosition(null);
    playerProvider.sortPlayers('name', ascending: true);
  }
}