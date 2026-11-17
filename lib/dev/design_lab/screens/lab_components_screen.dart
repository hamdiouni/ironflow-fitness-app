import 'package:flutter/material.dart';

import '../design_lab_theme.dart';
import '../widgets/design_lab_widgets.dart';

class LabComponentsScreen extends StatelessWidget {
  const LabComponentsScreen({
    super.key,
    required this.tokens,
    required this.isWide,
    this.onToggleBrightness,
  });

  final LabTokens tokens;
  final bool isWide;
  final VoidCallback? onToggleBrightness;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.pagePadding),
      children: [
        Text('Components & Settings', style: tokens.headingStyle(24)),
        Text(
          '${tokens.direction.title} • ${tokens.isDark ? "Dark" : "Light"} tokens',
          style: tokens.bodyStyle(13, color: tokens.textSecondary),
        ),
        SizedBox(height: tokens.sectionGap),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildButtonsAndTagsCard()),
              SizedBox(width: tokens.sectionGap),
              Expanded(child: _buildSettingsAndPaletteCard()),
            ],
          )
        else ...[
          _buildButtonsAndTagsCard(),
          SizedBox(height: tokens.sectionGap),
          _buildSettingsAndPaletteCard(),
        ],
      ],
    );
  }

  Widget _buildButtonsAndTagsCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions & Badges', style: tokens.headingStyle(16)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: LabPrimaryButton(
              tokens: tokens,
              label: 'Primary Action',
              icon: Icons.check_circle_outline_rounded,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LabSecondaryButton(
                  tokens: tokens,
                  label: 'Secondary',
                  icon: Icons.tune_rounded,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: onToggleBrightness,
                    child: Text(
                      tokens.isDark ? 'Preview Light' : 'Preview Dark',
                      style: tokens.bodyStyle(
                        13,
                        weight: FontWeight.w700,
                        color: tokens.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LabTag(tokens: tokens, label: 'Ready', color: tokens.success),
              LabTag(tokens: tokens, label: 'Recovering', color: tokens.warning),
              LabTag(tokens: tokens, label: 'Rest Day', color: tokens.error),
              LabTag(tokens: tokens, label: 'Coach Tip', color: tokens.secondaryAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsAndPaletteCard() {
    return LabCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferences & Tokens', style: tokens.headingStyle(16)),
          const SizedBox(height: 10),
          _SettingPreviewRow(
            tokens: tokens,
            icon: Icons.straighten_rounded,
            title: 'Units',
            value: 'Metric (kg, cm, g)',
          ),
          Divider(height: 16, color: tokens.border),
          _SettingPreviewRow(
            tokens: tokens,
            icon: Icons.language_rounded,
            title: 'Language',
            value: 'English (7 locales)',
          ),
          Divider(height: 16, color: tokens.border),
          _SettingPreviewRow(
            tokens: tokens,
            icon: tokens.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Theme Mode',
            value: tokens.isDark ? 'Dark (Gym)' : 'Light',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Swatch(tokens: tokens, name: 'Canvas', color: tokens.canvas),
              _Swatch(tokens: tokens, name: 'Surface', color: tokens.surface),
              _Swatch(tokens: tokens, name: 'Raised', color: tokens.raised),
              _Swatch(tokens: tokens, name: 'Accent', color: tokens.accent),
              _Swatch(tokens: tokens, name: 'Second', color: tokens.secondaryAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingPreviewRow extends StatelessWidget {
  const _SettingPreviewRow({
    required this.tokens,
    required this.icon,
    required this.title,
    required this.value,
  });

  final LabTokens tokens;
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: tokens.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: tokens.bodyStyle(14, weight: FontWeight.w600)),
        ),
        Text(value, style: tokens.bodyStyle(13, color: tokens.textSecondary)),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.tokens,
    required this.name,
    required this.color,
  });

  final LabTokens tokens;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: tokens.border),
          ),
        ),
        const SizedBox(width: 4),
        Text(name, style: tokens.labelStyle(11, color: tokens.textSecondary)),
      ],
    );
  }
}
