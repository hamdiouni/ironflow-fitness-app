import 'package:flutter/material.dart';
import '../design_lab_fake_data.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewExerciseLibraryScreen extends StatefulWidget {
  final DesignTokens tokens;
  final ValueChanged<String>? onSelectExercise;

  const PreviewExerciseLibraryScreen({
    super.key,
    required this.tokens,
    this.onSelectExercise,
  });

  @override
  State<PreviewExerciseLibraryScreen> createState() => _PreviewExerciseLibraryScreenState();
}

class _PreviewExerciseLibraryScreenState extends State<PreviewExerciseLibraryScreen> {
  String _selectedMuscle = 'All';
  bool _isGrid = true;

  final List<String> _filters = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms'];

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Pinned Search & Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exercises',
                        style: TextStyle(
                          fontFamily: tokens.displayFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded, color: tokens.textSecondary),
                        onPressed: () => setState(() => _isGrid = !_isGrid),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: tokens.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Search 150+ exercises...',
                          style: TextStyle(color: tokens.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Filter Chips Row
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final f = _filters[index];
                  final isSelected = f == _selectedMuscle;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedScaleButton(
                      onPressed: () => setState(() => _selectedMuscle = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? tokens.accent : tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.chipRadius),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f,
                          style: TextStyle(
                            color: isSelected ? tokens.onAccent : tokens.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Exercise Cards Grid / List
            Expanded(
              child: _isGrid ? _buildGrid(tokens) : _buildList(tokens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(DesignTokens tokens) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: FakeData.exerciseCatalog.length,
      itemBuilder: (context, index) {
        final item = FakeData.exerciseCatalog[index];
        return AnimatedScaleButton(
          onPressed: () => widget.onSelectExercise?.call(item['name']!),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tokens.elevated,
                    borderRadius: BorderRadius.circular(tokens.chipRadius),
                  ),
                  child: Icon(Icons.fitness_center, color: tokens.accent, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: tokens.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['muscle']!,
                      style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(DesignTokens tokens) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: FakeData.exerciseCatalog.length,
      itemBuilder: (context, index) {
        final item = FakeData.exerciseCatalog[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedScaleButton(
            onPressed: () => widget.onSelectExercise?.call(item['name']!),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.cardRadius),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tokens.elevated,
                      borderRadius: BorderRadius.circular(tokens.chipRadius),
                    ),
                    child: Icon(Icons.fitness_center, color: tokens.accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: tokens.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${item['muscle']} • ${item['equipment']}', style: TextStyle(color: tokens.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: tokens.textMuted, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

