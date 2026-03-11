import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/team_provider.dart';
import '../providers/settings_provider.dart';

class TeamSelectorWidget extends StatefulWidget {
  final String? title;
  final bool showDefaultTeamOption;
  final Function(Team?)? onTeamSelected;
  final Team? initialSelectedTeam;
  final bool compactMode;

  const TeamSelectorWidget({
    Key? key,
    this.title,
    this.showDefaultTeamOption = true,
    this.onTeamSelected,
    this.initialSelectedTeam,
    this.compactMode = false,
  }) : super(key: key);

  @override
  State<TeamSelectorWidget> createState() => _TeamSelectorWidgetState();
}

class _TeamSelectorWidgetState extends State<TeamSelectorWidget> {
  Team? _selectedTeam;
  String _searchQuery = '';
  bool _showOnlyAvailableTeams = false;

  @override
  void initState() {
    super.initState();
    _selectedTeam = widget.initialSelectedTeam;
    
    // Defer the initial data loading to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    // Si no hay equipo inicial y hay un equipo por defecto, usarlo
    if (mounted && _selectedTeam == null && settingsProvider.hasDefaultTeam) {
      final defaultTeamId = settingsProvider.defaultTeamId;
      if (defaultTeamId != null) {
        final defaultTeam = teamProvider.getTeamById(defaultTeamId);
        if (defaultTeam != null && mounted) {
          setState(() {
            _selectedTeam = defaultTeam;
          });
          widget.onTeamSelected?.call(defaultTeam);
        }
      }
    }
  }

  List<Team> _filterTeams(List<Team> teams) {
    List<Team> filtered = teams;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((team) {
        return team.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            team.ownerName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar solo equipos disponibles (con presupuesto > 0)
    if (_showOnlyAvailableTeams) {
      filtered = filtered.where((team) => team.budget > 0).toList();
    }

    // Ordenar alfabéticamente
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  }

  Widget _buildTeamTile(Team team, SettingsProvider settingsProvider) {
    final isSelected = _selectedTeam?.id == team.id;
    final isDefault = settingsProvider.defaultTeamId == team.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      elevation: isSelected ? 4.0 : 1.0,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[600],
          child: Text(
            team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isDefault)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manager: ${team.ownerName}'),
            Text(
              'Presupuesto: \$${team.budget.toStringAsFixed(0)}M',
              style: TextStyle(
                color: team.budget > 50 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (team.playerIds.isNotEmpty)
              Text('Jugadores: ${team.playerIds.length}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showDefaultTeamOption && isSelected)
              IconButton(
                icon: Icon(
                  isDefault ? Icons.star : Icons.star_border,
                  color: isDefault ? Colors.amber : Colors.grey,
                ),
                onPressed: () async {
                  if (isDefault) {
                    await settingsProvider.clearDefaultTeam();
                  } else {
                    await settingsProvider.setDefaultTeam(team);
                  }
                  // Remove setState() - Provider will handle the rebuild automatically
                },
                tooltip: isDefault 
                    ? 'Quitar como equipo por defecto'
                    : 'Establecer como equipo por defecto',
              ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
        onTap: () {
          final newSelectedTeam = isSelected ? null : team;
          _selectedTeam = newSelectedTeam;
          widget.onTeamSelected?.call(_selectedTeam);
          
          // Use a post-frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TeamProvider, SettingsProvider>(
      builder: (context, teamProvider, settingsProvider, child) {
        if (teamProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando equipos...'),
              ],
            ),
          );
        }

        if (teamProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error cargando equipos:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  teamProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        final teams = _filterTeams(teamProvider.teams);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
            ],

            // Información del equipo por defecto
            if (widget.showDefaultTeamOption && settingsProvider.hasDefaultTeam)
              Card(
                color: Colors.amber.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Equipo por defecto: ${settingsProvider.defaultTeamName}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Controles de filtrado
            if (!widget.compactMode) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar equipos...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Disponibles'),
                    selected: _showOnlyAvailableTeams,
                    onSelected: (selected) {
                      setState(() {
                        _showOnlyAvailableTeams = selected;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Lista de equipos
            if (teams.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No se encontraron equipos\nque coincidan con la búsqueda'
                          : 'No hay equipos disponibles\nCargar datos desde JSON',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    return _buildTeamTile(teams[index], settingsProvider);
                  },
                ),
              ),

            // Información de selección
            if (_selectedTeam != null && !widget.compactMode) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seleccionado: ${_selectedTeam!.name}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedTeam = null;
                          });
                          widget.onTeamSelected?.call(null);
                        },
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}