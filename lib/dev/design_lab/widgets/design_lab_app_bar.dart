import 'package:flutter/material.dart';
import '../design_lab_theme.dart';

class DesignLabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DesignTokens tokens;
  final DesignDirection currentDirection;
  final bool isDark;
  final ValueChanged<DesignDirection> onDirectionChanged;
  final ValueChanged<bool> onThemeModeChanged;
  final VoidCallback onOpenScreenPicker;
  final String activeScreenTitle;

  const DesignLabAppBar({
    super.key,
    required this.tokens,
    required this.currentDirection,
    required this.isDark,
    required this.onDirectionChanged,
    required this.onThemeModeChanged,
    required this.onOpenScreenPicker,
    required this.activeScreenTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tokens.panel,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
          ),
          child: Row(
            children: [
              // Screen Selector Button
              InkWell(
                onTap: onOpenScreenPicker,
                borderRadius: BorderRadius.circular(tokens.chipRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tokens.elevated,
                    borderRadius: BorderRadius.circular(tokens.chipRadius),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard_outlined, size: 16, color: tokens.accent),
                      const SizedBox(width: 6),
                      Text(
                        activeScreenTitle,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 18, color: tokens.textSecondary),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Direction Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: tokens.elevated,
                  borderRadius: BorderRadius.circular(tokens.chipRadius),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DesignDirection>(
                    value: currentDirection,
                    dropdownColor: tokens.panel,
                    icon: Icon(Icons.palette_outlined, size: 16, color: tokens.accent),
                    items: DesignDirection.values.map((dir) {
                      final num = dir.index + 1;
                      return DropdownMenuItem(
                        value: dir,
                        child: Text(
                          'Dir $num',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onDirectionChanged(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Dark / Light Toggle
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: tokens.textPrimary,
                  size: 20,
                ),
                tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                onPressed: () => onThemeModeChanged(!isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

