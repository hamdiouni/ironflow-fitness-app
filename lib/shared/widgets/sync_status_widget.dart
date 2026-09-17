import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/providers/sync_provider.dart';

class SyncStatusWidget extends ConsumerWidget {
  final bool showLabel;

  const SyncStatusWidget({
    Key? key,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final pendingCount = ref.watch(pendingOperationsCountProvider);

    return pendingCount.when(
      data: (count) {
        if (count == 0) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green.shade700,
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  'All synced',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          );
        }

        if (syncStatus == 'syncing') {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  'Syncing $count...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_queue,
              size: 16,
              color: Colors.orange.shade700,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                '$count pending',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => Icon(
        Icons.error,
        size: 16,
        color: Colors.red.shade700,
      ),
    );
  }
}
