import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/core/theme/app_typography.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item_full.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/food_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY SEARCH STATE
// ─────────────────────────────────────────────────────────────────────────────

class EmptyFoodSearchState extends StatelessWidget {
  const EmptyFoodSearchState({super.key, required this.query, required this.onReset});
  final String query;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.panel,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Icon(Icons.search_off_rounded, size: 36, color: tokens.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'NO FOODS FOUND',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              query.isNotEmpty
                  ? 'No verified food matches "$query" under the active category/budget filter.'
                  : 'No verified items found with active filter selections.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: tokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.refresh_rounded, size: 16, color: tokens.cyanAccent),
              label: Text(
                'RESET FILTERS',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.cyanAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM FOOD DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class CreateCustomFoodDialog extends ConsumerStatefulWidget {
  const CreateCustomFoodDialog({super.key, required this.onFoodCreated});
  final void Function(FoodItemFull food) onFoodCreated;

  @override
  ConsumerState<CreateCustomFoodDialog> createState() =>
      _CreateCustomFoodDialogState();
}

class _CreateCustomFoodDialogState
    extends ConsumerState<CreateCustomFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  FoodCategory _selectedCategory = FoodCategory.protein;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName required';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName required';
    }
    final number = double.tryParse(value);
    if (number == null) return 'Invalid number';
    if (number < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _saveCustomFood() async {
    if (!_formKey.currentState!.validate()) return;
    AppHaptics.shared.buttonPress();
    setState(() => _isSaving = true);

    try {
      final customFood = FoodItemFull(
        id: 'custom_${const Uuid().v4()}',
        name: _nameController.text.trim(),
        category: _selectedCategory.displayName.toLowerCase(),
        imageUrl: '',
        macros: MacrosPer100g(
          calories: double.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fats: double.parse(_fatController.text),
        ),
        micros: const MicrosPer100g(
          fiber: 0,
          sugar: 0,
          sodium: 0,
          potassium: 0,
        ),
        vitamins: const VitaminsPer100g(
          vitaminA: 0,
          vitaminB: 0,
          vitaminC: 0,
          vitaminD: 0,
          vitaminE: 0,
        ),
        minerals: const MineralsPer100g(
          calcium: 0,
          iron: 0,
          magnesium: 0,
          zinc: 0,
        ),
      );

      await ref.read(customFoodsProvider.notifier).addCustomFood(customFood);

      if (mounted) {
        Navigator.pop(context);
        widget.onFoodCreated(customFood);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save fuel: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Dialog(
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEW FUEL ENTRY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: tokens.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: tokens.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Define nutritional values per 100 grams.',
                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                decoration: _dialogInputDecoration(tokens, 'Food Name', 'e.g. Homemade Protein Bar'),
                validator: (v) => _validateRequired(v, 'Name'),
              ),
              const SizedBox(height: 12),

              // Category selector
              DropdownButtonFormField<FoodCategory>(
                initialValue: _selectedCategory,
                dropdownColor: tokens.panel,
                style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                decoration: _dialogInputDecoration(tokens, 'Category', ''),
                items: FoodCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.displayName),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),

              // Calories
              TextFormField(
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                decoration: _dialogInputDecoration(tokens, 'Calories per 100g', 'kcal'),
                validator: (v) => _validateNumber(v, 'Calories'),
              ),
              const SizedBox(height: 12),

              // Macros row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: tokens.protein, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _dialogInputDecoration(tokens, 'Protein (g)', 'g'),
                      validator: (v) => _validateNumber(v, 'Protein'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: tokens.carbs, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _dialogInputDecoration(tokens, 'Carbs (g)', 'g'),
                      validator: (v) => _validateNumber(v, 'Carbs'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: tokens.fats, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _dialogInputDecoration(tokens, 'Fat (g)', 'g'),
                      validator: (v) => _validateNumber(v, 'Fat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _isSaving ? 'SAVING...' : 'SAVE FUEL',
                      icon: const Icon(Icons.check_rounded, size: 18),
                      onPressed: _isSaving ? null : _saveCustomFood,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(AppThemeTokens tokens, String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: AppTypography.displayFontFamily,
        fontSize: 10,
        color: tokens.textMuted,
        letterSpacing: 0.5,
      ),
      hintText: hint,
      hintStyle: TextStyle(color: tokens.textMuted.withValues(alpha: 0.5), fontSize: 12),
      filled: true,
      fillColor: tokens.panel,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        borderSide: BorderSide(color: tokens.cyanAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        borderSide: BorderSide(color: tokens.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        borderSide: BorderSide(color: tokens.error, width: 1.5),
      ),
    );
  }
}
