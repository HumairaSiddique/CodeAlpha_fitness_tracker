# 🏋️ Fitness Tracker App
A modern Flutter-based Fitness Tracker application designed to help users monitor and manage their daily fitness activities. The app provides an intuitive interface for tracking workouts, fitness goals, and progress efficiently.


## ✨ Features

- 🔐 **Authentication** — Email/Password & Google Sign-In via Firebase Auth
- 🏃 **Workout Logging** — Log workouts with type, duration, calories & steps
- ✏️ **Edit & Delete** — Full CRUD operations on workout entries
- 📊 **Progress Charts** — 7-day line chart with calories, steps & duration metrics
- 📈 **Workout Breakdown** — Visual progress bars for each workout type
- 🗂️ **Dashboard** — All-time stats with total calories, steps, minutes & workouts
- 🌙 **Dark Theme** — Professional dark UI with teal & purple gradient accents
- ☁️ **Cloud Sync** — All data stored securely in Firebase Firestore

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| **Flutter** | Cross-platform UI framework |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Real-time cloud database |
| **Google Sign-In** | OAuth authentication |
| **fl_chart** | Progress line charts |
| **Google Fonts** | Inter font family |
| **intl** | Date formatting |
| **uuid** | Unique workout IDs |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Firebase project (console.firebase.google.com)
- Android Studio / VS Code

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/YourUsername/CodeAlpha_FitnessTrackerApp.git
cd CodeAlpha_FitnessTrackerApp
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Firebase Setup**
- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- Enable **Authentication** → Email/Password & Google
- Enable **Cloud Firestore**
- Download `google-services.json` → place in `android/app/`
- Run `flutterfire configure` to generate `firebase_options.dart`

**4. Run the app**
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & theme
├── models/
│   └── workout_model.dart             # Workout data model
├── services/
│   ├── auth_service.dart              # Firebase Auth logic
│   └── firestore_service.dart         # Firestore CRUD operations
├── screens/
│   ├── splash_screen.dart             # Animated splash screen
│   ├── auth/
│   │   ├── login_screen.dart          # Login screen
│   │   └── signup_screen.dart         # Registration screen
│   └── home/
│       ├── dashboard_screen.dart      # Main dashboard
│       ├── add_workout_screen.dart    # Add/Edit workout
│       └── progress_screen.dart       # Charts & progress
└── widgets/
    ├── stat_card.dart                 # Reusable stat card
    └── workout_tile.dart              # Workout list item
```

---

## 🎨 UI Design

- **Color Palette:** Dark background `#0D0D0D` with Teal `#00C6AE` & Purple `#6C63FF` gradients
- **Typography:** Google Fonts — Inter
- **Design Style:** Modern dark UI with glassmorphism-inspired cards

---

## 🔥 Workout Types Supported

| Type | Type | Type | Type |
|------|------|------|------|
| 🏃 Running | 🚴 Cycling | 🏋️ Gym | 🏊 Swimming |
| 🧘 Yoga | 🚶 Walking | ⚡ HIIT | 💪 Other |

---

## 👩‍💻 Developer

**Developed by:** Humaira  
**Internship:** CodeAlpha — App Development Track  
**Task:** 3 of 4 — Fitness Tracker App  

---

## 📄 License

This project is built for educational purposes as part of the CodeAlpha internship program.

---

<p align="center">Made with ❤️ using Flutter & Firebase</p>
