import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Título
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipo por Defecto',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Selecciona tu equipo favorito',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lista de equipos simple
              Expanded(
                child: Card(
                  child: Consumer2<TeamProvider, SettingsProvider>(
                    builder: (context, teamProvider, settingsProvider, child) {
                      if (teamProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      if (teamProvider.teams.isEmpty) {
                        return const Center(
                          child: Text('No hay equipos disponibles'),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: teamProvider.teams.length,
                        itemBuilder: (context, index) {
                          final team = teamProvider.teams[index];
                          final isDefault = settingsProvider.defaultTeamId == team.id;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDefault ? AppTheme.primaryColor : Colors.grey,
                              child: Text(
                                team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              team.name,
                              style: TextStyle(
                                fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text('Manager: ${team.ownerName}'),
                            trailing: isDefault 
                              ? Icon(Icons.star, color: Colors.amber)
                              : null,
                            onTap: () async {
                              try {
                                if (isDefault) {
                                  await settingsProvider.clearDefaultTeam();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Equipo por defecto eliminado'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                } else {
                                  await settingsProvider.setDefaultTeam(team);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              
              // Información actual
              const SizedBox(height: 16),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              settingsProvider.hasDefaultTeam 
                                ? 'Equipo actual: ${settingsProvider.defaultTeamName}'
                                : 'No hay equipo seleccionado',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}