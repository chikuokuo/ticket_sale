# Color System Guide

This folder contains the complete color system and theme configuration for the Neuschwanstein Castle ticketing platform.

## File Structure

### `colors.dart` - Color System
Contains a complete Material Design 3 color system with castle blue as the primary theme color:

- **Primary Colors** (Primary): Castle blue series (#1A4B84)
- **Secondary Colors** (Secondary): UNESCO gold series (#F2C94C)
- **Tertiary Colors** (Tertiary): Light castle blue series (#2E5B95)
- **Functional Colors**: Error (red), success (green), warning (orange), info (blue)
- **Neutral Colors**: Complete grayscale color series

### `app_theme.dart` - Theme System
Contains complete application theme configuration:

- Typography system
- Spacing and border radius system
- Shadow styles
- Component theme configurations (buttons, cards, input fields, etc.)
- Light and dark themes

## How to Use

### Using Predefined Colors

```dart
// Import color system
import 'package:your_app/theme/colors.dart';

// Use primary colors
Container(
  color: AppColorScheme.primary,  // Primary castle blue
  child: Text(
    'Hello Castle',
    style: TextStyle(color: AppColorScheme.secondary), // Gold text
  ),
)

// Use functional colors
Container(
  color: AppColorScheme.success,  // Success green
  // or
  color: AppColorScheme.error,    // Error red
  color: AppColorScheme.warning,  // Warning orange
)

// Use different shades
Container(color: AppColorScheme.getPrimaryShade(100))  // Light blue
Container(color: AppColorScheme.getPrimaryShade(900))  // Dark blue
```

### Using Theme Styles

```dart
// Import theme system
import 'package:your_app/theme/app_theme.dart';

// Use predefined text styles
Text(
  'Castle Ticket',
  style: AppTheme.displayLarge,  // Large title
)

Text(
  'Description',
  style: AppTheme.bodyMedium,    // Body text
)

// Use spacing system
Padding(
  padding: EdgeInsets.all(AppTheme.spacingM),  // 16px spacing
)

// Use border radius system
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppTheme.radiusL), // 12px radius
    boxShadow: AppTheme.shadowMedium,  // Medium shadow
  ),
)
```

### Using Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.castleGradient,  // Castle gradient
    // or
    gradient: AppTheme.sunsetGradient,  // Sunset gradient
    gradient: AppTheme.forestGradient,  // Forest gradient
  ),
)
```

## Color Theme Features

- **Material Design 3 Compliant**
- **Light and Dark Mode Support**
- **Castle-themed Design**: Inspired by Neuschwanstein Castle's blue tones
- **Full Accessibility Support**: Meets WCAG contrast requirements
- **Rich Color Variations**: Each color has 50-900 shade variations

## Automatic Theme Switching

The application now supports automatic switching between light/dark modes based on system settings:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,      // Light theme
  darkTheme: AppTheme.darkTheme,   // Dark theme  
  themeMode: ThemeMode.system,     // Auto switch
)
```

## Extending the Color System

If you need to add new colors, add them to `colors.dart`:

```dart
static const Color customColor = Color(0xFF123456);
static const List<Color> customGradient = [customColor, primary];
```

Then create corresponding theme configurations in `app_theme.dart`.