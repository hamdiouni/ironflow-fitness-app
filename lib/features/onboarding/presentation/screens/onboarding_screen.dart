import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Monolithic Sci-Fi Guided 5-Step Onboarding Stepper with Mission Specification Review.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // Collected parameters
  FitnessGoal? _goal;
  FitnessLevel _fitnessLevel = FitnessLevel.beginner;
  int _daysPerWeek = 4;
  EquipmentType _equipment = EquipmentType.gym;

  int _age = 25;
  double _weightKg = 75.0;
  double _heightCm = 175.0;
  bool _isImperial = false; // KG/CM vs LBS/IN
  BudgetLevel _budget = BudgetLevel.medium;

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
      final storage = ref.read(userProfileStorageProvider);
      final draft = await storage.getDraft();
      if (draft != null && mounted) {
        setState(() {
          if (draft['goal'] != null) {
            _goal = FitnessGoal.values.byName(draft['goal'] as String);
          }
          if (draft['fitnessLevel'] != null) {
            _fitnessLevel = FitnessLevel.values.byName(draft['fitnessLevel'] as String);
          }
          if (draft['daysPerWeek'] != null) {
            _daysPerWeek = draft['daysPerWeek'] as int;
          }
          if (draft['equipment'] != null) {
            _equipment = EquipmentType.values.byName(draft['equipment'] as String);
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
          if (draft['budget'] != null) {
            _budget = BudgetLevel.values.byName(draft['budget'] as String);
          }
          if (draft['isImperial'] != null) {
            _isImperial = draft['isImperial'] as bool;
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
      final storage = ref.read(userProfileStorageProvider);
      final draftData = <String, dynamic>{
        'goal': _goal?.name,
        'fitnessLevel': _fitnessLevel.name,
        'daysPerWeek': _daysPerWeek,
        'equipment': _equipment.name,
        'age': _age,
        'weightKg': _weightKg,
        'heightCm': _heightCm,
        'budget': _budget.name,
        'isImperial': _isImperial,
      };
      await storage.saveDraft(step: _currentStep, data: draftData);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Onboarding] Error saving draft: $e');
      }
    }
  }

  bool get _canProceed {
    if (_currentStep == 0) return _goal != null;
    return true;
  }

  void _nextStep() {
    if (!_canProceed) return;
    AppHaptics.shared.buttonPress();

    if (_currentStep < _totalSteps - 1) {
      final next = _currentStep + 1;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep = next);
      _saveDraft();
    } else {
      _synthesizeAndInitialize();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      AppHaptics.shared.selectionChanged();
      final prev = _currentStep - 1;
      _pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep = prev);
      _saveDraft();
    }
  }

  Future<void> _synthesizeAndInitialize() async {
    if (_goal == null || _isSynthesizing) return;

    AppHaptics.shared.buttonPress();
    setState(() {
      _isSynthesizing = true;
      _synthesisError = null;
    });

    final profile = UserProfile(
      goal: _goal!,
      age: _age,
      weightKg: _weightKg,
      heightCm: _heightCm,
      fitnessLevel: _fitnessLevel,
      equipment: _equipment,
      workoutDaysPerWeek: _daysPerWeek,
      budget: _budget,
    );

    try {
      await ref.read(onboardingNotifierProvider.notifier).completeOnboarding(profile);

      // Invalidate queries so navigation sees fresh onboarded state
      ref.invalidate(isOnboardedProvider);
      ref.invalidate(userProfileProvider);

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSynthesizing = false;
          _synthesisError = e.toString();
        });
        AppHaptics.shared.error();
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
                      _buildStep2Experience(tokens),
                      _buildStep3Protocol(tokens),
                      _buildStep4Biometrics(tokens),
                      _buildStep5Review(tokens),
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

  // ─── Header & Progress Tracker ───────────────────────────────────────────────

  Widget _buildHeader(AppThemeTokens tokens) {
    final stepNumber = (_currentStep + 1).toString().padLeft(2, '0');
    final totalSteps = _totalSteps.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(
          bottom: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
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
                    width: 7,
                    height: 7,
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
            ],
          ),
          const SizedBox(height: 12),
          // Segmented Progress Bar
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isActive = index == _currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? tokens.kineticAccent
                        : isActive
                            ? tokens.kineticAccent.withValues(alpha: 0.85)
                            : tokens.borderSubtle,
                    borderRadius: BorderRadius.circular(1.5),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: tokens.kineticAccent.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Fitness Goal ───────────────────────────────────────────────────

  Widget _buildStep1Goal(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'PRIMARY DIRECTIVE',
      stepDescription: 'Select your core physiological focus for automated calibration.',
      children: [
        _buildSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.gainMuscle,
          groupValue: _goal,
          code: 'DIRECTIVE // 01',
          title: 'HYPERTROPHY // GAIN MUSCLE',
          subtitle: 'Acquire lean muscle tissue, increase strength output, and maximize structural power.',
          icon: Icons.fitness_center_rounded,
          onSelect: (g) {
            setState(() => _goal = g);
            _saveDraft();
          },
        ),
        const SizedBox(height: 12),
        _buildSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.loseWeight,
          groupValue: _goal,
          code: 'DIRECTIVE // 02',
          title: 'OXIDATION // LOSE WEIGHT',
          subtitle: 'Accelerate fat oxidation, preserve contractile muscle tissue, and achieve athletic definition.',
          icon: Icons.local_fire_department_rounded,
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
          title: 'EQUILIBRIUM // MAINTAIN',
          subtitle: 'Sustain peak athletic composition, optimize energy metabolism, and reinforce longevity.',
          icon: Icons.balance_rounded,
          onSelect: (g) {
            setState(() => _goal = g);
            _saveDraft();
          },
        ),
      ],
    );
  }

  // ─── Step 2: Experience Level ───────────────────────────────────────────────

  Widget _buildStep2Experience(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'OPERATOR TIER',
      stepDescription: 'State your current lifting experience to adjust progressive overload intensity.',
      children: [
        _buildSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.beginner,
          groupValue: _fitnessLevel,
          code: 'TIER // CADET',
          title: 'BEGINNER (< 1 YEAR)',
          subtitle: 'Establishing foundational neuromuscular recruitment, motor patterns, and steady recovery.',
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
          code: 'TIER // OPERATIVE',
          title: 'INTERMEDIATE (1–3 YEARS)',
          subtitle: 'Consistent progressive overload acclimation, compound lift proficiency, and planned volume.',
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
          code: 'TIER // VETERAN',
          title: 'ADVANCED (3+ YEARS)',
          subtitle: 'High training density, specialized periodization protocols, and refined auto-regulation.',
          icon: Icons.military_tech_outlined,
          onSelect: (l) {
            setState(() => _fitnessLevel = l);
            _saveDraft();
          },
        ),
      ],
    );
  }

  // ─── Step 3: Protocol Parameters (Frequency & Equipment) ────────────────────

  Widget _buildStep3Protocol(AppThemeTokens tokens) {
    return _StepContentLayout(
      stepTitle: 'PROTOCOL PARAMETERS',
      stepDescription: 'Configure weekly deployment frequency and available training arsenal.',
      children: [
        // Frequency Selector
        _buildContainerBox(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WEEKLY TRAINING FREQUENCY',
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
                      '$_daysPerWeek DAYS / WEEK',
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
              const SizedBox(height: 12),
              Text(
                _getFrequencyAdvice(_daysPerWeek),
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Equipment Selector
        Text(
          'EQUIPMENT ARSENAL',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: tokens.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        _buildSelectableCard<EquipmentType>(
          tokens: tokens,
          value: EquipmentType.gym,
          groupValue: _equipment,
          code: 'ARSENAL // FULL',
          title: 'COMMERCIAL GYM // FULL ARSENAL',
          subtitle: 'Barbells, calibrated plates, selectorized machines, cable columns, and racks.',
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
          code: 'ARSENAL // TACTICAL',
          title: 'TACTICAL OUTPOST // HOME & DUMBBELLS',
          subtitle: 'Adjustable dumbbells, pull-up bar, resistance loops, and calisthenic bodyweight movements.',
          icon: Icons.home_repair_service_rounded,
          onSelect: (e) {
            setState(() => _equipment = e);
            _saveDraft();
          },
        ),
      ],
    );
  }

  String _getFrequencyAdvice(int days) {
    switch (days) {
      case 2:
        return '2-Day Full Body Matrix. Maximum recovery efficiency.';
      case 3:
        return '3-Day Classic Full Body Split. Proven baseline for steady progress.';
      case 4:
        return '4-Day Upper / Lower Split. Balanced fatigue and recovery distribution.';
      case 5:
        return '5-Day Push / Pull / Legs + Upper / Lower Split. High training stimulus.';
      case 6:
        return '6-Day Push / Pull / Legs Hypertrophy Split. High volume commitment.';
      default:
        return 'Custom training frequency schedule.';
    }
  }

  // ─── Step 4: Biometric Telemetry & Budget ───────────────────────────────────

  Widget _buildStep4Biometrics(AppThemeTokens tokens) {
    // Conversions
    final displayWeight = _isImperial
        ? (_weightKg * 2.20462).round().toDouble()
        : _weightKg.round().toDouble();
    final weightUnit = _isImperial ? 'LBS' : 'KG';

    final displayHeight = _isImperial
        ? (_heightCm / 2.54).round().toDouble()
        : _heightCm.round().toDouble();
    final heightUnit = _isImperial ? 'IN' : 'CM';

    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    final bmr = 10 * _weightKg + 6.25 * _heightCm - 5 * _age + 5;
    final activityMult = _daysPerWeek <= 2 ? 1.375 : (_daysPerWeek <= 4 ? 1.55 : 1.725);
    final tdee = bmr * activityMult;

    return _StepContentLayout(
      stepTitle: 'BIOMETRIC TELEMETRY',
      stepDescription: 'Input physiological statistics for energy expenditure and macronutrient computation.',
      children: [
        // Unit System Switch
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
                  _buildUnitChip(tokens, label: 'METRIC (KG/CM)', isSelected: !_isImperial, onTap: () {
                    AppHaptics.shared.selectionChanged();
                    setState(() => _isImperial = false);
                    _saveDraft();
                  }),
                  const SizedBox(width: 6),
                  _buildUnitChip(tokens, label: 'IMPERIAL (LBS/IN)', isSelected: _isImperial, onTap: () {
                    AppHaptics.shared.selectionChanged();
                    setState(() => _isImperial = true);
                    _saveDraft();
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Sliders Container
        _buildContainerBox(
          tokens: tokens,
          child: Column(
            children: [
              // Age
              _buildMetricSlider(
                tokens: tokens,
                label: 'OPERATOR AGE',
                valueText: '$_age YRS',
                value: _age.toDouble(),
                min: 16,
                max: 80,
                divisions: 64,
                onChanged: (val) {
                  setState(() => _age = val.toInt());
                  _saveDraft();
                },
              ),
              Divider(color: tokens.borderSubtle, height: 24),
              // Weight
              _buildMetricSlider(
                tokens: tokens,
                label: 'BODY MASS',
                valueText: '${displayWeight.toInt()} $weightUnit',
                value: displayWeight,
                min: _isImperial ? 88 : 40,
                max: _isImperial ? 440 : 200,
                divisions: _isImperial ? 176 : 160,
                onChanged: (val) {
                  setState(() {
                    if (_isImperial) {
                      _weightKg = (val / 2.20462);
                    } else {
                      _weightKg = val;
                    }
                  });
                  _saveDraft();
                },
              ),
              Divider(color: tokens.borderSubtle, height: 24),
              // Height
              _buildMetricSlider(
                tokens: tokens,
                label: 'STATURE',
                valueText: _isImperial
                    ? '${(displayHeight ~/ 12)}\' ${(displayHeight % 12).toInt()}" ($heightUnit)'
                    : '${displayHeight.toInt()} $heightUnit',
                value: displayHeight,
                min: _isImperial ? 48 : 120,
                max: _isImperial ? 88 : 225,
                divisions: _isImperial ? 40 : 105,
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
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Dynamic Telemetry Readout
        _buildContainerBox(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALCULATED TELEMETRY METRICS',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryMetric(
                      tokens,
                      title: 'BMI INDEX',
                      value: bmi.toStringAsFixed(1),
                      status: _getBmiStatus(bmi),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTelemetryMetric(
                      tokens,
                      title: 'BASAL METABOLIC',
                      value: '${bmr.round()}',
                      status: 'KCAL / DAY',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTelemetryMetric(
                      tokens,
                      title: 'TOTAL EXPENDITURE',
                      value: '${tdee.round()}',
                      status: 'KCAL TDEE',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Food Budget
        Text(
          'NUTRITION RESOURCE ALLOCATION',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: tokens.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: BudgetLevel.values.map((b) {
            final isSelected = _budget == b;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: b == BudgetLevel.high ? 0 : 8,
                ),
                child: InkWell(
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    setState(() => _budget = b);
                    _saveDraft();
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.kineticAccent.withValues(alpha: 0.12) : tokens.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          b.displayName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isSelected ? tokens.kineticAccent : tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          switch (b) {
                            BudgetLevel.low => 'Cost Efficient',
                            BudgetLevel.medium => 'Balanced Variety',
                            BudgetLevel.high => 'Elite Sourcing',
                          },
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 10,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getBmiStatus(double bmi) {
    if (bmi < 18.5) return 'UNDERWEIGHT';
    if (bmi < 25.0) return 'OPTIMAL';
    if (bmi < 30.0) return 'OVERWEIGHT';
    return 'OBESE';
  }

  Widget _buildUnitChip(
    AppThemeTokens tokens, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? tokens.kineticAccent : tokens.card,
          borderRadius: BorderRadius.circular(4),
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
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Text(
                valueText,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tokens.kineticAccent,
                ),
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

  Widget _buildTelemetryMetric(
    AppThemeTokens tokens, {
    required String title,
    required String value,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: tokens.kineticAccent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 5: Mission Specification Review & Synthesis ───────────────────────

  Widget _buildStep5Review(AppThemeTokens tokens) {
    if (_goal == null) {
      return const Center(child: Text('Please select a goal first'));
    }

    final tempProfile = UserProfile(
      goal: _goal!,
      age: _age,
      weightKg: _weightKg,
      heightCm: _heightCm,
      fitnessLevel: _fitnessLevel,
      equipment: _equipment,
      workoutDaysPerWeek: _daysPerWeek,
      budget: _budget,
    );

    final dailyCalories = tempProfile.dailyCalorieTarget.round();
    final surplusOrDeficit = switch (_goal!) {
      FitnessGoal.gainMuscle => '+300 KCAL SURPLUS',
      FitnessGoal.loseWeight => '-500 KCAL DEFICIT',
      FitnessGoal.maintain => 'MAINTENANCE EQUILIBRIUM',
    };

    return _StepContentLayout(
      stepTitle: 'MISSION SPECIFICATION',
      stepDescription: 'Review generated protocol specifications prior to automated system initialization.',
      children: [
        // Specification Manifest Container
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.terminal_rounded, size: 16, color: tokens.kineticAccent),
                      const SizedBox(width: 8),
                      Text(
                        'SPECIFICATION MANIFEST',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'READY',
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
              Divider(color: tokens.borderSubtle, height: 24),
              _buildReviewRow(
                tokens,
                label: 'PRIMARY DIRECTIVE',
                value: _goal!.displayName.toUpperCase(),
                code: 'GOAL // ${_goal!.name.toUpperCase()}',
              ),
              const SizedBox(height: 12),
              _buildReviewRow(
                tokens,
                label: 'OPERATOR CLASSIFICATION',
                value: _fitnessLevel.displayName.toUpperCase(),
                code: 'TIER // ${_fitnessLevel.name.toUpperCase()}',
              ),
              const SizedBox(height: 12),
              _buildReviewRow(
                tokens,
                label: 'DEPLOYMENT SCHEDULE',
                value: '$_daysPerWeek DAYS / WEEK',
                code: _equipment.displayName.toUpperCase(),
              ),
              const SizedBox(height: 12),
              _buildReviewRow(
                tokens,
                label: 'BIOMETRIC SIGNATURE',
                value: '${_weightKg.toStringAsFixed(1)} KG // ${_heightCm.round()} CM // $_age YRS',
                code: 'BMI: ${tempProfile.bmi.toStringAsFixed(1)}',
              ),
              const SizedBox(height: 12),
              _buildReviewRow(
                tokens,
                label: 'PROJECTED CALORIC TARGET',
                value: '$dailyCalories KCAL / DAY',
                code: surplusOrDeficit,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Generated Architecture Preview Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tokens.kineticAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 20, color: tokens.kineticAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE PROTOCOL SYNTHESIS',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Personalized $_daysPerWeek-day training split and nutrient-matched diet matrix will be generated and set active immediately.',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        color: tokens.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_synthesisError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Initialization failed: $_synthesisError',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewRow(
    AppThemeTokens tokens, {
    required String label,
    required String value,
    required String code,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          code,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: tokens.kineticAccent.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Navigation ───────────────────────────────────────────────────────

  Widget _buildBottomNavigation(AppThemeTokens tokens) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(
          top: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
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
              label: isLastStep ? 'INITIALIZE SYSTEM' : 'PROCEED',
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
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: tokens.kineticAccent.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'SYNTHESIZING PROTOCOL',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Calibrating progressive overload and macronutrient distribution...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 11,
                  color: tokens.textMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers & Base Components ───────────────────────────────────────────────

  Widget _buildSelectableCard<T>({
    required AppThemeTokens tokens,
    required T value,
    required T? groupValue,
    required String code,
    required String title,
    required String subtitle,
    required IconData icon,
    required ValueChanged<T> onSelect,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        AppHaptics.shared.selectionChanged();
        onSelect(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? tokens.kineticAccent.withValues(alpha: 0.1) : tokens.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tokens.kineticAccent.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? tokens.kineticAccent : tokens.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                ),
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
                      Text(
                        code,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isSelected ? tokens.kineticAccent : tokens.textMuted,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: tokens.kineticAccent,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? tokens.kineticAccent : tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11,
                      color: tokens.textMuted,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: child,
    );
  }
}

class _StepContentLayout extends StatelessWidget {
  const _StepContentLayout({
    required this.stepTitle,
    required this.stepDescription,
    required this.children,
  });

  final String stepTitle;
  final String stepDescription;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepTitle,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stepDescription,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 12,
              color: tokens.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
