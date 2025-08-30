# AnimeAR - AR-Based Anime Character Recognition App

## 🎯 Project Overview

AnimeAR is a comprehensive Flutter application that combines Augmented Reality (AR) technology with anime character recognition. The app uses real camera feed to identify anime characters in real-time and provides an immersive AR experience for anime enthusiasts.

## ✨ Key Features

### 📱 **In-App Camera System**
- **Real-time camera preview** within the app (no external camera redirection)
- **Permission management** for camera, location, notifications, and storage
- **First-launch onboarding** with beautiful permission request screen
- **Multiple camera support** (front/back switching)
- **Flash controls** with auto/on/off/torch modes
- **Camera testing utilities** for debugging and verification

### 🔍 **AR Character Recognition**
- Live camera feed with AR overlay capabilities
- Anime character detection framework (ready for ML integration)
- Interactive character information display
- Confidence-based detection results with bounding boxes

### 🔐 **Authentication & User Management**
- Firebase Authentication with Google Sign-in
- Automatic user profile creation and management
- Real-time profile synchronization
- Secure data storage with Firestore

### 🏠 **Interactive Dashboard**
- Personalized welcome section with dynamic usernames
- Real-time statistics (scanned characters, achievements)
- Quick access feature cards
- Recent discoveries and character collection

### 🎨 **Modern UI/UX**
- **Beautiful gradient theme** with purple/cyane color scheme
- Material Design 3 with dark theme
- Smooth animations and transitions
- Responsive design for all screen sizes
- Fixed overflow issues and optimized layouts

### 🔧 **Developer Features**
- **Camera Test Screen** for debugging camera functionality
- Real-time permission status monitoring
- Comprehensive error handling and recovery
- Debug logging and state management

## 🏗️ **Technical Architecture**

### 📁 **Project Structure**
```
lib/
├── core/
│   ├── services/          # Camera, Permission services
│   ├── providers/         # Global state management
│   ├── widgets/           # App startup, navigation
│   └── theme/            # Design system
├── features/
│   ├── ar/               # Camera and AR functionality
│   ├── auth/             # Authentication system
│   ├── home/             # Dashboard and main screens
│   ├── profile/          # User profile management
│   ├── permissions/      # Permission onboarding
│   └── social/           # Social features
└── routes/               # Navigation configuration
```

### 🛠️ **Technology Stack**
- **Framework**: Flutter (Latest)
- **State Management**: flutter_riverpod 2.4.5
- **Navigation**: go_router 16.2.0
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Camera**: Native camera plugin with permission_handler
- **Local Storage**: sqflite + shared_preferences
- **Animations**: flutter_animate 4.2.0

### 📱 **Core Dependencies**
```yaml
dependencies:
  # State & Navigation
  flutter_riverpod: ^2.4.5
  go_router: ^16.2.0
  
  # Firebase
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.1
  cloud_firestore: ^6.0.0
  google_sign_in: ^6.2.0
  
  # Camera & Permissions
  camera: ^0.11.2
  permission_handler: ^11.0.1
  
  # Storage & Utilities
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  
  # ML & Image Processing
  tflite_flutter: ^0.11.0
  image: ^4.1.3
```

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK 3.9.0+
- Android Studio / VS Code
- Firebase project setup
- Physical device for camera testing

### **Installation**
1. **Clone the repository**
   ```bash
   git clone https://github.com/AnjishnuSengupta/AnimeAR.git
   cd AnimeAR
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project
   - Add Android/iOS configuration files
   - Enable Authentication and Firestore
   - Or run the setup_firebase.sh script for quick startup

4. **Run the app**
   ```bash
   flutter run --debug
   ```

## 🎯 **App Flow**

### **First Launch**
1. **Permission Onboarding**: Beautiful screen requesting essential permissions
2. **Camera Permission**: Required for core AR functionality
3. **Optional Permissions**: Location, notifications, storage for enhanced features

### **Main Features**
1. **Home Dashboard**: User stats, recent discoveries, feature access
2. **AR Camera**: Live camera with character recognition
3. **Camera Test**: Developer tool for testing camera functionality
4. **Profile**: User management and settings

### **Navigation**
- **Bottom Navigation**: Home, AR Camera, Social, Profile
- **Quick Access**: Camera Test button on home screen
- **Error Recovery**: "Go to Home" buttons on error screens

## 🎨 **Design System**

### 🌈 **Color Palette**
- **Primary**: Purple (#6C5CE7) - Modern gradient primary
- **Secondary**: Cyan (#00CEC9) - Accent and highlights  
- **Background**: Dark (#0D0E1B) - Premium dark theme
- **Surface**: Navy (#1A1B2E) - Card and surface colors

### 📱 **Key UI Components**
- **PermissionScreen**: Animated onboarding with permission cards
- **FeatureCard**: Gradient-based navigation cards
- **CameraPreview**: Real-time camera display with controls
- **AROverlay**: Detection results and interactive elements

## 🔒 **Permissions System**

### **Required Permissions**
- **Camera**: Essential for AR character recognition
- **Location**: Optional for location-based recommendations
- **Notifications**: Optional for app updates and discoveries
- **Storage**: Optional for saving character images

### **Permission Flow**
1. **Check Status**: Verify current permission state
2. **Request Dialog**: Show permission rationale
3. **Handle Denial**: Guide users to settings if needed
4. **Persistent Storage**: Remember permission choices

## 🧪 **Testing & Debugging**

### **Camera Test Screen**
- Access via "Camera Test" button on home screen
- Real-time permission status display
- Camera initialization debugging
- Multiple camera detection
- Error handling verification

### **Debug Features**
- Console logging for all major operations
- Error boundaries with recovery options
- State management debugging
- Permission status monitoring

## 🚀 **Deployment**

### **Build for Release**
```bash
# Android APK
flutter build apk --release

# Android Bundle
flutter build appbundle --release
```

### **Firebase Setup**
1. Configure authentication providers
2. Set up Firestore security rules
3. Configure storage bucket permissions

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Test thoroughly (especially camera functionality)
5. Submit a pull request

## � **License**

This project is licensed under the MIT License. See LICENSE file for details.

## 🆘 **Support**

For issues, questions, or contributions:
- Create an issue on GitHub
- Check the camera test screen for debugging
- Verify permissions are properly granted

**AnimeAR** - Bringing anime characters to life through AR technology! 🎌✨
