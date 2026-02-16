import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';
import '../data/models/weight_record.dart';
import '../data/models/meal_record.dart';
import '../data/models/daily_health.dart';
import '../data/models/chat_message.dart';
import '../data/repositories/dummy_data.dart';
import '../data/services/ai_chat_service.dart';
import '../data/services/food_api_service.dart';
import '../data/services/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService();
});

final foodApiServiceProvider = Provider<FoodApiService>((ref) {
  return FoodApiService();
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return UserProfileNotifier(storage);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final LocalStorageService _storage;

  UserProfileNotifier(this._storage) : super(_loadProfile(_storage));

  static UserProfile _loadProfile(LocalStorageService storage) {
    final data = storage.getUserProfile();
    if (data != null) {
      return UserProfile.fromJson(data);
    }
    return UserProfile.defaultProfile();
  }

  void updateProfile(UserProfile profile) {
    state = profile;
    _persist();
  }

  void updateWeight(double weight) {
    state = state.copyWith(currentWeight: weight);
    _persist();
  }

  void _persist() {
    _storage.saveUserProfile(state.toJson());
  }
}

final weightRecordsProvider =
    StateNotifierProvider<WeightRecordsNotifier, List<WeightRecord>>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return WeightRecordsNotifier(storage);
});

class WeightRecordsNotifier extends StateNotifier<List<WeightRecord>> {
  final LocalStorageService _storage;

  WeightRecordsNotifier(this._storage) : super(_loadRecords(_storage));

  static List<WeightRecord> _loadRecords(LocalStorageService storage) {
    final data = storage.getWeightRecords();
    if (data.isNotEmpty) {
      return data.map((d) => WeightRecord.fromJson(d)).toList();
    }
    return DummyData.generateWeightRecords();
  }

  void addRecord(WeightRecord record) {
    state = [...state, record];
    _persist();
  }

  void removeRecord(String id) {
    state = state.where((r) => r.id != id).toList();
    _persist();
  }

  void _persist() {
    _storage.saveWeightRecords(state.map((r) => r.toJson()).toList());
  }
}

final mealRecordsProvider =
    StateNotifierProvider<MealRecordsNotifier, List<MealRecord>>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return MealRecordsNotifier(storage);
});

class MealRecordsNotifier extends StateNotifier<List<MealRecord>> {
  final LocalStorageService _storage;

  MealRecordsNotifier(this._storage) : super(_loadRecords(_storage));

  static List<MealRecord> _loadRecords(LocalStorageService storage) {
    final data = storage.getMealRecords();
    if (data.isNotEmpty) {
      return data.map((d) => MealRecord.fromJson(d)).toList();
    }
    return DummyData.generateTodayMeals();
  }

  void addMeal(MealRecord meal) {
    state = [...state, meal];
    _persist();
  }

  void removeMeal(String id) {
    state = state.where((m) => m.id != id).toList();
    _persist();
  }

  void clearDay(DateTime date) {
    state = state
        .where((m) =>
            m.date.year != date.year ||
            m.date.month != date.month ||
            m.date.day != date.day)
        .toList();
    _persist();
  }

  void _persist() {
    _storage.saveMealRecords(state.map((m) => m.toJson()).toList());
  }
}

final dailyHealthProvider =
    StateNotifierProvider<DailyHealthNotifier, DailyHealth>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return DailyHealthNotifier(storage);
});

class DailyHealthNotifier extends StateNotifier<DailyHealth> {
  final LocalStorageService _storage;

  DailyHealthNotifier(this._storage) : super(_loadHealth(_storage));

  static DailyHealth _loadHealth(LocalStorageService storage) {
    final data = storage.getTodayHealth();
    if (data != null) {
      return DailyHealth.fromJson(data);
    }
    return DummyData.generateTodayHealth();
  }

  void addWater(int ml) {
    state = state.copyWith(waterMl: state.waterMl + ml);
    _persist();
  }

  void removeWater(int ml) {
    state = state.copyWith(waterMl: (state.waterMl - ml).clamp(0, 10000));
    _persist();
  }

  void updateSteps(int steps) {
    state = state.copyWith(steps: steps);
    _persist();
  }

