import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_theme.dart';
import '../providers/sync_provider.dart';

/// Widget that shows sync status and last sync time
class SyncIndicator extends ConsumerWidget {
  final bool showDetails;

  const SyncIndicator({
    super.key,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusStreamProvider);
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return syncStatusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        final isOnline = isOnlineAsync.valueOrNull ?? false;

        if (!showDetails && !status.isSyncing) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(status, isOnline),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(status, isOnline),
              if (showDetails) ...[
                const SizedBox(width: 8),
                _buildText(context, status, isOnline),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(dynamic status, bool isOnline) {
    if (status.isSyncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (!isOnline) {
      return const Icon(
        Icons.cloud_off,
        size: 16,
        color: Colors.white,
      );
    }

    if (status.failedActions > 0) {
      return const Icon(
        Icons.sync_problem,
        size: 16,
        color: Colors.white,
      );
    }

    if (status.pendingActions > 0) {
      return const Icon(
        Icons.cloud_upload,
        size: 16,
        color: Colors.white,
      );
    }

    return const Icon(
      Icons.cloud_done,
      size: 16,
      color: Colors.white,
    );
  }

  Widget _buildText(BuildContext context, dynamic status, bool isOnline) {
    String text;

    if (status.isSyncing) {
      text = 'Syncing...';
    } else if (!isOnline) {
      text = 'Offline';
    } else if (status.failedActions > 0) {
      text = '${status.failedActions} failed';
    } else if (status.pendingActions > 0) {
      text = '${status.pendingActions} pending';
    } else if (status.lastSyncTime != null) {
      text = 'Synced ${timeago.format(status.lastSyncTime!)}';
    } else {
      text = 'Not synced';
    }

    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getBackgroundColor(dynamic status, bool isOnline) {
    if (status.isSyncing) {
      return AppTheme.primaryColor;
    }

    if (!isOnline) {
      return Colors.grey;
    }

    if (status.failedActions > 0) {
      return Colors.red;
    }

    if (status.pendingActions > 0) {
      return Colors.orange;
    }

    return Colors.green;
  }
}

/// Compact sync indicator for app bar
class CompactSyncIndicator extends ConsumerWidget {
  const CompactSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusStreamProvider);

    return syncStatusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        if (!status.isSyncing && status.pendingActions == 0 && status.failedActions == 0) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: _buildIcon(status),
          onPressed: () => _showSyncDialog(context, ref, status),
          tooltip: 'Sync status',
        );
      },
    );
  }

  Widget _buildIcon(dynamic status) {
    if (status.isSyncing) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (status.failedActions > 0) {
      return const Icon(Icons.sync_problem, color: Colors.red);
    }

    if (status.pendingActions > 0) {
      return const Icon(Icons.cloud_upload, color: Colors.orange);
    }

    return const Icon(Icons.cloud_done, color: Colors.green);
  }

  void _showSyncDialog(BuildContext context, WidgetRef ref, dynamic status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Status', status.isSyncing ? 'Syncing...' : 'Idle'),
            const SizedBox(height: 8),
            _buildStatusRow('Pending', '${status.pendingActions}'),
            const SizedBox(height: 8),
            _buildStatusRow('Failed', '${status.failedActions}'),
            const SizedBox(height: 8),
            if (status.lastSyncTime != null)
              _buildStatusRow(
                'Last Sync',
                timeago.format(status.lastSyncTime!),
              ),
          ],
        ),
        actions: [
          if (status.failedActions > 0)
            TextButton(
              onPressed: () {
                ref.read(retryFailedActionsProvider)();
                Navigator.of(context).pop();
              },
              child: const Text('Retry Failed'),
            ),
          TextButton(
            onPressed: () {
              ref.read(syncTriggerProvider)();
              Navigator.of(context).pop();
            },
            child: const Text('Sync Now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
