# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app on connected device/emulator
- `flutter test` - Run all tests
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build for iOS (requires Xcode)
- `flutter analyze` - Run static analysis using rules from analysis_options.yaml
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Widgetbook Development
- `flutter run -t lib/widgetbook.dart` - Run Widgetbook for component development
- `dart run build_runner build` - Generate Widgetbook directories (required after adding new @UseCase widgets)

### Testing
- `flutter test test/widget_test.dart` - Run specific widget test (note: current test is outdated and needs updating)

## Project Architecture

### Core Application Structure
This is a Flutter ticket booking application for Neuschwanstein Castle with the following key components:

**Main Application (`lib/main.dart`)**:
- Single-screen ticket ordering app built with Material Design
- Uses Form validation for user input
- Integrates with device email client via `url_launcher` package
- Implements dynamic pricing based on attendee types (Adult: €23.50, Child: €2.50)
- Features date picker with 2-day minimum advance booking
- Collects customer email, bank account verification, and attendee details

**Key Data Models**:
- `AttendeeType` enum: `adult`, `child`
- `TimeSlot` enum: `am`, `pm`
- `Attendee` class: Manages individual attendee form controllers and type

**Core Features**:
- Dynamic attendee management (add/remove multiple people)
- Date restriction (minimum 2 days advance booking)
- AM/PM time slot selection
- Real-time total price calculation
- Email order submission with formatted details
- Form validation for all required fields

### Component Development with Widgetbook
- Uses Widgetbook for isolated component development and testing
- Components annotated with `@UseCase` are automatically discovered
- Generated directories in `lib/widgetbook.directories.g.dart`
- Example component: `MyButton` in `lib/widgets/my_button.dart`

### Dependencies
**Key packages**:
- `intl: ^0.20.2` - Date formatting and internationalization
- `url_launcher: ^6.3.2` - Email client integration
- `widgetbook: ^3.16.0` - Component development and documentation
- `flutter_lints: ^5.0.0` - Static analysis rules

### Testing Strategy
- Widget tests in `test/` directory
- Current widget test is a template and needs updating to match actual app functionality
- No automated testing for email integration (requires manual testing)

### Development Notes
- App uses Material 3 design system
- Email submission is handled via device's default email client
- Bank account format: "1234-5678-9999" (hardcoded for demo)
- Target email: "chikuokuo@msn.com" (hardcoded)
- Form state management uses setState pattern
- Text controllers require proper disposal to prevent memory leaks