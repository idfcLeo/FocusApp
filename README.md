<div align="center">

  # Focus 🎯
  ### *The Ultimate Productivity, Fitness & Health Hub for College Students*

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-blue.svg?style=for-the-badge)](#)

</div>

---

## 📌 Overview

**Focus** is an all-in-one, cross-platform Flutter application engineered specifically for university students. It seamlessly blends daily task prioritization, habit streak building, deep work focus timers, AI-powered food scanning, and dynamic fitness goal planning into a unified, responsive interface.

---

## ✨ Key Features

### 🎯 1. Deep Focus Mode & Custom Alarm
- **Custom Duration Timers**: Choose from standard Pomodoro presets (15, 25, 45, 60 min) or set any custom timer between **1 and 300 minutes**.
- **Ringing Audio Alarm & Vibration**: Features high-priority alarm notifications, device vibration feedback, and continuous looping audio chime alerts (`alarm_chime.wav`) when timer sessions complete.
- **Break Prompts**: Encourages structured rest periods to prevent academic burnout.

### 📸 2. AI Camera Food Scanner & Nutrition Hub
- **AI Food Identification**: Snap photos of your meals to classify food items and estimate portion size, calories, and macronutrients.
- **Connected Goal Plans**: Scanned meals automatically deduct from your remaining daily calorie budget and update your protein progress in real-time.

### 🏋️ 3. Dynamic BMI & Fitness Goal Plans
- **Tailored Goal Plans**: Choose between *Weight Loss Plan*, *Muscle Gain Plan*, and *Lean Maintenance Plan*.
- **Live TDEE & Macro Sync**: Recalculates maintenance calories (TDEE), target protein, hydration, and step goals dynamically whenever body parameters (weight, height, age, sex, activity level) change.

### 📋 4. Smart Task Management & Auto-Rollover
- **Priority Categorization**: Organize tasks by High/Medium/Low priority across Study, Project, Assignment, and Placement Prep.
- **Automated Task Carry-Over**: Uncompleted tasks from past days automatically roll over to today's active task list.

### ⚡ 5. Habit Building & Streak Tracker
- **Streak Counters**: Build momentum with visual streak counters for study blocks, capstone project work, protein targets, and hydration goals.

### 📈 6. Comprehensive Analytics & Progress Hub
- **Health & Consistency Cards**: Displays square option cards decorated with visual badges, progress indicators, and quick action pills.
- **Sleep & Water Tracking**: Log daily sleep hours and hydration glasses to optimize cognitive performance.

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter 3.x](https://flutter.dev) / Dart |
| **Local Storage** | `shared_preferences` |
| **Audio Playback** | `audioplayers` |
| **Notifications** | `flutter_local_notifications` |
| **Calendar & Dates** | `table_calendar`, `intl` |
| **Media Input** | `image_picker` |

---

## 📁 Codebase Architecture

```text
lib/
├── main.dart                  # App entry point & theme initialization
├── models/
│   ├── task.dart              # Task model & serialization
│   ├── habit.dart             # Habit & streak model
│   ├── food_item.dart         # Food log item model
│   └── exercise.dart         # Exercise log model
├── screens/
│   ├── main_screen.dart       # Bottom navigation bar host
│   ├── home_screen.dart       # Dashboard & Health & Consistency hub
│   ├── focus_screen.dart      # Focus timer, custom durations & alarm audio
│   ├── food_scanner_screen.dart # AI Camera Food scanner & connected plans
│   ├── plans_screen.dart      # BMI calculator & Fitness Goal Plans
│   ├── fitness_screen.dart    # Track Food, Exercises, Steps & Water Hub
│   ├── todo_screen.dart       # Task management & rollover logic
│   ├── habit_screen.dart      # Habit tracker screen
│   ├── progress_screen.dart   # Analytics & progress visualizations
│   └── calendar_screen.dart   # Academic schedule calendar
└── services/
    ├── storage_service.dart   # ValueNotifier state persistence & listener sync
    ├── notification_service.dart # High-importance alarm notifications
    ├── food_classifier_service.dart # AI food classifier
    └── food_database.dart     # Built-in food nutrition lookup database
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.5.4 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/idfcLeo/FocusApp.git
   cd FocusApp
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   # Run on connected device or emulator
   flutter run
   ```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/idfcLeo/FocusApp/issues).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
