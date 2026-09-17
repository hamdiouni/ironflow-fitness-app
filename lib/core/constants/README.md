# Theme System Documentation

## Overview

The Progression Tracker app uses a dark theme with neon accent colors and glassmorphism effects to create a modern, minimal fitness aesthetic.

## Requirements Fulfilled

This theme system implements the following requirements:

- **Requirement 13.1**: Dark mode as default theme with neon green (primary) and neon blue (accent) colors
- **Requirement 13.2**: Glassmorphism effects on card components with transparency and blur
- **Requirement 13.3**: Rounded corners with 16-24px radius for buttons and cards

## Theme Configuration

### Colors

```dart
// Primary colors
AppTheme.primaryColor      // Neon green (#00FF00)
AppTheme.accentColor       // Neon blue (#00BFFF)
AppTheme.backgroundColor   // Black (#000000)
AppTheme.surfaceColor      // Dark grey (#1A1A1A)

// Status colors
AppTheme.errorColor        // Red (#FF3B30)
AppTheme.successColor      // Green (#00FF00)
AppTheme.warningColor      // Orange (#FF9500)

// Macro colors (for nutrition tracking)
AppTheme.proteinColor      // Red (#FF3B30)
AppTheme.carbsColor        // Blue (#007AFF)
AppTheme.fatsColor         // Yellow (#FFCC00)

// Text colors
AppTheme.textPrimary       // White (#FFFFFF)
AppTheme.textSecondary     // Light grey (#B0B0B0)
AppTheme.textDisabled      // Dark grey (#666666)
```

### Border Radius

```dart
AppTheme.borderRadiusSmall   // 8px
AppTheme.borderRadiusMedium  // 16px (requirement: 16-24px)
AppTheme.borderRadiusLarge   // 24px (requirement: 16-24px)
```

### Spacing

```dart
AppTheme.spacingXSmall   // 4px
AppTheme.spacingSmall    // 8px
AppTheme.spacingMedium   // 16px
AppTheme.spacingLarge    // 24px
AppTheme.spacingXLarge   // 32px
```

## Glassmorphism Effects

The theme system provides three ways to create glassmorphic cards:

### 1. Helper Widget (Recommended)

The easiest way to create a glassmorphic card:

```dart
AppTheme.glassmorphicCard(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.all(16),
  borderRadius: AppTheme.borderRadiusMedium,
  child: Text('Your content here'),
)
```

**Features:**
- Automatic BackdropFilter with blur effect
- Transparent background with subtle border
- Configurable border radius, padding, and margin
- Custom background and border colors

### 2. Decoration Method

For more control, use the decoration directly:

```dart
Container(
  decoration: AppTheme.glassmorphicCardDecoration(
    borderRadius: AppTheme.borderRadiusMedium,
    backgroundColor: AppTheme.surfaceColor,
    borderColor: Colors.white,
  ),
  child: YourContent(),
)
```

**Note:** When using this method, you need to manually wrap with `ClipRRect` and `BackdropFilter` for the blur effect.

### 3. Gradient Decoration

For special cards with gradient backgrounds (e.g., workout summary):

```dart
Container(
  decoration: AppTheme.glassmorphicGradientDecoration(
    borderRadius: AppTheme.borderRadiusLarge,
    gradientColors: [Colors.blue.shade900, Colors.purple.shade900],
  ),
  child: YourContent(),
)
```

## Usage Examples

### Simple Card

```dart
AppTheme.glassmorphicCard(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Workout Summary'),
      Text('Total Sets: 12'),
    ],
  ),
)
```

### Meal Card (from design spec)

```dart
AppTheme.glassmorphicCard(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Grilled Chicken', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('350 cal'),
      Row(
        children: [
          MacroChip(label: 'P', value: 35, color: AppTheme.proteinColor),
          MacroChip(label: 'C', value: 0, color: AppTheme.carbsColor),
          MacroChip(label: 'F', value: 5, color: AppTheme.fatsColor),
        ],
      ),
    ],
  ),
)
```

### Workout Summary Card with Gradient

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: AppTheme.glassBlurSigma,
      sigmaY: AppTheme.glassBlurSigma,
    ),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassmorphicGradientDecoration(
        gradientColors: [Colors.blue.shade900, Colors.purple.shade900],
      ),
      child: Column(
        children: [
          Text('Workout Complete!', style: TextStyle(fontSize: 28)),
          Text('Total Volume: 2400 kg'),
        ],
      ),
    ),
  ),
)
```

## Applying the Theme

In your `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.darkTheme,
  home: YourHomeScreen(),
)
```

## Theme Components

The dark theme automatically configures:

- **Cards**: Rounded corners (16px), transparent background, no elevation
- **Buttons**: Neon green background, rounded corners (16px)
- **Input Fields**: Dark surface background, rounded corners (16px)
- **Bottom Navigation**: Dark surface background, neon green selection
- **App Bar**: Black background, centered title, no elevation

## Best Practices

1. **Use the helper widget** (`AppTheme.glassmorphicCard`) for most cards - it handles all the boilerplate
2. **Stick to defined border radii** (16px or 24px) for consistency
3. **Use theme colors** instead of hardcoding colors
4. **Apply glassmorphism to cards** that need visual hierarchy
5. **Use gradient decoration** sparingly for special emphasis (e.g., completion screens)

## Technical Details

### Glassmorphism Implementation

The glassmorphism effect is achieved through:

1. **BackdropFilter**: Applies blur to content behind the card
   - Blur sigma: 10.0 (configurable via `AppTheme.glassBlurSigma`)

2. **Transparency**: Semi-transparent background color
   - Alpha: 0.5 (50% opacity)

3. **Subtle Border**: Light border for definition
   - Color: White with 10% opacity
   - Width: 1px

4. **Rounded Corners**: Smooth edges
   - Default: 16px (medium)
   - Large cards: 24px

### Performance Considerations

- BackdropFilter can be expensive on low-end devices
- Use sparingly for important UI elements
- Consider disabling blur on very old devices if needed
- The blur effect is GPU-accelerated in Flutter

## Examples File

See `app_theme_examples.dart` for complete, runnable examples of:
- Simple glassmorphic cards
- Manual glassmorphic cards
- Gradient glassmorphic cards
- Meal cards with macro chips

## Testing

The theme system is fully tested in `test/unit/core/app_theme_test.dart`:
- Color constants validation
- Border radius requirements (16-24px)
- Dark theme configuration
- Glassmorphism decoration properties
- Widget rendering with BackdropFilter
- Custom styling options
