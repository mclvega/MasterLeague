import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/settings_provider.dart';
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
  String? _selectedTeamId;
  String _sortBy = 'name';
  bool _sortAscending = true;

  final List<String> _positions = [
    'Todas',
    'PT',
    'CT',
    'LI',
    'LD',
    'MCD',
    'MC',
    'II',
    'ID',
    'MP',
    'EI',
    'ED',
    'SD',
    'DC',
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Nombre', 'value': 'name'},
    {'label': 'Precio', 'value': 'price'},
    {'label': 'Overall', 'value': 'overall'},
    {'label': 'Edad', 'value': 'age'},
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.defaultTeamId != null && settingsProvider.defaultTeamId!.isNotEmpty) {
        setState(() {
          _selectedTeamId = settingsProvider.defaultTeamId;
        });
        context.read<PlayerProvider>().filterByTeam(_selectedTeamId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<PlayerProvider, TeamProvider>(
        builder: (context, playerProvider, teamProvider, child) {
          return Column(
            children: [
              _buildSearchAndFilters(playerProvider, teamProvider),
              Expanded(
                child: _buildPlayerList(playerProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(PlayerProvider playerProvider, TeamProvider teamProvider) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 900;

              final positionFilter = DropdownButtonFormField<String>(
                value: _selectedPosition ?? 'Todas',
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
                  playerProvider.sortPlayers(_sortBy, ascending: _sortAscending);
                },
              );

              final teamFilter = DropdownButtonFormField<String>(
                value: _selectedTeamId ?? 'Todos',
                decoration: const InputDecoration(
                  labelText: 'Equipo',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'Todos',
                    child: Text('Todos'),
                  ),
                  ...teamProvider.teams.map((team) {
                    return DropdownMenuItem<String>(
                      value: team.id,
                      child: Text(team.name, overflow: TextOverflow.ellipsis),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTeamId = value == 'Todos' ? null : value;
                  });
                  playerProvider.filterByTeam(_selectedTeamId);
                  playerProvider.sortPlayers(_sortBy, ascending: _sortAscending);
                },
              );

              final sortFilter = DropdownButtonFormField<String>(
                value: _sortBy,
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
              );

              final sortDirection = IconButton(
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
              );

              if (isCompact) {
                return Column(
                  children: [
                    positionFilter,
                    const SizedBox(height: 10),
                    teamFilter,
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: sortFilter),
                        const SizedBox(width: 8),
                        sortDirection,
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: positionFilter),
                  const SizedBox(width: 12),
                  Expanded(child: teamFilter),
                  const SizedBox(width: 12),
                  Expanded(child: sortFilter),
                  sortDirection,
                ],
              );
            },
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
            Icon(
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
}