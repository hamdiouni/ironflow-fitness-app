import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Monolithic Sci-Fi Guided 7-Step Onboarding Stepper.
///
/// Steps:
/// 1. Goal (Lose fat, Gain muscle, Maintain)
/// 2. About You (Sex, Age, Height, Weight with unit selection & safety validation)
/// 3. Training Place (Commercial Gym vs Home, with equipment options)
/// 4. Weekly Frequency (2 to 6 days/week)
/// 5. Experience Level (Beginner, Intermediate, Advanced)
/// 6. Nutrition Budget (Low, Medium, High)
/// 7. Protocol Summary (Computed BMR, TDEE, Calorie/Macro targets, recommended program, and Start)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 7;

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

  // Step 4: Weekly Frequency
  int _daysPerWeek = 4;

  // Step 5: Experience Level
  FitnessLevel _fitnessLevel = FitnessLevel.beginner;

  // Step 6: Diet Budget
  BudgetLevel _budget = BudgetLevel.medium;

  // Synthesis state
  bool _isSynthesizing = false;
  String? _synthesisError;

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
        print('⚠️ [Onboarding] Error restoring draft: $e');
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
          'fitnessLevel': _fitnessLevel.name,
          'budget': _budget.name,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Onboarding] Error saving draft: $e');
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

      final userId = ref.read(authNotifierProvider).user?.id;
      await ref.read(onboardingNotifierProvider.notifier).completeOnboarding(
            profile,
            userId: userId,
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
                      _buildStep1Goal(tokens),
                      _buildStep2AboutYou(tokens),
                      _buildStep3TrainingPlace(tokens),
                      _buildStep4Frequency(tokens),
                      _buildStep5Experience(tokens),
                      _buildStep6Budget(tokens),
                      _buildStep7Summary(tokens),
                    ],
                  ),
                ),
                _buildBottomNavigation(tokens),
              ],
            ),
            if (_isSynthesizing) _buildSynthesisOverlay(tokens),
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
                    'INITIALIZE // OPERATOR PROFILE',
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
                      borderRadius: BorderRadius.circular(4),
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

  // ─── Step 1: Goal ────────────────────────────────────────────────────────────

  Widget _buildStep1Goal(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'PRIMARY GOAL',
      whyWeAsk: 'Calibrates your daily energy expenditure baseline and macronutrient ratio.',
      children: [
        _buildSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.loseWeight,
          groupValue: _goal,
          code: 'DIRECTIVE // 01',
          title: 'LOSE FAT',
          subtitle: 'Moderate caloric deficit designed to maximize fat oxidation while preserving lean muscle.',
          icon: Icons.local_fire_department_rounded,
          onSelect: (g) {
            setState(() => _goal = g);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.gainMuscle,
          groupValue: _goal,
          code: 'DIRECTIVE // 02',
          title: 'GAIN MUSCLE',
          subtitle: 'Targeted caloric surplus optimized for hypertrophy, strength gains, and recovery.',
          icon: Icons.fitness_center_rounded,
          onSelect: (g) {
            setState(() => _goal = g);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.maintain,
          groupValue: _goal,
          code: 'DIRECTIVE // 03',
          title: 'MAINTAIN',
          subtitle: 'Nutritional equilibrium to sustain current body composition, health, and fitness.',
          icon: Icons.balance_rounded,
          onSelect: (g) {
            setState(() => _goal = g);
            _saveDraft();
          },
        ),
      ],
    );
  }

  // ─── Step 2: About You (Physical Stats) ───────────────────────────────────────

  Widget _buildStep2AboutYou(AppThemeTokens tokens) {
    final displayWeight = _isImperial
        ? (_weightKg * 2.20462).round().toDouble()
        : _weightKg.round().toDouble();
    final weightUnit = _isImperial ? 'LBS' : 'KG';

    final displayHeight = _isImperial
        ? (_heightCm / 2.54).round().toDouble()
        : _heightCm.round().toDouble();
    final heightUnit = _isImperial ? 'IN' : 'CM';

    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    final isUnderweight = bmi < 18.5;
    final isMinor = _age < 18;

    return _StepContentLayout(
      stepTitle: 'ABOUT YOU',
      whyWeAsk: 'Powers the Mifflin-St Jeor metabolic expenditure equation for exact targets.',
      children: [
        // Biological Sex Selection
        _buildContainerBox(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BIOLOGICAL SEX (FOR BMR CALCULATION)',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildUnitChip(
                      tokens,
                      label: 'MALE',
                      isSelected: _sex == BiologicalSex.male,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        setState(() => _sex = BiologicalSex.male);
                        _saveDraft();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildUnitChip(
                      tokens,
                      label: 'FEMALE',
                      isSelected: _sex == BiologicalSex.female,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        setState(() => _sex = BiologicalSex.female);
                        _saveDraft();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildUnitChip(
                      tokens,
                      label: 'PREFER NOT TO SAY',
                      isSelected: _sex == BiologicalSex.preferNotToSay,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        setState(() => _sex = BiologicalSex.preferNotToSay);
                        _saveDraft();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Measurement System Toggle
        _buildContainerBox(
          tokens: tokens,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEASUREMENT SYSTEM',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
              ),
              Row(
                children: [
                  _buildUnitChip(tokens, label: 'METRIC', isSelected: !_isImperial, onTap: () {
                    AppHaptics.shared.selectionChanged();
                    setState(() => _isImperial = false);
                    _saveDraft();
                  }),
                  const SizedBox(width: 6),
                  _buildUnitChip(tokens, label: 'IMPERIAL', isSelected: _isImperial, onTap: () {
                    AppHaptics.shared.selectionChanged();
                    setState(() => _isImperial = true);
                    _saveDraft();
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Age, Height, Weight Controls
        _buildContainerBox(
          tokens: tokens,
          child: Column(
            children: [
              _buildMetricSlider(
                tokens: tokens,
                label: 'AGE',
                valueText: '$_age YEARS',
                value: _age.toDouble(),
                min: 14,
                max: 90,
                divisions: 76,
                onChanged: (val) {
                  setState(() => _age = val.toInt());
                  _saveDraft();
                },
              ),
              Divider(color: tokens.borderSubtle, height: 20),
              _buildMetricSlider(
                tokens: tokens,
                label: 'HEIGHT',
                valueText: '${displayHeight.toInt()} $heightUnit',
                value: displayHeight,
                min: _isImperial ? 47 : 120, // 47in (~120cm) to 87in (~220cm)
                max: _isImperial ? 87 : 220,
                divisions: _isImperial ? 40 : 100,
                onChanged: (val) {
                  setState(() {
                    if (_isImperial) {
                      _heightCm = val * 2.54;
                    } else {
                      _heightCm = val;
                    }
                  });
                  _saveDraft();
                },
              ),
              Divider(color: tokens.borderSubtle, height: 20),
              _buildMetricSlider(
                tokens: tokens,
                label: 'WEIGHT',
                valueText: '${displayWeight.toInt()} $weightUnit',
                value: displayWeight,
                min: _isImperial ? 66 : 35,
                max: _isImperial ? 440 : 200,
                divisions: _isImperial ? 187 : 165,
                onChanged: (val) {
                  setState(() {
                    if (_isImperial) {
                      _weightKg = val / 2.20462;
                    } else {
                      _weightKg = val;
                    }
                  });
                  _saveDraft();
                },
              ),
            ],
          ),
        ),

        // Safety notes if applicable
        if (isMinor) ...[
          const SizedBox(height: 12),
          _buildSafetyNotice(
            tokens: tokens,
            icon: Icons.info_outline_rounded,
            title: 'ADOLESCENT SAFETY GUARD',
            message: 'Users under 18 receive maintenance targets to support healthy biological growth. Always consult a guardian or healthcare professional.',
          ),
        ],

        if (isUnderweight && _goal == FitnessGoal.loseWeight) ...[
          const SizedBox(height: 12),
          _buildSafetyNotice(
            tokens: tokens,
            icon: Icons.shield_outlined,
            title: 'BMI HEALTH SAFEGUARD',
            message: 'Your current BMI is in the underweight range (<18.5). Calorie deficit has been clamped to maintenance for your safety.',
          ),
        ],
      ],
    );
  }

  // ─── Step 3: Training Place ──────────────────────────────────────────────────

  Widget _buildStep3TrainingPlace(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'TRAINING PLACE',
      whyWeAsk: 'Configures exercise movements and equipment matching what you have available.',
      children: [
        _buildSelectableCard<EquipmentType>(
          tokens: tokens,
          value: EquipmentType.gym,
          groupValue: _equipment,
          code: 'ENVIRONMENT // 01',
          title: 'COMMERCIAL GYM',
          subtitle: 'Full access to barbells, racks, dumbbells, cable columns, and machines.',
          icon: Icons.domain_rounded,
          onSelect: (e) {
            setState(() => _equipment = e);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<EquipmentType>(
          tokens: tokens,
          value: EquipmentType.home,
          groupValue: _equipment,
          code: 'ENVIRONMENT // 02',
          title: 'HOME TRAINING',
          subtitle: 'Bodyweight, dumbbells, and resistance bands suitable for home workouts.',
          icon: Icons.home_rounded,
          onSelect: (e) {
            setState(() => _equipment = e);
            _saveDraft();
          },
        ),
        if (_equipment == EquipmentType.home) ...[
          const SizedBox(height: 16),
          _buildContainerBox(
            tokens: tokens,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE HOME GEAR',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUnitChip(
                        tokens,
                        label: 'BODYWEIGHT',
                        isSelected: _homeEquipment == 'none',
                        onTap: () {
                          setState(() => _homeEquipment = 'none');
                          _saveDraft();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildUnitChip(
                        tokens,
                        label: 'DUMBBELLS',
                        isSelected: _homeEquipment == 'dumbbells',
                        onTap: () {
                          setState(() => _homeEquipment = 'dumbbells');
                          _saveDraft();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildUnitChip(
                        tokens,
                        label: 'BANDS',
                        isSelected: _homeEquipment == 'bands',
                        onTap: () {
                          setState(() => _homeEquipment = 'bands');
                          _saveDraft();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Step 4: Training Frequency ──────────────────────────────────────────────

  Widget _buildStep4Frequency(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'WEEKLY FREQUENCY',
      whyWeAsk: 'Determines your workout split schedule and physical activity expenditure multiplier.',
      children: [
        _buildContainerBox(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAYS PER WEEK',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: tokens.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$_daysPerWeek DAYS',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tokens.kineticAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [2, 3, 4, 5, 6].map((days) {
                  final isSelected = _daysPerWeek == days;
                  return InkWell(
                    onTap: () {
                      AppHaptics.shared.selectionChanged();
                      setState(() => _daysPerWeek = days);
                      _saveDraft();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 52,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.kineticAccent : tokens.canvas,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$days',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.black : tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                _getFrequencyAdvice(_daysPerWeek),
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: tokens.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFrequencyAdvice(int days) {
    switch (days) {
      case 2:
        return '2-Day Full Body Matrix. Optimized for busy lifestyles and maximum recovery.';
      case 3:
        return '3-Day Classic Full Body Split. Proven baseline for strength, muscle, and consistency.';
      case 4:
        return '4-Day Upper / Lower Split. Balanced recovery and hypertrophy progression.';
      case 5:
        return '5-Day Upper / Lower / PPL Hybrid Split. High stimulus for experienced lifters.';
      case 6:
        return '6-Day Push / Pull / Legs Split. Maximum volume frequency for dedicated trainees.';
      default:
        return 'Custom schedule.';
    }
  }

  // ─── Step 5: Experience Level ────────────────────────────────────────────────

  Widget _buildStep5Experience(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'EXPERIENCE LEVEL',
      whyWeAsk: 'Sets exercise volume, movement complexity, and progressive overload pacing.',
      children: [
        _buildSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.beginner,
          groupValue: _fitnessLevel,
          code: 'LEVEL // 01',
          title: 'BEGINNER',
          subtitle: 'Less than 1 year of consistent structured lifting. Focus on form and baseline strength.',
          icon: Icons.shield_outlined,
          onSelect: (l) {
            setState(() => _fitnessLevel = l);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.intermediate,
          groupValue: _fitnessLevel,
          code: 'LEVEL // 02',
          title: 'INTERMEDIATE',
          subtitle: '1 to 3 years of progressive overload training. Familiar with compound lifts and recovery.',
          icon: Icons.verified_user_outlined,
          onSelect: (l) {
            setState(() => _fitnessLevel = l);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.advanced,
          groupValue: _fitnessLevel,
          code: 'LEVEL // 03',
          title: 'EXPERT',
          subtitle: '3+ years of dedicated training. Advanced periodization and high training capacity.',
          icon: Icons.military_tech_outlined,
          onSelect: (l) {
            setState(() => _fitnessLevel = l);
            _saveDraft();
          },
        ),
      ],
    );
  }

  // ─── Step 6: Diet Budget ─────────────────────────────────────────────────────

  Widget _buildStep6Budget(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'NUTRITION BUDGET',
      whyWeAsk: 'Prioritizes food recommendations and meal suggestions in Fuel.',
      children: [
        _buildSelectableCard<BudgetLevel>(
          tokens: tokens,
          value: BudgetLevel.low,
          groupValue: _budget,
          code: 'TIER // ECONOMIC',
          title: 'LOW BUDGET',
          subtitle: 'Simple, highly cost-effective staples: oats, eggs, canned tuna, rice, peanut butter, lentils.',
          icon: Icons.savings_outlined,
          onSelect: (b) {
            setState(() => _budget = b);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<BudgetLevel>(
          tokens: tokens,
          value: BudgetLevel.medium,
          groupValue: _budget,
          code: 'TIER // BALANCED',
          title: 'MEDIUM BUDGET',
          subtitle: 'Balanced variety: chicken breasts, greek yogurt, fresh fruits, vegetables, lean mince.',
          icon: Icons.shopping_bag_outlined,
          onSelect: (b) {
            setState(() => _budget = b);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<BudgetLevel>(
          tokens: tokens,
          value: BudgetLevel.high,
          groupValue: _budget,
          code: 'TIER // PREMIUM',
          title: 'HIGH BUDGET',
          subtitle: 'Premium foods: fresh salmon, sirloin steak, blueberries, whey isolate, avocado.',
          icon: Icons.diamond_outlined,
          onSelect: (b) {
            setState(() => _budget = b);
            _saveDraft();
          },
        ),
      ],
    );
  }

  // ─── Step 7: Summary & Protocol Launch ───────────────────────────────────────

  Widget _buildStep7Summary(AppThemeTokens tokens) {
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

    final dailyCalories = tempProfile.dailyCalorieTarget.round();
    final proteinGrams = tempProfile.dailyProteinTargetGrams.round();
    final fatGrams = tempProfile.dailyFatTargetGrams.round();
    final carbGrams = tempProfile.dailyCarbTargetGrams.round();

    final programName = switch (_daysPerWeek) {
      <= 3 => 'Full Body Split ($_daysPerWeek Days)',
      4 => 'Upper / Lower Split (4 Days)',
      5 => '5-Day Hybrid Split (Upper/Lower/PPL)',
      _ => 'Push / Pull / Legs Split (6 Days)',
    };

    return _StepContentLayout(
      stepTitle: 'PROTOCOL INITIALIZED',
      whyWeAsk: 'Review your personalized training & nutrition profile before deployment.',
      children: [
        // Caloric Target HUD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: tokens.kineticAccent.withValues(alpha: 0.08),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY TARGET',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: tokens.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _goal!.displayName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: tokens.kineticAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$dailyCalories',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'KCAL / DAY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tokens.kineticAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Mifflin-St Jeor BMR: ${tempProfile.bmr.round()} kcal • TDEE: ${tempProfile.tdee.round()} kcal',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 11,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: tokens.borderSubtle, height: 1),
              const SizedBox(height: 14),
              // Macro targets
              Row(
                children: [
                  Expanded(
                    child: _buildMacroPill(
                      tokens,
                      label: 'PROTEIN',
                      grams: '${proteinGrams}g',
                      color: const Color(0xFF4FC3F7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroPill(
                      tokens,
                      label: 'CARBS',
                      grams: '${carbGrams}g',
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroPill(
                      tokens,
                      label: 'FATS',
                      grams: '${fatGrams}g',
                      color: const Color(0xFFF06292),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Program Assignment Preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.kineticAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fitness_center_rounded, size: 20, color: tokens.kineticAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMMENDED PROGRAM',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programName,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_equipment.displayName} • ${_fitnessLevel.displayName}',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.canvas,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: tokens.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Estimates are mathematical projections and not medical advice. All nutrition and workout targets can be fine-tuned anytime in Profile.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_synthesisError != null) ...[
          const SizedBox(height: 12),
          Text(
            'Error: $_synthesisError',
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildMacroPill(
    AppThemeTokens tokens, {
    required String label,
    required String grams,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            grams,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared UI Helpers ───────────────────────────────────────────────────────

  Widget _buildSelectableCard<T>({
    required AppThemeTokens tokens,
    required T value,
    required T? groupValue,
    required String code,
    required String title,
    required String subtitle,
    required IconData icon,
    required void Function(T) onSelect,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        AppHaptics.shared.selectionChanged();
        onSelect(value);
      },
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.kineticAccent.withValues(alpha: 0.08)
              : tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? tokens.kineticAccent
                    : tokens.canvas,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.black : tokens.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? tokens.kineticAccent
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        code,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerBox({
    required AppThemeTokens tokens,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: child,
    );
  }

  Widget _buildUnitChip(
    AppThemeTokens tokens, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? tokens.kineticAccent : tokens.canvas,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: isSelected ? Colors.black : tokens.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSlider({
    required AppThemeTokens tokens,
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: tokens.textSecondary,
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: tokens.kineticAccent,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: tokens.kineticAccent,
            inactiveTrackColor: tokens.borderSubtle,
            thumbColor: tokens.kineticAccent,
            overlayColor: tokens.kineticAccent.withValues(alpha: 0.15),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyNotice({
    required AppThemeTokens tokens,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.cyanAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: tokens.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: tokens.cyanAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ───────────────────────────────────────────────────────

  Widget _buildBottomNavigation(AppThemeTokens tokens) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: AppButton(
                label: 'BACK',
                variant: AppButtonVariant.secondary,
                onPressed: _previousStep,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: AppButton(
              label: isLastStep ? 'START PROTOCOL' : 'CONTINUE',
              icon: Icon(
                isLastStep ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.black,
              ),
              variant: AppButtonVariant.primary,
              onPressed: _canProceed ? _nextStep : null,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Synthesis Overlay ───────────────────────────────────────────────────────

  Widget _buildSynthesisOverlay(AppThemeTokens tokens) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'INITIALIZING PROTOCOL',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Generating workout program & diet plan...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 11,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepContentLayout extends StatelessWidget {
  const _StepContentLayout({
    required this.stepTitle,
    required this.whyWeAsk,
    required this.children,
  });

  final String stepTitle;
  final String whyWeAsk;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepTitle,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WHY WE ASK: ',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: tokens.kineticAccent,
                ),
              ),
              Expanded(
                child: Text(
                  whyWeAsk,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
