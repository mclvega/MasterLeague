import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team.dart';
import '../../providers/team_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/team_selector_widget.dart';

class TeamSelectionExampleScreen extends StatefulWidget {
  const TeamSelectionExampleScreen({Key? key}) : super(key: key);

  @override
  State<TeamSelectionExampleScreen> createState() => _TeamSelectionExampleScreenState();
}

class _TeamSelectionExampleScreenState extends State<TeamSelectionExampleScreen> {
  Team? selectedTeam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selector de Equipos - Ejemplo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<TeamProvider, SettingsProvider>(
        builder: (context, teamProvider, settingsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del ejemplo
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ejemplo de Uso del Selector de Equipos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Este widget permite:\n'
                          '• Seleccionar equipos cargados desde el JSON\n'
                          '• Establecer un equipo por defecto\n'
                          '• Buscar equipos por nombre o manager\n'
                          '• Filtrar solo equipos disponibles\n'
                          '• Persistir la configuración en base de datos local',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Estado actual
                if (selectedTeam != null) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Equipo Seleccionado',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  selectedTeam!.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text('Manager: ${selectedTeam!.ownerName}'),
                                Text('Presupuesto: \$${selectedTeam!.budget.toStringAsFixed(0)}M'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Selector de equipos
                Expanded(
                  child: TeamSelectorWidget(
                    title: 'Selecciona tu equipo:',
                    showDefaultTeamOption: true,
                    compactMode: false,
                    initialSelectedTeam: selectedTeam,
                    onTeamSelected: (team) {
                      setState(() {
                        selectedTeam = team;
                      });
                      
                      if (team != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Seleccionaste: ${team.name}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: selectedTeam != null 
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Ejemplo de cómo establecer como equipo por defecto programáticamente
                final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                await settingsProvider.setDefaultTeam(selectedTeam!);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${selectedTeam!.name} establecido como equipo por defecto'),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.star),
              label: const Text('Establecer por defecto'),
            )
          : null,
    );
  }
}