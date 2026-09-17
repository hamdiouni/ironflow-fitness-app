import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/body_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/usecases/save_body_entry_use_case.dart';
import '../../../../shared/widgets/weight_trend_graph.dart';
import '../providers/body_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weight'),
            Tab(text: 'Measurements'),
            Tab(text: 'Photos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WeightTab(),
          _MeasurementsTab(),
          _PhotosTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weight Tab — FIX: uses weightTrendProvider (non-family) + refresh counter
// ---------------------------------------------------------------------------

class _WeightTab extends ConsumerWidget {
  const _WeightTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: watch the non-family provider — it re-runs when bodyRefreshCounterProvider changes
    final trendAsync = ref.watch(weightTrendProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graph card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(color: theme.dividerColor),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight Trend (Last 30 Days)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                trendAsync.when(
                  data: (points) => WeightTrendGraph(dataPoints: points)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  loading: () => const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'Failed to load weight data: $e',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Recent entries list
          trendAsync.when(
            data: (points) {
              if (points.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No weight entries yet.\nTap "Log Weight" to start.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }
              // Show last 5 entries
              final recent = points.reversed.take(5).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Entries', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...recent.map((p) => _WeightEntryRow(point: p)),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          ElevatedButton.icon(
            onPressed: () => _showLogWeightDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Log Weight'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogWeightDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'e.g. 75.5',
            ),
            validator: (v) {
              final parsed = double.tryParse(v?.trim() ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid positive weight';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final weight = double.parse(controller.text.trim());
        final entry = BodyEntry.create(weight: weight);
        final repository = ref.read(bodyRepositoryProvider);
        final useCase = SaveBodyEntryUseCase(repository);
        await useCase(entry);

        // FIX: increment the refresh counter — both bodyHistoryProvider and
        // weightTrendProvider watch this counter and will re-fetch automatically.
        ref.read(bodyRefreshCounterProvider.notifier).state++;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Weight ${weight.toStringAsFixed(1)}kg logged!'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e, stack) {
        if (context.mounted) {
          ErrorHandler.handleError(context, e, stack);
        }
      } finally {
        // FIX: Dispose controller after we're done using it
        controller.dispose();
      }
    } else {
      // FIX: Dispose controller if dialog was cancelled
      controller.dispose();
    }
  }
}

class _WeightEntryRow extends StatelessWidget {
  const _WeightEntryRow({required this.point});
  final dynamic point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            DateFormat('MMM d, yyyy').format(point.date as DateTime),
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            '${(point.weight as double).toStringAsFixed(1)} kg',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Measurements Tab
// ---------------------------------------------------------------------------

class _MeasurementsTab extends ConsumerWidget {
  const _MeasurementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(bodyHistoryProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          historyAsync.when(
            data: (entries) {
              final withMeasurements =
                  entries.where((e) => e.measurements.isNotEmpty).toList();

              if (withMeasurements.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Center(
                    child: Text(
                      'No measurements logged yet',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              final latest = withMeasurements.first;
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Measurements',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ...MeasurementType.values.map((type) {
                      final value = latest.measurements[type];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingXSmall),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_label(type),
                                style: theme.textTheme.bodyMedium),
                            Text(
                              value != null
                                  ? '${value.toStringAsFixed(1)} cm'
                                  : '—',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: value != null
                                    ? AppTheme.primaryColor
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Failed to load measurements',
                style: TextStyle(color: theme.colorScheme.error)),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          ElevatedButton.icon(
            onPressed: () => _showLogMeasurementsForm(context, ref),
            icon: const Icon(Icons.straighten),
            label: const Text('Log Measurements'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  String _label(MeasurementType type) => switch (type) {
        MeasurementType.chest => 'Chest',
        MeasurementType.waist => 'Waist',
        MeasurementType.hips => 'Hips',
        MeasurementType.arms => 'Arms',
        MeasurementType.legs => 'Legs',
      };

  Future<void> _showLogMeasurementsForm(
      BuildContext context, WidgetRef ref) async {
    final controllers = {
      for (final type in MeasurementType.values)
        type: TextEditingController(),
    };
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Measurements'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MeasurementType.values.map((type) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppTheme.spacingSmall),
                  child: TextFormField(
                    controller: controllers[type],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${_label(type)} (cm) — optional',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final parsed = double.tryParse(v);
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid positive value';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final measurements = <MeasurementType, double>{};
        for (final type in MeasurementType.values) {
          final text = controllers[type]!.text.trim();
          if (text.isNotEmpty) {
            final value = double.tryParse(text);
            if (value != null && value > 0) measurements[type] = value;
          }
        }

        final history = ref.read(bodyHistoryProvider).valueOrNull;
        final lastWeight =
            history?.isNotEmpty == true ? history!.first.weight : 1.0;

        final entry = BodyEntry.create(
          weight: lastWeight,
          measurements: measurements,
        );
        final repository = ref.read(bodyRepositoryProvider);
        final useCase = SaveBodyEntryUseCase(repository);
        await useCase(entry);

        // FIX: increment refresh counter
        ref.read(bodyRefreshCounterProvider.notifier).state++;
      } catch (e, stack) {
        if (context.mounted) ErrorHandler.handleError(context, e, stack);
      } finally {
        // FIX: Dispose all controllers after we're done
        for (final c in controllers.values) {
          c.dispose();
        }
      }
    } else {
      // FIX: Dispose all controllers if dialog was cancelled
      for (final c in controllers.values) {
        c.dispose();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Photos Tab
// ---------------------------------------------------------------------------

class _PhotosTab extends ConsumerStatefulWidget {
  const _PhotosTab();
  @override
  ConsumerState<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends ConsumerState<_PhotosTab> {
  final _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
    );
    if (picked == null || !mounted) return;
    try {
      final history = ref.read(bodyHistoryProvider).valueOrNull;
      final lastWeight =
          history?.isNotEmpty == true ? history!.first.weight : 70.0;
      final entry =
          BodyEntry.create(weight: lastWeight, photoPath: picked.path);
      final repository = ref.read(bodyRepositoryProvider);
      await repository.saveBodyEntry(entry);
      // FIX: increment refresh counter
      ref.read(bodyRefreshCounterProvider.notifier).state++;
    } catch (e, stack) {
      if (mounted) ErrorHandler.handleError(context, e, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(bodyHistoryProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) {
        final photoEntries =
            entries.where((e) => e.photoPath != null).toList();
        return Stack(
          children: [
            photoEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('No progress photos yet',
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first photo',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: photoEntries.length,
                    itemBuilder: (context, index) {
                      final entry = photoEntries[index];
                      return _PhotoCard(entry: entry);
                    },
                  ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: _pickPhoto,
                child: const Icon(Icons.add_a_photo),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.entry});
  final BodyEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(entry.photoPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.surface,
                child: Icon(Icons.broken_image,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(entry.date),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
