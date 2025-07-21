# Doomscroll - Digital Wellbeing & Screen Time Management App

## 📱 Overview
Doomscroll is an iOS application designed to help users manage their screen time and develop healthier digital habits. The app provides tools for tracking usage, setting blocking rules, mood tracking, and educational resources about digital wellbeing.

## ✨ Key Features

### 🎯 Dashboard
- Real-time screen time analytics
- Quick mood and urge tracking
- Level-based progression system
- Custom blocking rules and schedules

### 📓 Journal & Tasks
- Daily journal entries
- Habit tracking
- Task management
- Progress visualization

### 📊 Analytics
- Detailed usage statistics
- Mood trends over time
- Habit completion rates
- Screen time breakdown by app/website

### 📚 Education
- Articles on digital wellbeing
- Tips for reducing screen time
- Mindfulness exercises
- Habit formation guidance

### ⚙️ Settings
- Notification preferences
- App blocking rules
- Data privacy controls
- Customization options

## 🛠 Technical Stack
- **Platform**: iOS
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependencies**:
  - UserNotifications for local notifications
  - ScreenTime API for usage monitoring
  - Core Data for local storage

## 📁 Project Structure
```
doomscroll/
├── doomscroll/               # Main app target
│   ├── Assets.xcassets/      # App assets and icons
│   ├── Core/                 # Core functionality
│   ├── Features/             # Feature modules
│   │   ├── Analytics/        # Analytics screens and logic
│   │   ├── Blocking/         # App blocking functionality
│   │   ├── Dashboard/        # Main dashboard views
│   │   ├── Education/        # Educational content
│   │   ├── JournalTasks/     # Journal and task management
│   │   ├── MoodTracking/     # Mood tracking features
│   │   └── Settings/         # App settings
│   ├── Resources/            # Additional resources
│   └── Shared/               # Shared components and utilities
├── doomscroll.xcodeproj/     # Xcode project file
├── doomscrollTests/          # Unit tests
└── doomscrollUITests/        # UI tests
```

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 16.0+
- Swift 5.0+

### Installation
1. Clone the repository
2. Open `doomscroll.xcodeproj` in Xcode
3. Build and run the project on a simulator or physical device

## 🤝 Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📬 Contact
For any questions or feedback, please open an issue in the repository.
