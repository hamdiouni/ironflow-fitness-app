import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progression_tracker/core/platform/platform_image.dart';

import '../../../../../core/constants/app_theme.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../shared/presentation/components/app_button.dart';
import '../../../../../shared/presentation/components/app_card.dart';
import '../../../../../shared/presentation/services/app_haptics.dart';
import '../../../domain/entities/body_entry.dart';
import '../../providers/body_providers.dart';
import '../progress_photo_comparison.dart';

class ProgressPhotosTab extends ConsumerStatefulWidget {
  const ProgressPhotosTab({super.key});
  @override
  ConsumerState<ProgressPhotosTab> createState() => _ProgressPhotosTabState();
}

class _ProgressPhotosTabState extends ConsumerState<ProgressPhotosTab> {
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
    } catch (e, stack) {
      if (mounted) ErrorHandler.handleError(context, e, stack);
    }
  }

  void _showComparisonSheet(
    BuildContext context,
    List<BodyEntry> photoEntries,
  ) {
    if (photoEntries.length < 2) return;
    final sorted = List<BodyEntry>.from(photoEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final oldest = sorted.first;
    final newest = sorted.last;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final tokens = AppThemeTokens.of(ctx);
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.8,
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BEFORE & AFTER COMPARISON',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: tokens.textMuted, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ProgressPhotoComparison(
                  beforeEntry: oldest,
                  afterEntry: newest,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final historyAsync = ref.watch(bodyHistoryProvider);

    return historyAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: tokens.kineticAccent,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e', style: TextStyle(color: tokens.error)),
      ),
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
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 56,
                          color: tokens.textMuted.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO PROGRESS PHOTOS YET',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + below to upload visual physique check-in',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (photoEntries.length >= 2)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: SizedBox(
                            height: 38,
                            width: double.infinity,
                            child: AppButton(
                              label: 'COMPARE BEFORE & AFTER',
                              variant: AppButtonVariant.secondary,
                              icon:
                                  const Icon(Icons.compare_rounded, size: 18),
                              onPressed: () {
                                AppHaptics.shared.selectionChanged();
                                _showComparisonSheet(context, photoEntries);
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: photoEntries.length,
                          itemBuilder: (context, index) {
                            final entry = photoEntries[index];
                            return _PhotoCard(entry: entry, tokens: tokens);
                          },
                        ),
                      ),
                    ],
                  ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: tokens.kineticAccent,
                foregroundColor: Colors.black,
                elevation: 4,
                onPressed: _pickPhoto,
                child: const Icon(Icons.add_a_photo_rounded),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.entry, required this.tokens});
  final BodyEntry entry;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PlatformImage.buildLocalOrNetwork(
              entry.photoPath!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: tokens.card,
                child: Icon(
                  Icons.broken_image_rounded,
                  color: tokens.textMuted,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(entry.date),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tokens.kineticAccent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

