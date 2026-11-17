import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_theme.dart';
import '../../../../../core/platform/platform_file_ops.dart';
import '../../../domain/usecases/restore_data_use_case.dart';

void showExportRestoreModal({
  required BuildContext context,
  required RestoreDataUseCase restoreUseCase,
  required Future<void> Function(String jsonText, bool overwriteExisting)
      onExecuteRestore,
}) {
  final tokens = AppThemeTokens.of(context);
  final jsonController = TextEditingController();
  BackupPreview? currentPreview;
  bool isValidating = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tokens.canvas,
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;

          void runValidation(String text) {
            final trimmed = text.trim();
            if (trimmed.isEmpty) {
              setModalState(() {
                currentPreview = null;
              });
              return;
            }

            setModalState(() {
              isValidating = true;
            });

            final preview = restoreUseCase.getRestorePreviewFromJson(trimmed);

            setModalState(() {
              currentPreview = preview;
              isValidating = false;
            });
          }

          Future<void> loadLatestLocalBackup() async {
            setModalState(() => isValidating = true);
            try {
              final dirPath = await PlatformFileOps.resolveExportDirectoryPath();
              final jsonFiles = await PlatformFileOps.listFilesInDirectory(
                dirPath,
                extensionFilter: '.json',
              );
              final candidates = jsonFiles
                  .where((p) => p.contains('backup'))
                  .toList();
              final withTimestamps = await Future.wait(
                candidates.map((path) async => (
                      path: path,
                      modified: await PlatformFileOps.fileLastModified(path) ??
                          DateTime.fromMillisecondsSinceEpoch(0),
                    )),
              );
              withTimestamps.sort(
                (a, b) => b.modified.compareTo(a.modified),
              );

              final backupPath =
                  withTimestamps.isNotEmpty ? withTimestamps.first.path : null;
              final content = backupPath != null
                  ? await PlatformFileOps.readUtf8File(backupPath)
                  : null;

              if (content == null) {
                if (sheetContext.mounted) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'No local backup file found in documents directory',
                      ),
                      backgroundColor: tokens.warning,
                    ),
                  );
                }
                setModalState(() => isValidating = false);
                return;
              }

              jsonController.text = content;
              runValidation(content);
            } catch (e) {
              if (sheetContext.mounted) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  SnackBar(
                    content: Text('Error reading local file: $e'),
                    backgroundColor: tokens.error,
                  ),
                );
              }
              setModalState(() => isValidating = false);
            }
          }

          Future<void> pasteFromClipboard() async {
            final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
            if (clipboardData?.text != null &&
                clipboardData!.text!.isNotEmpty) {
              jsonController.text = clipboardData.text!;
              runValidation(clipboardData.text!);
            }
          }

          Future<void> executeRestore(bool overwriteExisting) async {
            final jsonText = jsonController.text.trim();
            if (jsonText.isEmpty) return;

            Navigator.of(sheetContext).pop();
            await onExecuteRestore(jsonText, overwriteExisting);
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, bottomInset + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: tokens.borderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'RESTORE BACKUP DATA',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Validate incoming JSON archive before applying any changes.',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.kineticAccent,
                            side: BorderSide(color: tokens.borderSubtle),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.paste_rounded, size: 16),
                          label: const Text(
                            'PASTE JSON',
                            style: TextStyle(fontSize: 11),
                          ),
                          onPressed: pasteFromClipboard,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.cyanAccent,
                            side: BorderSide(color: tokens.borderSubtle),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.folder_open_rounded, size: 16),
                          label: const Text(
                            'LOAD LOCAL',
                            style: TextStyle(fontSize: 11),
                          ),
                          onPressed: loadLatestLocalBackup,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: jsonController,
                    maxLines: 5,
                    style:
                        const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Paste backup JSON string here...',
                      hintStyle:
                          TextStyle(color: tokens.textMuted, fontSize: 11),
                      filled: true,
                      fillColor: tokens.panel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        borderSide: BorderSide(color: tokens.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        borderSide: BorderSide(color: tokens.borderSubtle),
                      ),
                    ),
                    onChanged: runValidation,
                  ),
                  const SizedBox(height: 14),

                  // Pre-validation preview card
                  if (isValidating)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: tokens.kineticAccent,
                        ),
                      ),
                    )
                  else if (currentPreview != null) ...[
                    if (!currentPreview!.isValid) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(
                            color: tokens.error.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: tokens.error,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'INVALID BACKUP ARCHIVE: ${currentPreview!.error ?? currentPreview!.validationErrors.join(", ")}',
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 11,
                                  color: tokens.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.card,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(
                            color: tokens.kineticAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: tokens.kineticAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'VALIDATED BACKUP ARCHIVE',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.kineticAccent,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'v${currentPreview!.exportVersion ?? "1.0"}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    color: tokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                _PreviewTag(
                                  label: 'WORKOUTS',
                                  count: currentPreview!.workoutCount,
                                  tokens: tokens,
                                ),
                                _PreviewTag(
                                  label: 'NUTRITION DAYS',
                                  count: currentPreview!.nutritionCount,
                                  tokens: tokens,
                                ),
                                _PreviewTag(
                                  label: 'BODY ENTRIES',
                                  count: currentPreview!.bodyMeasurementCount,
                                  tokens: tokens,
                                ),
                                _PreviewTag(
                                  label: 'PROFILE',
                                  count: currentPreview!.hasUserProfile ? 1 : 0,
                                  tokens: tokens,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tokens.kineticAccent,
                                side: BorderSide(color: tokens.kineticAccent),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => executeRestore(false),
                              child: Text(
                                'MERGE DATA',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tokens.error,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: modalCtx,
                                  builder: (confirmCtx) => AlertDialog(
                                    backgroundColor: tokens.panel,
                                    title: const Text('OVERWRITE ALL DATA?'),
                                    content: const Text(
                                      'This will clear existing local records and replace them with this backup archive.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(confirmCtx),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(confirmCtx);
                                          executeRestore(true);
                                        },
                                        child: Text(
                                          'OVERWRITE',
                                          style: TextStyle(color: tokens.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text(
                                'OVERWRITE ALL',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _PreviewTag extends StatelessWidget {
  final String label;
  final int count;
  final AppThemeTokens tokens;

  const _PreviewTag({
    required this.label,
    required this.count,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10,
            color: tokens.textMuted,
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

