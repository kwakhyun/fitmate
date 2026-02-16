import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _userProfileBox = 'user_profile';
  static const String _weightRecordsBox = 'weight_records';
  static const String _mealRecordsBox = 'meal_records';
  static const String _dailyHealthBox = 'daily_health';
  static const String _settingsBox = 'settings';

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(_userProfileBox),
      Hive.openBox<String>(_weightRecordsBox),
      Hive.openBox<String>(_mealRecordsBox),
      Hive.openBox<String>(_dailyHealthBox),
      Hive.openBox<String>(_settingsBox),
    ]);
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final box = Hive.box<String>(_userProfileBox);
    await box.put('profile', jsonEncode(profile));
  }

  Map<String, dynamic>? getUserProfile() {
    final box = Hive.box<String>(_userProfileBox);
    final data = box.get('profile');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> saveWeightRecords(List<Map<String, dynamic>> records) async {
    final box = Hive.box<String>(_weightRecordsBox);
    await box.put('records', jsonEncode(records));
  }

  List<Map<String, dynamic>> getWeightRecords() {
    final box = Hive.box<String>(_weightRecordsBox);
    final data = box.get('records');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> addWeightRecord(Map<String, dynamic> record) async {
    final records = getWeightRecords();
    records.add(record);
    await saveWeightRecords(records);
  }

  Future<void> removeWeightRecord(String id) async {
    final records = getWeightRecords();
    records.removeWhere((r) => r['id'] == id);
    await saveWeightRecords(records);
  }

  Future<void> saveMealRecords(List<Map<String, dynamic>> records) async {
    final box = Hive.box<String>(_mealRecordsBox);
    await box.put('records', jsonEncode(records));
  }

  List<Map<String, dynamic>> getMealRecords() {
    final box = Hive.box<String>(_mealRecordsBox);
    final data = box.get('records');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> addMealRecord(Map<String, dynamic> record) async {
    final records = getMealRecords();
    records.add(record);
    await saveMealRecords(records);
  }

  Future<void> removeMealRecord(String id) async {
    final records = getMealRecords();
    records.removeWhere((r) => r['id'] == id);
    await saveMealRecords(records);
  }

  Future<void> saveDailyHealth(Map<String, dynamic> health) async {
    final box = Hive.box<String>(_dailyHealthBox);
    final dateKey = health['date'] as String;
    await box.put(dateKey, jsonEncode(health));
  }

  Map<String, dynamic>? getDailyHealth(String dateKey) {
    final box = Hive.box<String>(_dailyHealthBox);
    final data = box.get(dateKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Map<String, dynamic>? getTodayHealth() {
    final now = DateTime.now();
    final dateKey = DateTime(now.year, now.month, now.day).toIso8601String();
    return getDailyHealth(dateKey);
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box<String>(_settingsBox);
    await box.put(key, jsonEncode(value));
  }

  T? getSetting<T>(String key) {
    final box = Hive.box<String>(_settingsBox);
    final data = box.get(key);
    if (data == null) return null;
    return jsonDecode(data) as T;
  }

  Future<void> clearAll() async {
    await Future.wait([
      Hive.box<String>(_userProfileBox).clear(),
      Hive.box<String>(_weightRecordsBox).clear(),
      Hive.box<String>(_mealRecordsBox).clear(),
      Hive.box<String>(_dailyHealthBox).clear(),
      Hive.box<String>(_settingsBox).clear(),
    ]);
  }

  bool get hasData {
    final box = Hive.box<String>(_userProfileBox);
    return box.isNotEmpty;
  }
}
