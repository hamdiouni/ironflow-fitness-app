import 'package:flutter/material.dart';
import '../design_lab_theme.dart';
import '../widgets/motion_widgets.dart';

class PreviewComponentSheet extends StatefulWidget {
  final DesignTokens tokens;

  const PreviewComponentSheet({
    super.key,
    required this.tokens,
  });

  @override
  State<PreviewComponentSheet> createState() => _PreviewComponentSheetState();
}

class _PreviewComponentSheetState extends State<PreviewComponentSheet> {
  int _selectedChip = 0;
  final TextEditingController _textController = TextEditingController(text: 'Bench Press');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'COMPONENT GALLERY',
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: tokens.accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Design System Tokens',
                style: TextStyle(
                  fontFamily: tokens.displayFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons Section
              _buildSectionTitle(tokens, 'Buttons & Actions'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AnimatedScaleButton(
                      onPressed: () {},
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: tokens.accent,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Primary Button',
                          style: TextStyle(color: tokens.onAccent, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedScaleButton(
                      onPressed: () {},
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: tokens.elevated,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Secondary',
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AnimatedScaleButton(
                      onPressed: () {},
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Outlined',
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedScaleButton(
                      onPressed: () {},
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: tokens.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Destructive',
                          style: TextStyle(color: tokens.error, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Inputs Section
              _buildSectionTitle(tokens, 'Form Inputs & Fields'),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                style: TextStyle(color: tokens.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
                  labelStyle: TextStyle(color: tokens.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: tokens.panel,
                  prefixIcon: Icon(Icons.search, color: tokens.textSecondary, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    borderSide: BorderSide(color: tokens.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    borderSide: BorderSide(color: tokens.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    borderSide: BorderSide(color: tokens.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Chips & Badges
              _buildSectionTitle(tokens, 'Chips & Radii Geometry'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(4, (index) {
                  final labels = ['Strength', 'Hypertrophy', 'Cardio', 'Mobility'];
                  final isSelected = _selectedChip == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedChip = index),
                    child: AnimatedContainer(
                      duration: tokens.durationQuick,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.accent : tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.chipRadius),
                        border: Border.all(color: isSelected ? tokens.accent : tokens.borderSubtle),
                      ),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected ? tokens.onAccent : tokens.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Feedback Elements: SnackBar & Dialog Trigger
              _buildSectionTitle(tokens, 'Interactive Feedback'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AnimatedScaleButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: tokens.elevated,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(tokens.cardRadius),
                              side: BorderSide(color: tokens.borderSubtle),
                            ),
                            content: Text(
                              'Workout set logged (+100 kg)',
                              style: TextStyle(color: tokens.textPrimary),
                            ),
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: tokens.accent,
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Test SnackBar with Undo',
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedScaleButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: tokens.panel,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(tokens.cardRadius),
                              side: BorderSide(color: tokens.borderSubtle),
                            ),
                            title: Text('Discard Workout?', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w700)),
                            content: Text('Your active sets will not be saved.', style: TextStyle(color: tokens.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel', style: TextStyle(color: tokens.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Discard', style: TextStyle(color: tokens.error, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.buttonRadius),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Show Dialog',
                          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Skeleton Preview
              _buildSectionTitle(tokens, 'Skeleton Loading State'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: tokens.elevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tokens.elevated.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        color: tokens.elevated.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Empty State Preview
              _buildSectionTitle(tokens, 'Empty State Pattern'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.cardRadius),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 40, color: tokens.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'No Custom Workouts',
                      style: TextStyle(
                        fontFamily: tokens.displayFont,
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a routine or explore curated programs.',
                      style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(DesignTokens tokens, String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: tokens.displayFont,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: tokens.textSecondary,
      ),
    );
  }
}
