import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/ai/presentation/providers/tts_provider.dart';

/// TTS Settings Bottom Sheet
class AITtsSettingsSheet extends ConsumerWidget {
  const AITtsSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = AppThemeTokens.of(context);
    final ttsState = ref.watch(ttsProvider);

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusXl)),
        border: Border(top: BorderSide(color: tokens.borderSubtle)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tokens.kineticAccent,
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                  ),
                  child: Icon(
                    Icons.settings_voice,
                    color: tokens.onAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Voice Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Speed Control
            Text(
              '🎚️ Speech Speed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(ttsState.speechRate * 2).toStringAsFixed(1)}x',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              _SpeedChip(
                                label: '0.5x',
                                value: 0.25,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(0.25),
                              ),
                              const SizedBox(width: 8),
                              _SpeedChip(
                                label: '1x',
                                value: 0.5,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(0.5),
                              ),
                              const SizedBox(width: 8),
                              _SpeedChip(
                                label: '1.5x',
                                value: 0.75,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(0.75),
                              ),
                              const SizedBox(width: 8),
                              _SpeedChip(
                                label: '2x',
                                value: 1.0,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(1.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: theme.colorScheme.primary,
                          inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                          thumbColor: theme.colorScheme.primary,
                          overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: ttsState.speechRate,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: (value) {
                            ref.read(ttsProvider.notifier).setSpeechRate(value);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Slower',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            'Faster',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Voice Personas
            Text(
              '🎭 Voice Personas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a coaching style that motivates you',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            
            // Persona Cards
            if (ttsState.personas.isNotEmpty)
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ttsState.personas.length,
                  itemBuilder: (context, index) {
                    final persona = ttsState.personas[index];
                    final isSelected = ttsState.selectedPersonaId == persona.id;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < ttsState.personas.length - 1 ? 12 : 0,
                      ),
                      child: _PersonaCard(
                        persona: persona,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(ttsProvider.notifier).applyPersona(persona);
                        },
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Voice personas are loading...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            // Advanced: Raw voice selection (collapsed by default)
            if (ttsState.availableVoices.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  'Advanced Voice Settings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: Icon(
                  Icons.tune,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ttsState.selectedVoice,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          hint: Row(
                            children: [
                              Icon(
                                Icons.record_voice_over,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Select system voice',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          items: ttsState.availableVoices.take(10).map((voice) {
                            return DropdownMenuItem<String>(
                              value: voice,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 18,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      voice,
                                      style: theme.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (voice) {
                            if (voice != null) {
                              ref.read(ttsProvider.notifier).setVoice(voice);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Test Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(ttsProvider.notifier).speak(
                    'Hello! This is a test of the text to speech voice. How does it sound?',
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test Voice'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Speed selection chip
class _SpeedChip extends StatelessWidget {
  final String label;
  final double value;
  final double currentValue;
  final VoidCallback onTap;

  const _SpeedChip({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = (currentValue - value).abs() < 0.01;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Persona Card Widget
class _PersonaCard extends StatelessWidget {
  final VoicePersona persona;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppThemeTokens.of(context);
    final selectedInk = tokens.onAccent;
    final selectedBg = tokens.kineticAccent;

    // Calculate display values
    final displaySpeed = '${(persona.recommendedSpeed * 2).toStringAsFixed(1)}x';
    final pitchLevel = persona.pitch < 0.8 ? 'Low' : persona.pitch > 1.3 ? 'High' : 'Normal';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : tokens.elevated,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(
            color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with speed badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedInk.withValues(alpha: 0.14)
                        : tokens.kineticAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    persona.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Spacer(),
                // Speed indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedInk.withValues(alpha: 0.16)
                        : tokens.cyanAccent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                  ),
                  child: Text(
                    displaySpeed,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? selectedInk : tokens.cyanAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Name
            Text(
              persona.name.replaceAll(RegExp(r'[^\w\s]'), ''),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? selectedInk : tokens.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Description
            Flexible(
              child: Text(
                persona.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? selectedInk.withValues(alpha: 0.9)
                      : tokens.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6),

            // Pitch indicator
            Row(
              children: [
                Icon(
                  pitchLevel == 'Low'
                      ? Icons.arrow_downward
                      : pitchLevel == 'High'
                          ? Icons.arrow_upward
                          : Icons.remove,
                  size: 10,
                  color: isSelected
                      ? selectedInk.withValues(alpha: 0.85)
                      : tokens.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '$pitchLevel pitch',
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? selectedInk.withValues(alpha: 0.85)
                        : tokens.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Selected indicator
            if (isSelected)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: selectedInk,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: selectedInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
