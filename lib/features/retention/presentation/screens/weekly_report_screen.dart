import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/retention/domain/usecases/generate_weekly_report_use_case.dart';
import 'package:share_plus/share_plus.dart';

/// Screen for displaying weekly workout and nutrition reports.
///
/// **Validates: Requirements 6.5**
class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() =>
      _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  int _selectedWeek = 0; // 0 = current week, 1 = last week, etc.
  WeeklyReport? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual use case from provider
      // For now, create sample data
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday % 7 + (_selectedWeek * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final report = WeeklyReport(
        weekStart: weekStart,
        weekEnd: weekEnd,
        totalWorkouts: 4,
        totalVolume: 12500,
        personalRecords: 2,
        totalMeals: 18,
        averageMacros: {
          'protein': 150,
          'carbs': 250,
          'fats': 70,
          'calories': 2200,
        },
        currentStreak: 5,
        consistencyRate: 0.8,
        highlights: [
          'Completed 4 workouts - great consistency!',
          'Set 2 personal records!',
          '5 day streak - you\'re on fire! 🔥',
        ],
        recommendations: [
          'Try to hit 5 workouts next week',
          'Consider increasing protein intake to 160g',
        ],
      );

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    }
  }

  Future<void> _shareReport() async {
    if (_report == null) return;

    try {
      await Share.share(
        _report!.toShareableText(),
        subject: 'My IronFlow Weekly Report',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        actions: [
          if (_report != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareReport,
              tooltip: 'Share Report',
            ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (week) {
              setState(() => _selectedWeek = week);
              _loadReport();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('This Week')),
              const PopupMenuItem(value: 1, child: Text('Last Week')),
              const PopupMenuItem(value: 2, child: Text('2 Weeks Ago')),
              const PopupMenuItem(value: 3, child: Text('3 Weeks Ago')),
              const PopupMenuItem(value: 4, child: Text('4 Weeks Ago')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
              ? const Center(child: Text('No report available'))
              : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    final report = _report!;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      children: [
        _buildHeaderCard(report),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildWorkoutSummaryCard(report),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildNutritionSummaryCard(report),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildConsistencyCard(report),
        const SizedBox(height: AppTheme.spacingMedium),
        if (report.highlights.isNotEmpty) ...[
          _buildHighlightsCard(report),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
        if (report.recommendations.isNotEmpty) ...[
          _buildRecommendationsCard(report),
          const SizedBox(height: AppTheme.spacingMedium),
        ],
      ],
    );
  }

  Widget _buildHeaderCard(WeeklyReport report) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        children: [
          const Icon(
            Icons.assessment,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Weekly Report',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(report.weekStart)} - ${_formatDate(report.weekEnd)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummaryCard(WeeklyReport report) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fitness_center, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Workout Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Workouts',
                  report.totalWorkouts.toString(),
                  AppTheme.primaryColor,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Volume',
                  '${(report.totalVolume / 1000).toStringAsFixed(1)}k kg',
                  AppTheme.accentColor,
                  Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'PRs',
                  report.personalRecords.toString(),
                  AppTheme.successColor,
                  Icons.emoji_events,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Streak',
                  '${report.currentStreak} days',
                  Colors.orange,
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard(WeeklyReport report) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Text(
                'Nutrition Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildNutritionRow(
            'Meals Logged',
            report.totalMeals.toString(),
            AppTheme.accentColor,
          ),
          const SizedBox(height: 8),
          _buildNutritionRow(
            'Avg Protein',
            '${report.averageMacros['protein']?.toStringAsFixed(0)}g',
            AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          _buildNutritionRow(
            'Avg Carbs',
            '${report.averageMacros['carbs']?.toStringAsFixed(0)}g',
            AppTheme.successColor,
          ),
          const SizedBox(height: 8),
          _buildNutritionRow(
            'Avg Fats',
            '${report.averageMacros['fats']?.toStringAsFixed(0)}g',
            AppTheme.warningColor,
          ),
          const SizedBox(height: 8),
          _buildNutritionRow(
            'Avg Calories',
            '${report.averageMacros['calories']?.toStringAsFixed(0)} kcal',
            AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard(WeeklyReport report) {
    final percentage = (report.consistencyRate * 100).toStringAsFixed(0);
    Color ratingColor;
    String ratingText;

    if (report.consistencyRate >= 0.8) {
      ratingColor = AppTheme.successColor;
      ratingText = 'Excellent';
    } else if (report.consistencyRate >= 0.6) {
      ratingColor = AppTheme.primaryColor;
      ratingText = 'Good';
    } else if (report.consistencyRate >= 0.4) {
      ratingColor = AppTheme.warningColor;
      ratingText = 'Fair';
    } else {
      ratingColor = AppTheme.errorColor;
      ratingText = 'Needs Improvement';
    }

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Consistency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  ratingText,
                  style: TextStyle(
                    color: ratingColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ratingColor,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'of planned workouts',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          LinearProgressIndicator(
            value: report.consistencyRate,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard(WeeklyReport report) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: AppTheme.successColor),
              SizedBox(width: 8),
              Text(
                'Highlights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...report.highlights.map((highlight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(WeeklyReport report) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.warningColor),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...report.recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
