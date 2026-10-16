import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training.dart';

/// Single source of truth for local workouts, drills, name and weekly goal.
/// ChangeNotifier tells listening widgets to rebuild when data changes.
class AppStore extends ChangeNotifier {
  static const _recordsKey = 'court_iq_records_v1';
  static const _drillsKey = 'court_iq_drills_v1';
  static const _nameKey = 'court_iq_name_v1';
  static const _goalKey = 'court_iq_goal_v1';

  SharedPreferences? _prefs;
  String athleteName = 'Athlete';
  int weeklyGoal = 5;
  final List<TrainingRecord> records = [];
  final List<Drill> customDrills = [];

  List<Drill> get allDrills => [...defaultDrills, ...customDrills];
  int get totalMinutes => records.fold(0, (sum, item) => sum + item.minutes);
  int get totalSessions => records.length;
  int get weeklySessions =>
      records.where((item) => _isThisWeek(item.completedAt)).length;
  int get weeklyMinutes => records
      .where((item) => _isThisWeek(item.completedAt))
      .fold(0, (sum, item) => sum + item.minutes);
  double get weeklyProgress =>
      (weeklySessions / weeklyGoal).clamp(0.0, 1.0).toDouble();

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return !date.isBefore(monday) &&
        date.isBefore(monday.add(const Duration(days: 7)));
  }

  int sessionsOn(DateTime day) => records
      .where((r) =>
          r.completedAt.year == day.year &&
          r.completedAt.month == day.month &&
          r.completedAt.day == day.day)
      .length;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final storedName = _prefs!.getString(_nameKey)?.trim();
    athleteName =
        storedName == null || storedName.isEmpty ? 'Athlete' : storedName;
    weeklyGoal = (_prefs!.getInt(_goalKey) ?? 5).clamp(1, 7).toInt();

    // Load separately so one damaged list cannot erase the other list.
    // Clear first so calling load() twice won't duplicate data in memory.
    records.clear();
    try {
      final decoded = jsonDecode(_prefs!.getString(_recordsKey) ?? '[]');
      if (decoded is! List) throw const FormatException('Invalid records list');
      records.addAll(decoded.map((item) =>
          TrainingRecord.fromJson(Map<String, dynamic>.from(item as Map))));
      records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } on FormatException {
      records.clear();
    } on TypeError {
      records.clear();
    }

    customDrills.clear();
    try {
      final decoded = jsonDecode(_prefs!.getString(_drillsKey) ?? '[]');
      if (decoded is! List) throw const FormatException('Invalid drills list');
      customDrills.addAll(decoded.map(
          (item) => Drill.fromJson(Map<String, dynamic>.from(item as Map))));
    } on FormatException {
      customDrills.clear();
    } on TypeError {
      customDrills.clear();
    }
    notifyListeners();
  }

  Future<void> addSession(Drill drill) async {
    final record = TrainingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: drill.title,
      category: drill.category,
      minutes: drill.minutes,
      completedAt: DateTime.now(),
    );
    records.insert(0, record);
    notifyListeners();
    try {
      await _saveRecords();
    } catch (_) {
      records.remove(record);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSession(String id) async {
    final backup = List<TrainingRecord>.from(records);
    records.removeWhere((record) => record.id == id);
    notifyListeners();
    try {
      await _saveRecords();
    } catch (_) {
      records
        ..clear()
        ..addAll(backup);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveCustomDrill(Drill drill) async {
    final backup = List<Drill>.from(customDrills);
    final index = customDrills.indexWhere((d) => d.id == drill.id);
    if (index == -1) {
      customDrills.add(drill);
    } else {
      customDrills[index] = drill;
    }
    notifyListeners();
    try {
      await _saveDrills();
    } catch (_) {
      customDrills
        ..clear()
        ..addAll(backup);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCustomDrill(String id) async {
    final backup = List<Drill>.from(customDrills);
    customDrills.removeWhere((drill) => drill.id == id);
    notifyListeners();
    try {
      await _saveDrills();
    } catch (_) {
      customDrills
        ..clear()
        ..addAll(backup);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateName(String newName) async {
    final updated = newName.trim();
    if (updated.isEmpty) throw ArgumentError('Name cannot be empty');
    final previous = athleteName;
    athleteName = updated;
    notifyListeners();
    try {
      if (!await _prefsOrThrow.setString(_nameKey, updated)) {
        throw StateError('Could not save name');
      }
    } catch (_) {
      athleteName = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateWeeklyGoal(int value) async {
    final previous = weeklyGoal;
    weeklyGoal = value.clamp(1, 7).toInt();
    notifyListeners();
    try {
      if (!await _prefsOrThrow.setInt(_goalKey, weeklyGoal)) {
        throw StateError('Could not save weekly goal');
      }
    } catch (_) {
      weeklyGoal = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearUserData() async {
    final oldRecords = List<TrainingRecord>.from(records);
    final oldDrills = List<Drill>.from(customDrills);
    records.clear();
    customDrills.clear();
    notifyListeners();
    try {
      await _saveRecords();
      await _saveDrills();
    } catch (_) {
      records
        ..clear()
        ..addAll(oldRecords);
      customDrills
        ..clear()
        ..addAll(oldDrills);
      notifyListeners();
      // Best-effort restoration after a partial write failure.
      try {
        await _saveRecords();
        await _saveDrills();
      } catch (_) {}
      rethrow;
    }
  }

  SharedPreferences get _prefsOrThrow {
    final prefs = _prefs;
    if (prefs == null) throw StateError('Call AppStore.load() before saving');
    return prefs;
  }

  Future<void> _saveRecords() async {
    final saved = await _prefsOrThrow.setString(
        _recordsKey, jsonEncode(records.map((r) => r.toJson()).toList()));
    if (!saved) throw StateError('Could not save training history');
  }

  Future<void> _saveDrills() async {
    final saved = await _prefsOrThrow.setString(
        _drillsKey, jsonEncode(customDrills.map((d) => d.toJson()).toList()));
    if (!saved) throw StateError('Could not save custom drills');
  }
}
