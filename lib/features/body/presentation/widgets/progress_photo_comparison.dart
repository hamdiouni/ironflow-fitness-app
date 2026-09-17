import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/body_entry.dart';

/// A before-after comparison widget for progress photos.
///
/// Displays two [BodyEntry] photos side by side with a draggable divider
/// that supports swipe gestures. Shows date metadata for each photo.
/// Handles missing photos gracefully with a placeholder.
class ProgressPhotoComparison extends StatefulWidget {
  final BodyEntry beforeEntry;
  final BodyEntry afterEntry;

  const ProgressPhotoComparison({
    required this.beforeEntry,
    required this.afterEntry,
    super.key,
  });

  @override
  State<ProgressPhotoComparison> createState() => _ProgressPhotoComparisonState();
}

class _ProgressPhotoComparisonState extends State<ProgressPhotoComparison> {
  /// Divider position as a fraction [0.0, 1.0] of the widget width.
  double _dividerPosition = 0.5;

  void _onDragUpdate(DragUpdateDetails details, double totalWidth) {
    setState(() {
      _dividerPosition = (_dividerPosition + details.delta.dx / totalWidth)
          .clamp(0.05, 0.95);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dividerX = totalWidth * _dividerPosition;

        return ClipRect(
          child: SizedBox(
            width: totalWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                // After photo (full width, behind divider)
                Positioned.fill(
                  child: _PhotoPanel(
                    entry: widget.afterEntry,
                    label: 'After',
                    alignment: Alignment.bottomRight,
                  ),
                ),

                // Before photo (clipped to left of divider)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: dividerX,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      maxWidth: totalWidth,
                      child: SizedBox(
                        width: totalWidth,
                        height: constraints.maxHeight,
                        child: _PhotoPanel(
                          entry: widget.beforeEntry,
                          label: 'Before',
                          alignment: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                  ),
                ),

                // Divider line
                Positioned(
                  left: dividerX - 1,
                  top: 0,
                  bottom: 0,
                  width: 2,
                  child: Container(color: Colors.white),
                ),

                // Drag handle
                Positioned(
                  left: dividerX - 20,
                  top: 0,
                  bottom: 0,
                  width: 40,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (d) => _onDragUpdate(d, totalWidth),
                    child: Center(
                      child: _DividerHandle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Displays a single photo panel with a date label overlay.
class _PhotoPanel extends StatelessWidget {
  final BodyEntry entry;
  final String label;
  final Alignment alignment;

  const _PhotoPanel({
    required this.entry,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = entry.photoPath != null && entry.photoPath!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo or placeholder
        hasPhoto
            ? Image.file(
                File(entry.photoPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PhotoPlaceholder(label: label),
              )
            : _PhotoPlaceholder(label: label),

        // Date + label overlay
        Positioned(
          bottom: 8,
          left: alignment == Alignment.bottomLeft ? 8 : null,
          right: alignment == Alignment.bottomRight ? 8 : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: alignment == Alignment.bottomLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(entry.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Placeholder shown when no photo is available.
class _PhotoPlaceholder extends StatelessWidget {
  final String label;

  const _PhotoPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No $label photo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The circular drag handle on the divider.
class _DividerHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.swap_horiz,
        size: 20,
        color: Colors.black87,
      ),
    );
  }
}