  void updateSleep(double hours) {
    state = state.copyWith(sleepHours: hours);
    _persist();
  }

  void updateExercise(int minutes) {
    state = state.copyWith(exerciseMinutes: minutes);
    _persist();
  }

  void updateMood(String mood) {
    state = state.copyWith(mood: mood);
    _persist();
  }

  void _persist() {
    _storage.saveDailyHealth(state.toJson());
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<SettingsBoolNotifier, bool>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return SettingsBoolNotifier(storage, 'notifications_enabled', true);
});

final darkModeProvider =
    StateNotifierProvider<SettingsBoolNotifier, bool>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return SettingsBoolNotifier(storage, 'dark_mode', false);
});

class SettingsBoolNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;
  final String _key;

  SettingsBoolNotifier(this._storage, this._key, bool defaultValue)
      : super(_storage.getSetting<bool>(_key) ?? defaultValue);

  void toggle() {
    state = !state;
    _storage.saveSetting(_key, state);
  }

  void setValue(bool value) {
    state = value;
    _storage.saveSetting(_key, value);
  }
}

final dataResetProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.clearAll();
    ref.invalidate(userProfileProvider);
    ref.invalidate(weightRecordsProvider);
    ref.invalidate(mealRecordsProvider);
    ref.invalidate(dailyHealthProvider);
    ref.invalidate(chatMessagesProvider);
    ref.invalidate(notificationsEnabledProvider);
    ref.invalidate(darkModeProvider);
  };
});

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

final chatLoadingProvider = StateProvider<bool>((ref) => false);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatMessagesNotifier(this._ref)
      : super([
          ChatMessage(
            id: 'welcome',
            content:
                '안녕하세요! 🌿 저는 FitMate AI 코치입니다.\n\n오늘 식단이나 운동에 대해 궁금한 점이 있으신가요? 무엇이든 물어보세요!',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            type: ChatMessageType.text,
          ),
        ]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  Future<void> addBotResponse(String userMessage) async {
    _ref.read(chatLoadingProvider.notifier).state = true;

    try {
      final aiService = _ref.read(aiChatServiceProvider);
      final context = _buildUserContext();

      final response = await aiService.generateResponse(
        userMessage: userMessage,
        context: context,
      );

      addMessage(ChatMessage(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.text,
      ));
    } catch (e) {
      addMessage(ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        content: '죄송해요, 일시적인 오류가 발생했어요. 😥\n다시 질문해주시면 답변드릴게요!',
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.text,
      ));
    } finally {
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  Map<String, dynamic> _buildUserContext() {
    final profile = _ref.read(userProfileProvider);
    final todayCalories = _ref.read(todayCaloriesProvider);
    final macros = _ref.read(todayMacrosProvider);
    final health = _ref.read(dailyHealthProvider);

    return {
      'todayCalories': todayCalories,
      'calorieGoal': profile.dailyCalorieGoal,
      'currentWeight': profile.currentWeight,
      'targetWeight': profile.targetWeight,
      'waterMl': health.waterMl,
      'steps': health.steps,
      'macros': macros,
    };
  }
}

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

final selectedDateMealsProvider = Provider<List<MealRecord>>((ref) {
  final meals = ref.watch(mealRecordsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return meals
      .where((m) =>
          m.date.year == selectedDate.year &&
          m.date.month == selectedDate.month &&
          m.date.day == selectedDate.day)
      .toList();
});

final todayCaloriesProvider = Provider<int>((ref) {
  final meals = ref.watch(selectedDateMealsProvider);
  return meals.fold(0, (sum, meal) => sum + meal.calories);
});

final todayMacrosProvider = Provider<Map<String, double>>((ref) {
  final meals = ref.watch(selectedDateMealsProvider);
  return {
    'carbs': meals.fold(0.0, (sum, m) => sum + m.carbs),
    'protein': meals.fold(0.0, (sum, m) => sum + m.protein),
    'fat': meals.fold(0.0, (sum, m) => sum + m.fat),
  };
});

final mealsByTypeProvider =
    Provider.family<List<MealRecord>, MealType>((ref, type) {
  final meals = ref.watch(selectedDateMealsProvider);
  return meals.where((m) => m.mealType == type).toList();
});
