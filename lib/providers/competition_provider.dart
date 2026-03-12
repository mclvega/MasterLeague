import 'package:flutter/foundation.dart';
import '../models/competition.dart';
import '../services/file_import_service_simple.dart';

class CompetitionProvider with ChangeNotifier {
  final List<Competition> _competitions = [];
  bool _isLoading = false;
  String? _error;

  List<Competition> get competitions => _competitions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Competition> get upcomingCompetitions =>
      _competitions.where((comp) => comp.status == CompetitionStatus.upcoming).toList();

  List<Competition> get ongoingCompetitions =>
      _competitions.where((comp) => comp.status == CompetitionStatus.ongoing).toList();

  List<Competition> get completedCompetitions =>
      _competitions.where((comp) => comp.status == CompetitionStatus.completed).toList();

  List<Competition> getCompetitionsByType(CompetitionType type) {
    return _competitions.where((comp) => comp.type == type).toList();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addCompetition(Competition competition) {
    _competitions.add(competition);
    notifyListeners();
  }

  void updateCompetition(Competition updatedCompetition) {
    final index = _competitions.indexWhere((comp) => comp.id == updatedCompetition.id);
    if (index != -1) {
      _competitions[index] = updatedCompetition;
      notifyListeners();
    }
  }

  void removeCompetition(String competitionId) {
    _competitions.removeWhere((comp) => comp.id == competitionId);
    notifyListeners();
  }

  Competition? getCompetitionById(String competitionId) {
    try {
      return _competitions.firstWhere((comp) => comp.id == competitionId);
    } catch (e) {
      return null;
    }
  }

  void addTeamToCompetition(String competitionId, String teamId) {
    final competition = getCompetitionById(competitionId);
    if (competition != null) {
      if (!competition.participantTeamIds.contains(teamId)) {
        final updatedParticipants = List<String>.from(competition.participantTeamIds)..add(teamId);
        final updatedCompetition = competition.copyWith(participantTeamIds: updatedParticipants);
        updateCompetition(updatedCompetition);
      }
    }
  }

  void removeTeamFromCompetition(String competitionId, String teamId) {
    final competition = getCompetitionById(competitionId);
    if (competition != null) {
      final updatedParticipants = List<String>.from(competition.participantTeamIds)..remove(teamId);
      final updatedCompetition = competition.copyWith(participantTeamIds: updatedParticipants);
      updateCompetition(updatedCompetition);
    }
  }

  void startCompetition(String competitionId) {
    final competition = getCompetitionById(competitionId);
    if (competition != null && competition.status == CompetitionStatus.upcoming) {
      final updatedCompetition = competition.copyWith(status: CompetitionStatus.ongoing);
      updateCompetition(updatedCompetition);
    }
  }

  void completeCompetition(String competitionId) {
    final competition = getCompetitionById(competitionId);
    if (competition != null && competition.status == CompetitionStatus.ongoing) {
      final updatedCompetition = competition.copyWith(
        status: CompetitionStatus.completed,
        endDate: DateTime.now(),
      );
      updateCompetition(updatedCompetition);
    }
  }

  List<Competition> searchCompetitions(String query) {
    if (query.isEmpty) return _competitions;
    
    return _competitions.where((comp) =>
        comp.name.toLowerCase().contains(query.toLowerCase()) ||
        comp.description?.toLowerCase().contains(query.toLowerCase()) == true ||
        comp.type.toString().split('.').last.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  void sortCompetitions(String sortBy, {bool ascending = true}) {
    switch (sortBy) {
      case 'name':
        _competitions.sort((a, b) => ascending 
            ? a.name.compareTo(b.name) 
            : b.name.compareTo(a.name));
        break;
      case 'startDate':
        _competitions.sort((a, b) => ascending 
            ? a.startDate.compareTo(b.startDate) 
            : b.startDate.compareTo(a.startDate));
        break;
      case 'prizePool':
        _competitions.sort((a, b) => ascending 
            ? a.prizePool.compareTo(b.prizePool) 
            : b.prizePool.compareTo(a.prizePool));
        break;
      case 'participants':
        _competitions.sort((a, b) => ascending 
            ? a.participantCount.compareTo(b.participantCount) 
            : b.participantCount.compareTo(a.participantCount));
        break;
    }
    notifyListeners();
  }

  void clearCompetitions() {
    _competitions.clear();
    notifyListeners();
  }

  Future<void> loadDataFromJsonUrl() async {
    // Google Sheets URL (se exporta automaticamente a Excel)
    const String excelUrl =
        'https://docs.google.com/spreadsheets/d/1QwBnvXQpDXIb5q4AUd3Sh4PI1zjmTQ03/export?format=xlsx';

    try {
      setLoading(true);
      setError(null);

      _competitions.clear();
      notifyListeners();

      final Map<String, dynamic> data = await FileImportService.downloadAndLoadExcelData(excelUrl);

      final List<Competition> importedCompetitions = data['competitions'] ?? [];
      _competitions.addAll(importedCompetitions);

      if (_competitions.isEmpty) {
        setError('No se encontraron eventos en los datos');
      }
    } catch (e) {
      setError('Error cargando eventos: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }
}