import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/food_item_full.dart';
import '../providers/food_providers.dart';

/// Screen for searching and selecting food items from the preloaded database.
/// When a food is tapped, shows a quantity input sheet with animated macro preview.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, required this.onFoodLogged});
  final void Function(FoodItem food, double grams) onFoodLogged;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuantitySheet(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuantitySheet(
        food: food,
        onConfirm: (grams) {
          Navigator.pop(context);
          widget.onFoodLogged(food, grams);
        },
      ),
    );
  }

  void _showCreateCustomFoodDialog() {
    showDialog(
      context: context,
      builder: (_) => _CreateCustomFoodDialog(
        onFoodCreated: (food) {
          // Food is already added to the list via the notifier
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom food "${food.name}" created!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foods = ref.watch(filteredFoodProvider);
    final search = ref.watch(foodSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateCustomFoodDialog,
            tooltip: 'Create Custom Food',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => ref.read(foodSearchProvider.notifier).setQuery(v),
              decoration: InputDecoration(
                hintText: 'Search 85+ foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(foodSearchProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: search.category == null,
                  onTap: () => ref.read(foodSearchProvider.notifier).setCategory(null),
                ),
                ...FoodCategory.values.map((c) => _CategoryChip(
                  label: c.displayName,
                  selected: search.category == c,
                  onTap: () => ref.read(foodSearchProvider.notifier).setCategory(
                    search.category == c ? null : c,
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Text('${foods.length} items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return _FoodListTile(
                  food: food,
                  onTap: () => _showQuantitySheet(food),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 20),
                  duration: const Duration(milliseconds: 150),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.white24),
          ),
          child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? Colors.black : Colors.white70,
            )),
        ),
      ),
    );
  }
}

class _FoodListTile extends StatelessWidget {
  const _FoodListTile({required this.food, required this.onTap});
  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: food.imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 52, height: 52,
                  color: Colors.white.withOpacity(0.05),
                  child: const Icon(Icons.restaurant, color: Colors.white24),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 52, height: 52,
                  color: Colors.white.withOpacity(0.05),
                  child: const Icon(Icons.restaurant, color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('per 100g',
                    style: TextStyle(fontSize: 11, color: Colors.white54)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MacroChip('P', food.proteinPer100g, const Color(0xFF4FC3F7)),
                      const SizedBox(width: 6),
                      _MacroChip('C', food.carbsPer100g, const Color(0xFFFFB74D)),
                      const SizedBox(width: 6),
                      _MacroChip('F', food.fatPer100g, const Color(0xFFF06292)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${food.caloriesPer100g.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('kcal', style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label ${value.toStringAsFixed(1)}g',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

/// Bottom sheet for entering quantity with animated macro preview.
class _QuantitySheet extends StatefulWidget {
  const _QuantitySheet({required this.food, required this.onConfirm});
  final FoodItem food;
  final void Function(double grams) onConfirm;

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  double _grams = 100;
  final _controller = TextEditingController(text: '100');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final macros = widget.food.macrosForGrams(_grams);

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.food.imageUrl,
                  width: 48, height: 48, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 48, height: 48,
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.restaurant, color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.food.category.displayName,
                      style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quantity input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Grams',
                    suffixText: 'g',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed > 0) {
                      setState(() => _grams = parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Quick amount buttons
              ...([50.0, 100.0, 150.0, 200.0]).map((g) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _grams = g);
                    _controller.text = g.toInt().toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: _grams == g
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _grams == g
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white12,
                      ),
                    ),
                    child: Text('${g.toInt()}g',
                      style: TextStyle(
                        fontSize: 11,
                        color: _grams == g
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white54,
                      )),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          // Animated macro display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _MacroRow(macros: macros, key: ValueKey(_grams)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(_grams),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add ${_grams.toInt()}g of ${widget.food.name}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.macros, super.key});
  final FoodMacros macros;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MacroStat('Calories', macros.calories.toStringAsFixed(0), 'kcal', const Color(0xFFFFD54F)),
        _MacroStat('Protein', macros.protein.toStringAsFixed(1), 'g', const Color(0xFF4FC3F7)),
        _MacroStat('Carbs', macros.carbs.toStringAsFixed(1), 'g', const Color(0xFFFFB74D)),
        _MacroStat('Fat', macros.fat.toStringAsFixed(1), 'g', const Color(0xFFF06292)),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 150)).scale(begin: const Offset(0.95, 0.95));
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat(this.label, this.value, this.unit, this.color);
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}

/// Dialog for creating custom food with validation
class _CreateCustomFoodDialog extends ConsumerStatefulWidget {
  const _CreateCustomFoodDialog({required this.onFoodCreated});
  final void Function(FoodItemFull food) onFoodCreated;

  @override
  ConsumerState<_CreateCustomFoodDialog> createState() => _CreateCustomFoodDialogState();
}

class _CreateCustomFoodDialogState extends ConsumerState<_CreateCustomFoodDialog> {
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
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  Future<void> _saveCustomFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Create custom food entity
      final customFood = FoodItemFull(
        id: 'custom_${const Uuid().v4()}',
        name: _nameController.text.trim(),
        category: _selectedCategory.displayName.toLowerCase(),
        macros: MacrosPer100g(
          calories: double.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fats: double.parse(_fatController.text),
        ),
        micros: MicrosPer100g(
          fiber: 0,
          sugar: 0,
          sodium: 0,
          potassium: 0,
        ),
        vitamins: VitaminsPer100g(
          vitaminA: 0,
          vitaminB: 0,
          vitaminC: 0,
          vitaminD: 0,
          vitaminE: 0,
        ),
        minerals: MineralsPer100g(
          calcium: 0,
          iron: 0,
          magnesium: 0,
          zinc: 0,
        ),
        imageUrl: '',
        dietaryTags: [],
      );

      // Add to custom foods via notifier (instant UI update)
      await ref.read(customFoodsProvider.notifier).addCustomFood(customFood);

      if (mounted) {
        widget.onFoodCreated(customFood);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create custom food: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Text('Create Custom Food'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g., Homemade Protein Shake',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateRequired(v, 'Food name'),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: FoodCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Macros section
              const Text(
                'Macros (per 100g)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),

              // Calories
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: 'Calories',
                  suffixText: 'kcal',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) => _validateNumber(v, 'Calories'),
              ),
              const SizedBox(height: 12),

              // Protein
              TextFormField(
                controller: _proteinController,
                decoration: InputDecoration(
                  labelText: 'Protein',
                  suffixText: 'g',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) => _validateNumber(v, 'Protein'),
              ),
              const SizedBox(height: 12),

              // Carbs
              TextFormField(
                controller: _carbsController,
                decoration: InputDecoration(
                  labelText: 'Carbs',
                  suffixText: 'g',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) => _validateNumber(v, 'Carbs'),
              ),
              const SizedBox(height: 12),

              // Fat
              TextFormField(
                controller: _fatController,
                decoration: InputDecoration(
                  labelText: 'Fat',
                  suffixText: 'g',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) => _validateNumber(v, 'Fat'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveCustomFood,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
