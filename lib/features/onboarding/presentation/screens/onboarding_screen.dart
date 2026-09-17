import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/ironflow_logo.dart';
import '../../../nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import '../../../nutrition/presentation/providers/diet_plan_providers.dart';
import '../../../workout/domain/usecases/generate_workout_program_use_case.dart';
import '../../../workout/presentation/providers/active_program_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Collected values
  FitnessGoal? _goal;
  int _age = 25;
  double _weight = 75;
  double _height = 175;
  FitnessLevel _fitnessLevel = FitnessLevel.beginner;
  EquipmentType _equipment = EquipmentType.gym;
  int _daysPerWeek = 3;
  BudgetLevel _budget = BudgetLevel.medium;

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _finish() async {
    if (_goal == null) return;
    
    final profile = UserProfile(
      goal: _goal!,
      age: _age,
      weightKg: _weight,
      heightCm: _height,
      fitnessLevel: _fitnessLevel,
      equipment: _equipment,
      workoutDaysPerWeek: _daysPerWeek,
      budget: _budget,
    );

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating your personalized program...'),
            ],
          ),
        ),
      );
    }

    try {
      // Save user profile
      await ref.read(onboardingNotifierProvider.notifier).completeOnboarding(profile);

      // Generate and set active program
      final generateWorkoutUseCase = GenerateWorkoutProgramUseCase();
      final workoutProgram = generateWorkoutUseCase(userProfile: profile);
      await ref.read(activeProgramProvider.notifier).setActiveProgram(workoutProgram);

      // Generate and save diet plan
      final generateDietUseCase = GenerateDietPlanUseCase();
      final dietPlan = generateDietUseCase(profile);
      
      // Get the save diet plan use case from the provider
      final saveDietUseCase = ref.read(saveDietPlanUseCaseProvider);
      await saveDietUseCase(dietPlan);

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Invalidate providers and navigate
        ref.invalidate(isOnboardedProvider);
        ref.invalidate(userProfileProvider);
        context.go(AppRoutes.workout);
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _canProceed {
    if (_currentPage == 0) return _goal != null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _currentPage, total: 6),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _GoalPage(
                    selected: _goal,
                    onSelect: (g) => setState(() => _goal = g),
                  ),
                  _BodyInfoPage(
                    age: _age,
                    weight: _weight,
                    height: _height,
                    onAgeChanged: (v) => setState(() => _age = v),
                    onWeightChanged: (v) => setState(() => _weight = v),
                    onHeightChanged: (v) => setState(() => _height = v),
                  ),
                  _FitnessLevelPage(
                    selected: _fitnessLevel,
                    onSelect: (l) => setState(() => _fitnessLevel = l),
                  ),
                  _EquipmentPage(
                    selected: _equipment,
                    onSelect: (e) => setState(() => _equipment = e),
                  ),
                  _FrequencyPage(
                    days: _daysPerWeek,
                    onChanged: (d) => setState(() => _daysPerWeek = d),
                  ),
                  _BudgetPage(
                    selected: _budget,
                    onSelect: (b) => setState(() => _budget = b),
                  ),
                ],
              ),
            ),
            _NavigationButtons(
              currentPage: _currentPage,
              canProceed: _canProceed,
              onNext: _nextPage,
              onBack: _prevPage,
              isLast: _currentPage == 5,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Bar ────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${current + 1} of $total',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                '${((current + 1) / total * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / total,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navigation Buttons ──────────────────────────────────────────────────────

class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons({
    required this.currentPage,
    required this.canProceed,
    required this.onNext,
    required this.onBack,
    required this.isLast,
  });
  final int currentPage;
  final bool canProceed;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          if (currentPage > 0) const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: canProceed ? AppTheme.primaryColor : AppTheme.textDisabled,
              ),
              child: Text(
                isLast ? 'Get Started 🚀' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 1: Goal ────────────────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  const _GoalPage({required this.selected, required this.onSelect});
  final FitnessGoal? selected;
  final ValueChanged<FitnessGoal> onSelect;

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      title: 'What\'s your goal?',
      subtitle: 'We\'ll build your personalized plan around this',
      child: Column(
        children: FitnessGoal.values.map((goal) {
          final isSelected = selected == goal;
          return _SelectionCard(
            emoji: goal.emoji,
            title: goal.displayName,
            subtitle: goal.description,
            isSelected: isSelected,
            onTap: () => onSelect(goal),
          ).animate().fadeIn(delay: (FitnessGoal.values.indexOf(goal) * 100).ms);
        }).toList(),
      ),
    );
  }
}

// ─── Page 2: Body Info ───────────────────────────────────────────────────────

