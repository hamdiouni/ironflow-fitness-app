import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/domain/splits/entities/split.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_catalog.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_schedule_builder.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/split_generator/exercise_swap_sheet.dart';
import '../widgets/onboarding_shared_widgets.dart';
import '../widgets/onboarding_step7_summary.dart';
import '../widgets/onboarding_steps_early.dart';
import '../widgets/onboarding_steps_schedule.dart';

/// Stripe Guided 7-Step Onboarding Stepper.
///
/// Steps:
/// 1. Goal (Lose fat, Gain muscle, Maintain)
/// 2. About You (Sex, Age, Height, Weight with unit selection & safety validation)
/// 3. Training Place (Commercial Gym vs Home, with equipment options)
/// 4. Weekly Frequency & Split (2 to 6 days/week, auto-recommended or custom split)
/// 5. Experience Level (Beginner, Intermediate, Advanced)
/// 6. Nutrition Budget (Low, Medium, High)
/// 7. Ready-to-Start Plan (Computed Targets, Pre-selected exercises with optional swap)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 7;
  static const _scheduleBuilder = SplitScheduleBuilder();

  // Step 1: Goal
  FitnessGoal? _goal = FitnessGoal.gainMuscle;

  // Step 2: About You
  BiologicalSex _sex = BiologicalSex.preferNotToSay;
  int _age = 25;
  double _weightKg = 75.0;
  double _heightCm = 175.0;
  bool _isImperial = false;

  // Step 3: Training Place
  EquipmentType _equipment = EquipmentType.gym;
  String _homeEquipment = 'dumbbells'; // 'none', 'dumbbells', 'bands'

  // Step 4: Weekly Frequency & Split Selection
  int _daysPerWeek = 4;
  String? _chosenSplitId;

  // Step 5: Experience Level
  FitnessLevel _fitnessLevel = FitnessLevel.beginner;

  // Step 6: Diet Budget
  BudgetLevel _budget = BudgetLevel.medium;

  // Step 7: Optional Diet Plan Suggestion (Outcome 3)
  bool _includeDietPlan = true;

  // Local exercise customizations per day (dayNumber -> list of exercises)
  final Map<int, List<ProgramExercise>> _customizedExercises = {};

  // Synthesis state
  bool _isSynthesizing = false;
  String? _synthesisError;

  Split _getEffectiveSplit() {
    if (_chosenSplitId != null) {
      final catalogSplit = SplitCatalog.findById(_chosenSplitId!);
      if (catalogSplit != null) return catalogSplit;
    }
    return SplitCatalog.getRecommendedSplitForDays(_daysPerWeek);
  }

  WorkoutProgram _buildProgramForCurrentSettings(UserProfile profile) {
    final split = _getEffectiveSplit();
    final rawProgram = _scheduleBuilder.buildProgram(
      split: split,
      daysPerWeek: _daysPerWeek,
      profile: profile,
    );

    if (_customizedExercises.isEmpty) {
      return rawProgram;
    }

    final updatedDays = rawProgram.days.map((day) {
      if (_customizedExercises.containsKey(day.dayNumber)) {
        return day.copyWith(exercises: _customizedExercises[day.dayNumber]!);
      }
      return day;
    }).toList();

    return rawProgram.copyWith(days: updatedDays);
  }

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    try {
      final userId = ref.read(authNotifierProvider).user?.id;
      final storage = ref.read(userProfileStorageProvider);
      final draft = await storage.getDraft(userId: userId);
      if (draft != null && mounted) {
        setState(() {
          if (draft['goal'] != null) {
            _goal = FitnessGoal.values.byName(draft['goal'] as String);
          }
          if (draft['sex'] != null) {
            _sex = BiologicalSex.values.byName(draft['sex'] as String);
          }
          if (draft['age'] != null) {
            _age = draft['age'] as int;
          }
          if (draft['weightKg'] != null) {
            _weightKg = (draft['weightKg'] as num).toDouble();
          }
          if (draft['heightCm'] != null) {
            _heightCm = (draft['heightCm'] as num).toDouble();
          }
          if (draft['isImperial'] != null) {
            _isImperial = draft['isImperial'] as bool;
          }
          if (draft['equipment'] != null) {
            _equipment = EquipmentType.values.byName(draft['equipment'] as String);
          }
          if (draft['homeEquipment'] != null) {
            _homeEquipment = draft['homeEquipment'] as String;
          }
          if (draft['daysPerWeek'] != null) {
            _daysPerWeek = draft['daysPerWeek'] as int;
          }
          if (draft['fitnessLevel'] != null) {
            _fitnessLevel = FitnessLevel.values.byName(draft['fitnessLevel'] as String);
          }
          if (draft['budget'] != null) {
            _budget = BudgetLevel.values.byName(draft['budget'] as String);
          }
          if (draft['chosenSplitId'] != null) {
            _chosenSplitId = draft['chosenSplitId'] as String;
          }
          if (draft['includeDietPlan'] != null) {
            _includeDietPlan = draft['includeDietPlan'] as bool;
          }

          final savedStep = draft['draft_step'] as int? ?? 0;
          if (savedStep > 0 && savedStep < _totalSteps) {
            _currentStep = savedStep;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(_currentStep);
              }
            });
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [Onboarding] Error restoring draft: $e');
      }
    }
  }

  Future<void> _saveDraft() async {
    try {
      final userId = ref.read(authNotifierProvider).user?.id;
      final storage = ref.read(userProfileStorageProvider);
      await storage.saveDraft(
        step: _currentStep,
        userId: userId,
        data: {
          'goal': _goal?.name,
          'sex': _sex.name,
          'age': _age,
          'weightKg': _weightKg,
          'heightCm': _heightCm,
          'isImperial': _isImperial,
          'equipment': _equipment.name,
          'homeEquipment': _homeEquipment,
          'daysPerWeek': _daysPerWeek,
          'chosenSplitId': _chosenSplitId,
          'fitnessLevel': _fitnessLevel.name,
          'budget': _budget.name,
          'includeDietPlan': _includeDietPlan,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [Onboarding] Error saving draft: $e');
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      AppHaptics.shared.selectionChanged();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
      );
      _saveDraft();
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      AppHaptics.shared.selectionChanged();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0: // Goal
        return _goal != null;
      case 1: // About You
        return _age >= 14 && _age <= 100 && _weightKg >= 30 && _weightKg <= 300 && _heightCm >= 100 && _heightCm <= 250;
      case 2: // Equipment
      case 3: // Frequency
      case 4: // Experience
      case 5: // Budget
      case 6: // Summary
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleSignOut() async {
    final tokens = AppThemeTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          'SIGN OUT',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
        content: Text(
          'Sign out of your session? Your onboarding progress is securely saved.',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13,
            color: tokens.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCEL', style: TextStyle(color: tokens.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('SIGN OUT', style: TextStyle(color: tokens.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isSynthesizing = true;
      _synthesisError = null;
    });

    try {
      final profile = UserProfile(
        goal: _goal ?? FitnessGoal.gainMuscle,
        age: _age,
        weightKg: _weightKg,
        heightCm: _heightCm,
        fitnessLevel: _fitnessLevel,
        equipment: _equipment,
        workoutDaysPerWeek: _daysPerWeek,
        budget: _budget,
        sex: _sex,
      );

      final program = _buildProgramForCurrentSettings(profile);
      final userId = ref.read(authNotifierProvider).user?.id;
      await ref.read(onboardingNotifierProvider.notifier).completeOnboarding(
            profile,
            userId: userId,
            customProgram: program,
            chosenSplit: _chosenSplitId != null ? _getEffectiveSplit() : null,
            includeDietPlan: _includeDietPlan,
          );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSynthesizing = false;
          _synthesisError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(tokens),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentStep = page),
                    children: [
                      OnboardingStep1Goal(
                        tokens: tokens,
                        goal: _goal,
                        onGoalChanged: (g) {
                          setState(() => _goal = g);
                          _saveDraft();
                        },
                      ),
                      OnboardingStep2AboutYou(
                        tokens: tokens,
                        sex: _sex,
                        age: _age,
                        weightKg: _weightKg,
                        heightCm: _heightCm,
                        isImperial: _isImperial,
                        goal: _goal,
                        onSexChanged: (s) {
                          setState(() => _sex = s);
                          _saveDraft();
                        },
                        onImperialChanged: (imp) {
                          setState(() => _isImperial = imp);
                          _saveDraft();
                        },
                        onAgeChanged: (a) {
                          setState(() => _age = a);
                          _saveDraft();
                        },
                        onHeightCmChanged: (h) {
                          setState(() => _heightCm = h);
                          _saveDraft();
                        },
                        onWeightKgChanged: (w) {
                          setState(() => _weightKg = w);
                          _saveDraft();
                        },
                      ),
                      OnboardingStep3TrainingPlace(
                        tokens: tokens,
                        equipment: _equipment,
                        homeEquipment: _homeEquipment,
                        onEquipmentChanged: (e) {
                          setState(() => _equipment = e);
                          _saveDraft();
                        },
                        onHomeEquipmentChanged: (he) {
                          setState(() => _homeEquipment = he);
                          _saveDraft();
                        },
                      ),
                      OnboardingStep4Frequency(
                        tokens: tokens,
                        daysPerWeek: _daysPerWeek,
                        chosenSplitId: _chosenSplitId,
                        onDaysChanged: (days) {
                          setState(() {
                            _daysPerWeek = days;
                            _customizedExercises.clear();
                          });
                          _saveDraft();
                        },
                        onSplitChosen: (splitId) {
                          setState(() {
                            _chosenSplitId = splitId;
                            _customizedExercises.clear();
                          });
                          _saveDraft();
                        },
                      ),
                      OnboardingStep5Experience(
                        tokens: tokens,
                        fitnessLevel: _fitnessLevel,
                        onLevelChanged: (l) {
                          setState(() => _fitnessLevel = l);
                          _saveDraft();
                        },
                      ),
                      OnboardingStep6Budget(
                        tokens: tokens,
                        budget: _budget,
                        onBudgetChanged: (b) {
                          setState(() => _budget = b);
                          _saveDraft();
                        },
                      ),
                      Builder(
                        builder: (_) {
                          final tempProfile = UserProfile(
                            goal: _goal ?? FitnessGoal.gainMuscle,
                            age: _age,
                            weightKg: _weightKg,
                            heightCm: _heightCm,
                            fitnessLevel: _fitnessLevel,
                            equipment: _equipment,
                            workoutDaysPerWeek: _daysPerWeek,
                            budget: _budget,
                            sex: _sex,
                          );
                          return OnboardingStep7Summary(
                            tokens: tokens,
                            tempProfile: tempProfile,
                            program: _buildProgramForCurrentSettings(tempProfile),
                            includeDietPlan: _includeDietPlan,
                            synthesisError: _synthesisError,
                            onSwapExercise: _openSwapSheetForOnboarding,
                            onToggleDietPlan: (val) =>
                                setState(() => _includeDietPlan = val),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                OnboardingBottomNavigation(
                  tokens: tokens,
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  canProceed: _canProceed,
                  onPrevious: _previousStep,
                  onNext: _nextStep,
                ),
              ],
            ),
            if (_isSynthesizing) OnboardingSynthesisOverlay(tokens: tokens),
          ],
        ),
      ),
    );
  }

  // ─── Header & Progress Bar ───────────────────────────────────────────────────

  Widget _buildHeader(AppThemeTokens tokens) {
    final stepNumber = (_currentStep + 1).toString().padLeft(2, '0');
    final totalSteps = _totalSteps.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: tokens.kineticAccent.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SET UP YOUR PROFILE',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.card,
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: Text(
                      'STEP $stepNumber // $totalSteps',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.kineticAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.logout_rounded, color: tokens.textMuted, size: 18),
                    tooltip: 'Sign Out',
                    visualDensity: VisualDensity.compact,
                    onPressed: _handleSignOut,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Segmented Progress Bar
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isActive = index == _currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? tokens.kineticAccent
                        : isActive
                            ? tokens.kineticAccent.withValues(alpha: 0.85)
                            : tokens.borderSubtle,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  void _openSwapSheetForOnboarding(ProgramDay day, int exerciseIndex, ProgramExercise currentEx) {
    ExerciseSwapSheet.show(
      context: context,
      currentExercise: currentEx,
      equipment: _equipment,
      onSelected: (newExerciseName) {
        final oldName = currentEx.exerciseName;
        final currentExercises = List<ProgramExercise>.from(
          _customizedExercises[day.dayNumber] ?? day.exercises,
        );
        currentExercises[exerciseIndex] = currentEx.copyWith(exerciseName: newExerciseName);

        setState(() {
          _customizedExercises[day.dayNumber] = currentExercises;
        });
        _saveDraft();

          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Swapped $oldName for $newExerciseName'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'UNDO',
                  textColor: Colors.amberAccent,
                  onPressed: () {
                    if (!mounted) return;
                    final revertedList = List<ProgramExercise>.from(
                      _customizedExercises[day.dayNumber] ?? day.exercises,
                    );
                    revertedList[exerciseIndex] = currentEx;
                    setState(() {
                      _customizedExercises[day.dayNumber] = revertedList;
                    });
                    _saveDraft();
                  },
                ),
              ),
            );
          }
        },
    );
  }

}
