# Calendar Craft

A modern, scalable calendar and event management application built with Flutter and clean architecture.

## Features

- 📅 **Calendar Views**: Monthly, Weekly, Daily views with smooth navigation
- 📝 **Event Management**: Full CRUD operations with categories, priorities, and reminders
- 🔔 **Notifications**: Local notifications with customizable reminders
- 🎨 **Themes**: Light/Dark/System themes with Material 3 design
- 🔍 **Search**: Event search, filter, and sort functionality
- 📊 **Data Persistence**: Offline-first architecture with Hive database
- 🎉 **Holiday System**: Preloaded holidays with JSON support
- 📤 **Export/Import**: Backup and restore functionality

## Tech Stack

- **Framework**: Flutter 3.10+
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
- **State Management**: Riverpod
- **Database**: Hive (local storage)
- **Calendar UI**: table_calendar
- **Notifications**: flutter_local_notifications
- **Theme**: Material 3 with dynamic theming

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart 3.10.0 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd calendar_craft
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate code
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. Run the app
```bash
flutter run
```

## Build Instructions

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### Web Build
```bash
flutter build web
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── services/
│   │   ├── hive_service.dart
│   │   ├── notification_service.dart
│   │   └── hive_adapters.dart
│   └── theme/
├── domain/
│   ├── models/
│   │   ├── event.dart
│   │   └── holiday.dart
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── repositories/
│   └── models/
├── presentation/
│   ├── pages/
│   │   └── home_page.dart
│   ├── providers/
│   │   ├── event_provider.dart
│   │   └── theme_provider.dart
│   └── widgets/
│       ├── calendar_widget.dart
│       ├── event_list_widget.dart
│       └── floating_action_button_widget.dart
└── main.dart
```

## Key Features

### Event Management
- Create, edit, and delete events
- Event categories with color coding
- Priority levels (Low, Medium, High)
- Time-based and all-day events
- Recurring events (Daily, Weekly, Monthly, Custom)
- Multiple reminders per event
- Location support

### Calendar Features
- Monthly calendar view with event indicators
- Smooth month navigation
- Today highlighting
- Event count markers
- Responsive design

### Theme System
- Light theme with Material 3 colors
- Dark theme with optimized contrast
- System theme following device settings
- Persistent theme preferences

### Data Management
- Offline-first architecture
- Hive database for local storage
- Export events to JSON
- Import events from backup
- Holiday integration

### Notifications
- Local notifications for event reminders
- Custom reminder times
- Multiple reminders per event
- Permission handling

## Development

### Code Generation
The project uses code generation for:
- Hive type adapters
- JSON serialization
- Riverpod providers

Run code generation with:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
flutter test
```

### Linting
```bash
flutter analyze
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and feature requests, please use the GitHub issue tracker.