class _BodyInfoPage extends StatelessWidget {
  const _BodyInfoPage({
    required this.age,
    required this.weight,
    required this.height,
    required this.onAgeChanged,
    required this.onWeightChanged,
    required this.onHeightChanged,
  });
  final int age;
  final double weight;
  final double height;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      title: 'Tell us about yourself',
      subtitle: 'Used to calculate your calorie targets',
      child: Column(
        children: [
          _SliderCard(
            label: 'Age',
            value: age.toDouble(),
            min: 15,
            max: 80,
            unit: 'years',
            divisions: 65,
            onChanged: (v) => onAgeChanged(v.toInt()),
          ).animate().fadeIn(delay: 0.ms),
          const SizedBox(height: AppTheme.spacingMedium),
          _SliderCard(
            label: 'Weight',
            value: weight,
            min: 40,
            max: 200,
            unit: 'kg',
            divisions: 160,
            onChanged: onWeightChanged,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppTheme.spacingMedium),
          _SliderCard(
            label: 'Height',
            value: height,
            min: 140,
            max: 220,
            unit: 'cm',
            divisions: 80,
            onChanged: onHeightChanged,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

// ─── Page 3: Fitness Level ───────────────────────────────────────────────────

class _FitnessLevelPage extends StatelessWidget {
  const _FitnessLevelPage({required this.selected, required this.onSelect});
  final FitnessLevel selected;
  final ValueChanged<FitnessLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      title: 'Your fitness level?',
      subtitle: 'We\'ll adjust workout intensity accordingly',
      child: Column(
        children: FitnessLevel.values.map((level) {
          return _SelectionCard(
            emoji: switch (level) {
              FitnessLevel.beginner => '🌱',
              FitnessLevel.intermediate => '⚡',
              FitnessLevel.advanced => '🔥',
            },
            title: level.displayName,
            subtitle: level.description,
            isSelected: selected == level,
            onTap: () => onSelect(level),
          ).animate().fadeIn(delay: (FitnessLevel.values.indexOf(level) * 100).ms);
        }).toList(),
      ),
    );
  }
}

// ─── Page 4: Equipment ───────────────────────────────────────────────────────

class _EquipmentPage extends StatelessWidget {
  const _EquipmentPage({required this.selected, required this.onSelect});
  final EquipmentType selected;
  final ValueChanged<EquipmentType> onSelect;

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      title: 'What equipment do you have?',
      subtitle: 'We\'ll only suggest exercises you can do',
      child: Column(
        children: EquipmentType.values.map((eq) {
          return _SelectionCard(
            emoji: eq == EquipmentType.gym ? '🏋️' : '🏠',
            title: eq.displayName,
            subtitle: eq.description,
            isSelected: selected == eq,
            onTap: () => onSelect(eq),
          ).animate().fadeIn(delay: (EquipmentType.values.indexOf(eq) * 100).ms);
        }).toList(),
      ),
    );
  }
}

// ─── Page 5: Frequency ───────────────────────────────────────────────────────

class _FrequencyPage extends StatelessWidget {
  const _FrequencyPage({required this.days, required this.onChanged});
  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      title: 'How often will you train?',
      subtitle: 'We\'ll schedule your workouts accordingly',
      child: Column(
        children: [
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              children: [
                Text(
                  '$days',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Text(
                  'days per week',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Slider(
                  value: days.toDouble(),
                  min: 2,
                  max: 6,
                  divisions: 4,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) => onChanged(v.toInt()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('2 days', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                    Text('6 days', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(),
        ],
      ),
    );
  }
}

// ─── Page 6: Budget ──────────────────────────────────────────────────────────

class _BudgetPage extends StatelessWidget {
  const _BudgetPage({required this.selected, required this.onSelect});
  final BudgetLevel selected;
  final ValueChanged<BudgetLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      title: 'Your food budget?',
      subtitle: 'We\'ll suggest meals that fit your budget',
      child: Column(
        children: BudgetLevel.values.map((b) {
          return _SelectionCard(
            emoji: switch (b) {
              BudgetLevel.low => '💰',
              BudgetLevel.medium => '💳',
              BudgetLevel.high => '💎',
            },
            title: b.displayName,
            subtitle: b.description,
            isSelected: selected == b,
            onTap: () => onSelect(b),
          ).animate().fadeIn(delay: (BudgetLevel.values.indexOf(b) * 100).ms);
        }).toList(),
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _PageWrapper extends StatelessWidget {
  const _PageWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppTheme.spacingXLarge),
          child,
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.divisions,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${value.toInt()} $unit',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
