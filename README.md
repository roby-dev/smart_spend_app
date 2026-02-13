# SmartSpend

A personal expense tracking application built with Flutter. SmartSpend helps users organize purchases into lists, track individual item prices against budgets, and back up data to Google Drive. It also integrates Google Gemini AI for adding items via camera, voice, or gallery input.

## Version

- **App version:** 1.1.0+2
- **Flutter SDK:** 3.41.0 (Dart 3.11.0)
- **Min Android SDK:** 21
- **Target SDK:** 36

## Architecture

The project follows a **layered architecture** with clear separation of concerns:

```
lib/
├── config/          # App configuration (database, routing, theming)
├── constants/       # App-wide constants (colors, values)
├── data/            # Data layer
│   ├── datasources/ # Local data sources (Drift/SQLite)
│   └── repositories/# Repository implementations
├── domain/          # Domain layer
│   ├── models/      # Business models
│   └── repositories/# Repository contracts (interfaces)
├── features/        # Feature modules
│   ├── home/        # Home screen (purchase lists)
│   ├── compra_detalle/ # Purchase detail screen (items)
│   ├── compras_archivadas/ # Archived purchases
│   └── shared/      # Shared providers, widgets, utilities
└── main.dart        # Application entry point
```

**State management:** Riverpod 3.x with the Notifier pattern.

**Local persistence:** Drift (SQLite) with code generation.

**Navigation:** GoRouter for declarative routing.

## Dependencies

### Core

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | 3.1.0 | State management |
| riverpod_annotation | 4.0.0 | Code generation for providers |
| go_router | 17.1.0 | Declarative navigation and routing |
| drift | 2.22.1 | Reactive SQLite persistence |
| drift_flutter | 0.2.2 | Flutter integration for Drift |
| intl | 0.20.1 | Internationalization and date formatting |

### Firebase and Authentication

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | 4.4.0 | Firebase initialization |
| firebase_auth | 6.1.4 | User authentication |
| google_sign_in | 7.2.0 | Google account sign-in |
| googleapis | 16.0.0 | Google APIs client (Drive) |
| googleapis_auth | 2.0.0 | OAuth 2.0 for Google APIs |

### AI and Media

| Package | Version | Purpose |
|---------|---------|---------|
| google_generative_ai | 0.4.7 | Gemini AI for smart item input |
| speech_to_text | 7.3.0 | Voice-to-text input |
| image_picker | 1.2.1 | Camera and gallery access |

### Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| share_plus | 12.0.1 | File sharing (backup export) |
| file_picker | 10.3.10 | File selection (backup import) |
| path_provider | 2.1.5 | Platform directory paths |
| http | 1.2.2 | HTTP client |
| flutter_svg | 2.0.16 | SVG asset rendering |
| visibility_detector | 0.4.0+2 | Widget visibility detection |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| build_runner | 2.4.13 | Code generation runner |
| drift_dev | 2.22.0 | Drift code generator |
| riverpod_generator | 4.0.0+1 | Riverpod code generator |
| riverpod_lint | 3.1.0 | Lint rules for Riverpod |
| custom_lint | 0.8.1 | Custom lint support |
| flutter_lints | 6.0.0 | Recommended Flutter lint rules |

## Setup

### Prerequisites

- Flutter SDK 3.41.0 or later
- Android SDK with NDK 28.2.13676358
- Java 17
- A Firebase project with Authentication enabled
- A Google Cloud project with Drive API enabled

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd smart_spend_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (Drift database and Riverpod providers):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Configure Firebase:
   - Place your `google-services.json` in `android/app/`
   - Ensure the Firebase project has Google Sign-In enabled

5. Run the app:
   ```bash
   flutter run
   ```

## Features

- **Purchase lists:** Create, edit, reorder, and archive purchase lists with optional budgets.
- **Item tracking:** Add items with names and prices to each list. Editable inline.
- **Smart Add:** Add items using Gemini AI via camera capture, gallery image, or voice input.
- **Budget monitoring:** Set budgets per list and track remaining balance.
- **Google Drive backup:** Export data as JSON and upload to Google Drive.
- **Import/Export:** Share backup files or import from local JSON files.
- **Archive:** Archive completed lists and restore them when needed.
- **Swipe to delete:** Animated dismiss gestures with undo support.

## Build

```bash
# Debug
flutter run

# Release APK
flutter build apk --release

# Code generation (after modifying Drift tables or Riverpod providers)
dart run build_runner build --delete-conflicting-outputs
```

## License

This project is proprietary software. All rights reserved.
