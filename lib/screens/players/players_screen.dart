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
  String? _selectedCountry;
  double? _selectedMinPrice;
  double? _selectedMaxPrice;
  String _sortBy = 'name';
  bool _sortAscending = true;

  final List<String> _positions = [
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

  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Nombre', 'value': 'name'},
    {'label': 'Precio', 'value': 'price'},
    {'label': 'Media', 'value': 'overall'},
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
    final countries = playerProvider.players
        .map((p) => p.nationality.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final activeFilters = [
      if (_selectedPosition != null) 'Posición: $_selectedPosition',
      if (_selectedTeamId != null)
        'Equipo: ${teamProvider.getTeamById(_selectedTeamId!)?.name ?? _selectedTeamId}',
      if (_selectedCountry != null) 'País: $_selectedCountry',
      if (_selectedMinPrice != null) 'Min: ${_selectedMinPrice!.toStringAsFixed(0)}',
      if (_selectedMaxPrice != null) 'Max: ${_selectedMaxPrice!.toStringAsFixed(0)}',
    ];

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
                child: OutlinedButton.icon(
                  onPressed: () => _openFiltersModal(playerProvider, teamProvider, countries),
                  icon: const Icon(Icons.tune),
                  label: Text(
                    activeFilters.isEmpty ? 'Filtros' : 'Filtros (${activeFilters.length})',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Limpiar filtros',
                onPressed: () {
                  setState(() {
                    _selectedPosition = null;
                    _selectedTeamId = null;
                    _selectedCountry = null;
                    _selectedMinPrice = null;
                    _selectedMaxPrice = null;
                    _sortBy = 'name';
                    _sortAscending = true;
                  });
                  playerProvider.filterByPosition(null);
                  playerProvider.filterByTeam(null);
                  playerProvider.filterByCountry(null);
                  playerProvider.filterByPriceRange(null, null);
                  playerProvider.sortPlayers(_sortBy, ascending: _sortAscending);
                },
                icon: const Icon(Icons.filter_alt_off),
              ),
            ],
          ),
          if (activeFilters.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: activeFilters
                    .map((f) => Chip(label: Text(f, style: const TextStyle(fontSize: 12))))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openFiltersModal(
    PlayerProvider playerProvider,
    TeamProvider teamProvider,
    List<String> countries,
  ) async {
    String tempSortBy = _sortBy;
    bool tempSortAscending = _sortAscending;
    String? tempPosition = _selectedPosition;
    String? tempTeamId = _selectedTeamId;
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
                          .map((position) => DropdownMenuItem(value: position, child: Text(position)))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempPosition = value == 'Todas' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tempTeamId ?? 'Todos',
                      decoration: const InputDecoration(labelText: 'Equipo'),
                      items: [
                        const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                        ...teamProvider.teams
                            .map((team) => DropdownMenuItem(value: team.id, child: Text(team.name))),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempTeamId = value == 'Todos' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tempCountry ?? 'Todos',
                      decoration: const InputDecoration(labelText: 'País'),
                      items: [
                        const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                        ...countries.map((country) => DropdownMenuItem(value: country, child: Text(country))),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempCountry = value == 'Todos' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Precio mínimo'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Precio máximo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tempSortBy,
                            decoration: const InputDecoration(labelText: 'Ordenar por'),
                            items: _sortOptions
                              .map((option) => DropdownMenuItem<String>(
                                      value: option['value'],
                                      child: Text(option['label']),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setModalState(() {
                                  tempSortBy = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(tempSortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                          onPressed: () {
                            setModalState(() {
                              tempSortAscending = !tempSortAscending;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final parsedMin = double.tryParse(minController.text.trim());
                              final parsedMax = double.tryParse(maxController.text.trim());

                              setState(() {
                                _selectedPosition = tempPosition;
                                _selectedTeamId = tempTeamId;
                                _selectedCountry = tempCountry;
                                _selectedMinPrice = parsedMin;
                                _selectedMaxPrice = parsedMax;
                                _sortBy = tempSortBy;
                                _sortAscending = tempSortAscending;
                              });

                              playerProvider.filterByPosition(_selectedPosition);
                              playerProvider.filterByTeam(_selectedTeamId);
                              playerProvider.filterByCountry(_selectedCountry);
                              playerProvider.filterByPriceRange(_selectedMinPrice, _selectedMaxPrice);
                              playerProvider.sortPlayers(_sortBy, ascending: _sortAscending);

                              Navigator.of(context).pop();
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
}