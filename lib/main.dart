import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/player_provider.dart';
import 'providers/team_provider.dart';
import 'providers/competition_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando MRRICHAR...');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => CompetitionProvider()),
      ],
      child: MaterialApp(
        title: 'MRRICHAR',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(), // Ir directo al home sin splash
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}