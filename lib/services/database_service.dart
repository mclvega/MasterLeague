import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/competition.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'master_league.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de configuraciones
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de equipos locales (cache)
    await db.execute('''
      CREATE TABLE teams_cache(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        owner_name TEXT NOT NULL,
        budget REAL DEFAULT 0,
        logo_url TEXT,
        formation TEXT,
        home_stadium TEXT,
        established TEXT,
        data_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de jugadores locales (cache)
    await db.execute('''
      CREATE TABLE players_cache(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        position TEXT,
        team_id TEXT,
        price REAL DEFAULT 0,
        data_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de competencias locales (cache)
    await db.execute('''
      CREATE TABLE competitions_cache(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT,
        status TEXT,
        data_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    print('✅ Base de datos Master League creada');
  }

  // === CONFIGURACIONES ===
  
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  // === CACHE DE EQUIPOS ===
  
  Future<void> cacheTeams(List<Team> teams) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    // Limpiar cache anterior
    await db.delete('teams_cache');
    
    // Insertar nuevos equipos
    for (final team in teams) {
      await db.insert('teams_cache', {
        'id': team.id,
        'name': team.name,
        'owner_name': team.ownerName,
        'budget': team.budget,
        'logo_url': team.logoUrl,
        'formation': team.formation,
        'home_stadium': team.homeStadium,
        'established': team.established,
        'data_json': team.toJson(),
        'updated_at': now,
      });
    }
    print('💾 ${teams.length} equipos almacenados en cache');
  }

  Future<List<Team>> getCachedTeams() async {
    final db = await database;
    final result = await db.query('teams_cache', orderBy: 'name ASC');
    
    if (result.isEmpty) return [];
    
    return result.map((row) {
      return Team.fromJson(row['data_json'] as String);
    }).toList();
  }

  // === CACHE DE JUGADORES ===
  
  Future<void> cachePlayers(List<Player> players) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    // Limpiar cache anterior
    await db.delete('players_cache');
    
    // Insertar nuevos jugadores
    for (final player in players) {
      await db.insert('players_cache', {
        'id': player.id,
        'name': player.name,
        'position': player.position,
        'team_id': player.teamId,
        'price': player.price,
        'data_json': player.toJson(),
        'updated_at': now,
      });
    }
    print('💾 ${players.length} jugadores almacenados en cache');
  }

  Future<List<Player>> getCachedPlayers() async {
    final db = await database;
    final result = await db.query('players_cache', orderBy: 'name ASC');
    
    if (result.isEmpty) return [];
    
    return result.map((row) {
      return Player.fromJson(row['data_json'] as String);
    }).toList();
  }

  // === CACHE DE COMPETENCIAS ===
  
  Future<void> cacheCompetitions(List<Competition> competitions) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    // Limpiar cache anterior
    await db.delete('competitions_cache');
    
    // Insertar nuevas competencias
    for (final competition in competitions) {
      await db.insert('competitions_cache', {
        'id': competition.id,
        'name': competition.name,
        'type': competition.type,
        'status': competition.status,
        'data_json': competition.toJson(),
        'updated_at': now,
      });
    }
    print('💾 ${competitions.length} competencias almacenadas en cache');
  }

  Future<List<Competition>> getCachedCompetitions() async {
    final db = await database;
    final result = await db.query('competitions_cache', orderBy: 'name ASC');
    
    if (result.isEmpty) return [];
    
    return result.map((row) {
      return Competition.fromJson(row['data_json'] as String);
    }).toList();
  }

  // === UTILIDADES ===
  
  Future<DateTime?> getLastCacheUpdate() async {
    final db = await database;
    final result = await db.query(
      'teams_cache',
      columns: ['updated_at'],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return DateTime.parse(result.first['updated_at'] as String);
    }
    return null;
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('teams_cache');
    await db.delete('players_cache');
    await db.delete('competitions_cache');
    print('🗑️ Cache limpiado');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}