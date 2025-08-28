# AnimeAR - AR-Based Anime Character Recognition App

## 🎯 Project Overview

AnimeAR is a comprehensive Flutter application that combines Augmented Reality (AR) technology with anime character recognition. The app uses camera feed to identify anime characters in real-time and overlays interactive information, creating an immersive experience for anime enthusiasts.

## ✨ Key Features

### 🔍 AR Character Recognition
- Real-time camera feed with AR overlay
- Anime character detection using TensorFlow Lite
- Interactive character information display
- Confidence-based detection results

### 🔐 Authentication System
- Firebase Authentication integration
- Email/password and Google Sign-in
- Secure user profile management
- Firestore user data storage

### 🏠 Interactive Dashboard
- Welcome section with user personalization
- Statistics overview (scanned characters, achievements, etc.)
- Feature cards for quick navigation
- Character recommendations and collection display

### 🎨 Modern UI/UX
- Material Design 3 dark theme
- Gradient-based color scheme
- Smooth animations with flutter_animate
- Responsive design for various screen sizes

### 🧭 Navigation
- Bottom navigation with 4 main tabs
- Shell route architecture with go_router
- Seamless navigation flow

## 🏗️ Architecture

### 📁 Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── ar/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   └── social/
└── routes/
```

### 🛠️ Technology Stack
- **Framework**: Flutter (Latest)
- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AR**: ar_flutter_plugin + camera
- **ML**: tflite_flutter
- **Local Storage**: sqflite
- **Animations**: flutter_animate

### 📱 Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.5
  go_router: ^10.1.2
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  ar_flutter_plugin: ^0.7.3
  camera: ^0.10.5
  tflite_flutter: ^0.10.4
  flutter_animate: ^4.2.0
  permission_handler: ^10.4.5
```

## 🎨 Design System

### 🌈 Color Palette
- **Primary**: Deep Purple (#6366F1) with gradients
- **Secondary**: Pink Accent (#EC4899)
- **Background**: Dark theme with surface variations
- **Accent**: Emerald (#10B981) for success states

### 🎯 UI Components
- `CustomTextField`: Styled input fields with validation
- `LoadingButton`: Interactive buttons with loading states
- `CharacterCard`: Display character information
- `FeatureCard`: Navigation cards with gradients
- `StatsOverview`: Dashboard statistics display

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest stable)
- Android Studio / VS Code
- Firebase project setup
- Android SDK with accepted licenses

### Setup Instructions
1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd AnimeAR
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project
   - Add Android/iOS apps to the project
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   flutter run
   ```

### Testing
```bash
flutter test
flutter analyze
```

## 📋 Development Status

### ✅ Completed Features
- [x] Project setup and architecture
- [x] Firebase authentication system
- [x] Home dashboard with statistics
- [x] AR camera interface (basic implementation)
- [x] Navigation system
- [x] Custom UI components
- [x] Theme and styling
- [x] Test suite

### 🔄 In Progress
- [ ] TensorFlow Lite model integration
- [ ] Character database expansion
- [ ] Social features implementation

### 📈 Future Enhancements
- [ ] Offline character database
- [ ] Social sharing capabilities
- [ ] Achievement system
- [ ] Custom AR filters
- [ ] Character collection game mechanics

## 🐛 Known Issues

### Build Issues
- **Android SDK Licenses**: Some environments may require accepting Android SDK licenses
  ```bash
  flutter doctor --android-licenses
  ```

### Dependencies
- **Font Assets**: Custom Inter font currently commented out (fallback to system fonts)
- **Deprecated APIs**: Flutter framework deprecation warnings (info level, non-blocking)

## 🔧 Troubleshooting

### Common Issues
1. **Permission Errors**: Ensure camera permissions are granted
2. **Firebase Errors**: Verify configuration files are correctly placed
3. **Build Failures**: Check Flutter doctor and Android SDK setup

### Debug Commands
```bash
flutter doctor -v
flutter clean && flutter pub get
flutter analyze
```

## 📱 Supported Platforms
- ✅ Android (Primary target)
- ✅ iOS (Compatible)
- ✅ Linux (Development/testing)
- ⚠️ Web (Limited AR functionality)

## 👥 Contributing

This project follows modern Flutter development practices:
- Feature-based architecture
- Provider pattern for state management
- Comprehensive error handling
- Extensive documentation

## 📄 License

This project is developed as a demonstration of Flutter AR capabilities and modern app architecture.

---

## 🎯 Quick Start Commands

```bash
# Development
flutter run --debug

# Testing
flutter test

# Analysis
flutter analyze

# Build (Android)
flutter build apk --debug
```

**Status**: ✅ Project successfully created and validated
**Tests**: ✅ All tests passing
**Architecture**: ✅ Production-ready structure implemented
