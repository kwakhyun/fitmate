import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/meal_record.dart';
import '../../data/services/food_api_service.dart';
import '../../providers/app_providers.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  MealType _selectedType = MealType.lunch;
  final _searchController = TextEditingController();
  List<FoodItem> _filteredFoods = [];
  final List<FoodItem> _selectedFoods = [];
  bool _isSearching = false;
  bool _isAiAnalyzing = false;
  String? _searchError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialFoods() async {
    final foodService = ref.read(foodApiServiceProvider);
    final foods = await foodService.searchFood('');
    if (mounted) {
      setState(() => _filteredFoods = foods);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _filterFoods('');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterFoods(query);
    });
  }

  Future<void> _filterFoods(String query) async {
    setState(() {
      _isSearching = true;
      _isAiAnalyzing = false;
      _searchError = null;
    });

    try {
      final foodService = ref.read(foodApiServiceProvider);

      final foods = await foodService.searchFood(query);

      if (mounted) {
        setState(() {
          _filteredFoods = foods;
          _isAiAnalyzing = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _searchError = '검색 중 오류가 발생했습니다');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isAiAnalyzing = false;
        });
      }
    }
  }

  void _addFood(FoodItem food) {
    setState(() {
      _selectedFoods.add(food);
    });
  }

  void _removeFood(int index) {
    setState(() {
      _selectedFoods.removeAt(index);
    });
  }

  void _saveMeal() {
    const uuid = Uuid();
    final selectedDate = ref.read(selectedDateProvider);
    for (final food in _selectedFoods) {
      ref.read(mealRecordsProvider.notifier).addMeal(
            food.toMealRecord(
              id: uuid.v4(),
              date: DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                DateTime.now().hour,
                DateTime.now().minute,
              ),
              mealType: _selectedType,
            ),
          );
    }
    Navigator.pop(context);
  }

  int get _totalCalories =>
      _selectedFoods.fold(0, (sum, f) => sum + f.calories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text(
          '식단 추가',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedFoods.isNotEmpty)
            TextButton(
              onPressed: _saveMeal,
              child: const Text(
                '저장',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildMealTypeSelector(),
          _buildSearchBar(),
          if (_isAiAnalyzing) _buildAiAnalyzingBanner(),
          if (_selectedFoods.isNotEmpty) _buildSelectedFoods(),
          Expanded(child: _buildFoodList()),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: context.colorSurface,
      child: Row(
        children: MealType.values.map((type) {
          final isSelected = type == _selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : context.colorSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: '음식을 검색하세요 (예: 김치찌개, 아사이볼, 연어 포케)',
              prefixIcon:
                  Icon(Icons.search_rounded, color: context.colorTextTertiary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '💡 DB에 없는 음식은 AI가 자동으로 영양 정보를 분석합니다',
            style: TextStyle(
              fontSize: 11,
              color: context.colorTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalyzingBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'AI가 영양 정보를 분석하고 있어요...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoods() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorPrimarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '선택된 음식 (${_selectedFoods.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${_totalCalories}kcal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFoods.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(
                      entry.value.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    avatar: entry.value.isAiGenerated
                        ? const Icon(Icons.auto_awesome,
                            size: 14, color: AppColors.secondary)
                        : null,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeFood(entry.key),
                    backgroundColor: context.colorSurface,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFoodList() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              _searchError!,
              style: TextStyle(
                color: context.colorTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _filterFoods(_searchController.text),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_filteredFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: context.colorTextTertiary, size: 48),
            const SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                color: context.colorTextSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final localFoods =
        _filteredFoods.where((f) => f.source == FoodSource.localDb).toList();
    final publicFoods =
        _filteredFoods.where((f) => f.source == FoodSource.publicApi).toList();
    final aiFoods =
        _filteredFoods.where((f) => f.source == FoodSource.aiAnalysis).toList();

    final isSearching = _searchController.text.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (isSearching) ...[
          if (localFoods.isNotEmpty) ...[
            _buildSectionHeader(
              icon: Icons.restaurant_menu_rounded,
              title: '내장 데이터베이스',
              count: localFoods.length,
              emoji: '📦',
            ),
            const SizedBox(height: 8),
            ...localFoods.map((food) => _buildFoodTile(food)),
          ],
          if (publicFoods.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              icon: Icons.account_balance_rounded,
              title: '식약처 식품영양정보',
              count: publicFoods.length,
              emoji: '🏛️',
              tagText: '공공데이터',
              tagColor: Colors.teal,
            ),
            const SizedBox(height: 8),
            ...publicFoods.map((food) => _buildFoodTile(food)),
          ],
          if (aiFoods.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              icon: Icons.auto_awesome,
              title: 'AI 영양 분석 결과',
              count: aiFoods.length,
              emoji: '🤖',
              isAi: true,
            ),
            const SizedBox(height: 8),
            ...aiFoods.map((food) => _buildFoodTile(food)),
          ],
        ] else ...[
          ...localFoods.map((food) => _buildFoodTile(food)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
    String? emoji,
    String? tagText,
    Color? tagColor,
    bool isAi = false,
  }) {
    final effectiveColor =
        tagColor ?? (isAi ? AppColors.secondary : context.colorTextTertiary);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 16, color: effectiveColor),
            const SizedBox(width: 6),
          ],
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isAi ? AppColors.secondary : context.colorTextSecondary,
            ),
          ),
          if (isAi || tagText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tagText ?? 'GPT 분석',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    final isExternal = food.source == FoodSource.aiAnalysis ||
        food.source == FoodSource.publicApi;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: food.source == FoodSource.aiAnalysis
              ? AppColors.secondary.withValues(alpha: 0.3)
              : food.source == FoodSource.publicApi
                  ? Colors.teal.withValues(alpha: 0.3)
                  : context.colorBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: isExternal
            ? Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: food.source == FoodSource.aiAnalysis
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(food.sourceEmoji,
                      style: const TextStyle(fontSize: 16)),
                ),
              )
            : null,
        title: Text(
          food.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                '탄 ${food.carbs.toStringAsFixed(0)}g · 단 ${food.protein.toStringAsFixed(0)}g · 지 ${food.fat.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colorTextTertiary,
                ),
              ),
            ),
            if (food.servingSize != null) ...[
              const SizedBox(width: 6),
              Text(
                food.servingSize!,
                style: TextStyle(
                  fontSize: 10,
                  color: context.colorTextTertiary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${food.calories}kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _addFood(food),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: food.source == FoodSource.aiAnalysis
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : food.source == FoodSource.publicApi
                          ? Colors.teal.withValues(alpha: 0.1)
                          : context.colorPrimarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: food.source == FoodSource.aiAnalysis
                      ? AppColors.secondary
                      : food.source == FoodSource.publicApi
                          ? Colors.teal
                          : AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
