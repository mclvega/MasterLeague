import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/team_provider.dart';
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
  String? _selectedClub;
  String? _selectedCountry;
  bool? _selectedIsFree;
  double? _selectedMinPrice;
  double? _selectedMaxPrice;
  int? _selectedMinOverall;
  int? _selectedMaxOverall;
  String? _selectedPlayerStyle;
  String _sortBy = 'name';
  bool _sortAscending = true;

  final List<Map<String, dynamic>> _freeStatusOptions = const [
    {'label': 'Todos', 'value': null},
    {'label': 'Agentes libres', 'value': true},
    {'label': 'Con equipo', 'value': false},
  ];

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

  final List<String> _playerStyles = [
    'Todos',
    'Cazagoles',
    'Señuelo',
    'Hombre de área',
    'Extremo prolífico',
    'Clásico No. 10',
    'Jugador de huecos',
    'De área a área',
    'El protector',
    'El destructor',
    'Atacante extra',
    'Lateral ofensivo',
    'Lateral defensivo',
    'Enganche',
    'Creador de juego',
    'Creación',
    'Portero ofensivo',
    'Portero defensivo',
    'Ala móvil',
    'Especialista en centros',
    'Organizador',
    'Lateral finalizador',
    'Proteger el balón',
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Nombre', 'value': 'name'},
    {'label': 'Posicion', 'value': 'position'},
    {'label': 'Precio', 'value': 'price'},
    {'label': 'Media', 'value': 'overall'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset all filters every time the widget is inserted into the tree (e.g., tab navigation)
    _resetFilters();
  }

  void _resetFilters() {
    setState(() {
      _selectedPosition = null;
      _selectedTeamId = null;
      _selectedClub = null;
      _selectedCountry = null;
      _selectedPlayerStyle = null;
      _selectedIsFree = null;
      _selectedMinPrice = null;
      _selectedMaxPrice = null;
      _selectedMinOverall = null;
      _selectedMaxOverall = null;
      _sortBy = 'name';
      _sortAscending = true;
      _searchController.text = '';
    });
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.setFilters(
      position: null,
      teamId: null,
      club: null,
      country: null,
      playerStyle: null,
      isFree: null,
      minPrice: null,
      maxPrice: null,
      minOverall: null,
      maxOverall: null,
    );
    playerProvider.sortPlayers('name', ascending: true);
    playerProvider.searchPlayers('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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

  Widget _buildSearchAndFilters(
      PlayerProvider playerProvider, TeamProvider teamProvider) {
    final clubs = playerProvider.clubs;
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
      if (_selectedClub != null) 'Club: $_selectedClub',
      if (_selectedCountry != null) 'País: $_selectedCountry',
      if (_selectedPlayerStyle != null) 'Estilo: $_selectedPlayerStyle',
      if (_selectedIsFree != null)
        _selectedIsFree! ? 'Estado: Agente libre' : 'Estado: Con equipo',
      if (_selectedMinPrice != null)
        'Min precio: ${_selectedMinPrice!.toStringAsFixed(0)}',
      if (_selectedMaxPrice != null)
        'Max precio: ${_selectedMaxPrice!.toStringAsFixed(0)}',
      if (_selectedMinOverall != null) 'Min media: $_selectedMinOverall',
      if (_selectedMaxOverall != null) 'Max media: $_selectedMaxOverall',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar jugadores...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: const Icon(Icons.filter_list, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white70),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  onPressed: () => _openFiltersModal(
                      playerProvider, teamProvider, clubs, countries),
                  icon: const Icon(Icons.tune),
                  label: Text(
                    activeFilters.isEmpty
                        ? 'Filtros'
                        : 'Filtros (${activeFilters.length})',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Limpiar filtros',
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedPosition = null;
                    _selectedTeamId = null;
                    _selectedClub = null;
                    _selectedCountry = null;
                    _selectedIsFree = null;
                    _selectedMinPrice = null;
                    _selectedMaxPrice = null;
                    _sortBy = 'name';
                    _sortAscending = true;
                  });
                  playerProvider.filterByPosition(null);
                  playerProvider.filterByTeam(null);
                  playerProvider.filterByClub(null);
                  playerProvider.filterByCountry(null);
                  playerProvider.filterByFreeStatus(null);
                  playerProvider.filterByPriceRange(null, null);
                  playerProvider.sortPlayers(_sortBy,
                      ascending: _sortAscending);
                },
                icon: const Icon(Icons.filter_alt_off),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openFiltersModal(
    PlayerProvider playerProvider,
    TeamProvider teamProvider,
    List<String> clubs,
    List<String> countries,
  ) async {
    String tempSortBy = _sortBy;
    bool tempSortAscending = _sortAscending;
    String? tempPosition = _selectedPosition;
    String? tempTeamId = _selectedTeamId;
    String? tempClub = _selectedClub;
    String? tempCountry = _selectedCountry;
    String? tempPlayerStyle = _selectedPlayerStyle;
    bool? tempIsFree = _selectedIsFree;
    final minController = TextEditingController(
      text: _selectedMinPrice != null
          ? _selectedMinPrice!.toStringAsFixed(0)
          : '',
    );
    final maxController = TextEditingController(
      text: _selectedMaxPrice != null
          ? _selectedMaxPrice!.toStringAsFixed(0)
          : '',
    );
    final minOverallController = TextEditingController(
      text: _selectedMinOverall != null ? _selectedMinOverall.toString() : '',
    );
    final maxOverallController = TextEditingController(
      text: _selectedMaxOverall != null ? _selectedMaxOverall.toString() : '',
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
                    Text('Filtros de jugadores',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempPosition ?? 'Todas',
                      decoration: const InputDecoration(labelText: 'Posición'),
                      items: _positions
                          .map((position) => DropdownMenuItem(
                              value: position, child: Text(position)))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempPosition = value == 'Todas' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minOverallController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Media mínima'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: maxOverallController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Media máxima'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tempTeamId ?? 'Todos',
                      decoration: const InputDecoration(labelText: 'Equipo'),
                      items: [
                        const DropdownMenuItem(
                            value: 'Todos', child: Text('Todos')),
                        ...teamProvider.teams.map((team) => DropdownMenuItem(
                            value: team.id, child: Text(team.name))),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempTeamId = value == 'Todos' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tempClub ?? 'Todos',
                      decoration: const InputDecoration(labelText: 'Club'),
                      items: [
                        const DropdownMenuItem(
                            value: 'Todos', child: Text('Todos')),
                        ...clubs.map((club) =>
                            DropdownMenuItem(value: club, child: Text(club))),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempClub = value == 'Todos' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tempCountry ?? 'Todos',
                      decoration: const InputDecoration(labelText: 'País'),
                      items: [
                        const DropdownMenuItem(
                            value: 'Todos', child: Text('Todos')),
                        ...countries.map((country) => DropdownMenuItem(
                            value: country, child: Text(country))),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          tempCountry = value == 'Todos' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tempPlayerStyle ?? 'Todos',
                      decoration:
                          const InputDecoration(labelText: 'Estilo de juego'),
                      items: _playerStyles
                          .map((style) => DropdownMenuItem(
                              value: style, child: Text(style)))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempPlayerStyle = value == 'Todos' ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<bool?>(
                      value: tempIsFree,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _freeStatusOptions
                          .map(
                            (option) => DropdownMenuItem<bool?>(
                              value: option['value'] as bool?,
                              child: Text(option['label'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          tempIsFree = value;
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
                            decoration: const InputDecoration(
                                labelText: 'Precio mínimo'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Precio máximo'),
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
                            decoration:
                                const InputDecoration(labelText: 'Ordenar por'),
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
                          icon: Icon(tempSortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
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
                              final parsedMin =
                                  double.tryParse(minController.text.trim());
                              final parsedMax =
                                  double.tryParse(maxController.text.trim());

                              final parsedMinOverall = int.tryParse(
                                  minOverallController.text.trim());
                              final parsedMaxOverall = int.tryParse(
                                  maxOverallController.text.trim());

                              setState(() {
                                _selectedPosition = tempPosition;
                                _selectedTeamId = tempTeamId;
                                _selectedClub = tempClub;
                                _selectedCountry = tempCountry;
                                _selectedPlayerStyle = tempPlayerStyle;
                                _selectedIsFree = tempIsFree;
                                _selectedMinPrice = parsedMin;
                                _selectedMaxPrice = parsedMax;
                                _selectedMinOverall = parsedMinOverall;
                                _selectedMaxOverall = parsedMaxOverall;
                                _sortBy = tempSortBy;
                                _sortAscending = tempSortAscending;
                              });

                              playerProvider.setFilters(
                                position: _selectedPosition,
                                teamId: _selectedTeamId,
                                club: _selectedClub,
                                country: _selectedCountry,
                                playerStyle: _selectedPlayerStyle,
                                isFree: _selectedIsFree,
                                minPrice: _selectedMinPrice,
                                maxPrice: _selectedMaxPrice,
                                minOverall: _selectedMinOverall,
                                maxOverall: _selectedMaxOverall,
                              );
                              playerProvider.sortPlayers(_sortBy,
                                  ascending: _sortAscending);

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
