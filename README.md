# Luxewear_Mobile_Application

A mobile and web fashion e-commerce application built with Flutter and Firebase. Features include user authentication, shopping cart, order management, and user profile — all powered by Cloud Firestore as the backend.

---

## 📱 Platforms Supported

- Android
- iOS

---

## 🔧 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase
  - Firebase Authentication (Email & Password)
  - Cloud Firestore

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or above)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- A [Firebase account](https://firebase.google.com/)

---

## 🔥 Firebase Setup Instructions

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add Project"**
3. Enter a project name (e.g. `LuxewearApp`)
4. Follow the setup wizard and click **"Create Project"**

---

### Step 2: Enable Firebase Authentication

1. In the Firebase Console, go to **Build → Authentication**
2. Click **"Get Started"**
3. Under the **"Sign-in method"** tab, enable **Email/Password**
4. Click **Save**

---

### Step 3: Set Up Cloud Firestore

1. In the Firebase Console, go to **Build → Firestore Database**
2. Click **"Create Database"**
3. Choose **"Start in test mode"** for development
4. Select your preferred Firestore location and click **Done**
5. Once created, go to the **Rules** tab and update for authenticated users:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

6. Click **Publish**

---

### Step 4: Add Firebase to Your App

#### Android

1. In Firebase Console, click the **Android icon** to add an Android app
2. Enter your package name (found in `android/app/build.gradle` → `applicationId`)
3. Download the `google-services.json` file
4. Place it in: `android/app/google-services.json`

#### iOS

1. Click the **iOS icon** to add an iOS app
2. Enter your iOS bundle ID (found in Xcode under project settings)
3. Download the `GoogleService-Info.plist` file
4. Place it in: `ios/Runner/GoogleService-Info.plist`

---

### Step 5: Install Dependencies

Run the following command in the project root:

```bash
flutter pub get
```

---

### Step 6: Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```

---

## 📦 APK Installation

To install the app on an Android device:

1. Download the `app-release.apk` file
2. On your Android device, go to **Settings → Security → Enable Unknown Sources**
3. Open the APK file and follow the installation steps

---

## 📁 Project Structure

```
lib/
├── data/           # App data and constants
├── services/       # Firebase services (auth, firestore)
├── firebase_options.dart
└── main.dart
```

---

## ⚠️ Important Notes

- Never share your `google-services.json` or `GoogleService-Info.plist` files publicly
- Make sure Firestore security rules are properly configured before production deployment
- The `lib/firebase_options.dart` file contains your Firebase configuration — keep it secure

---

## 👤 Author

**2001hilmafathi-hue**  
GitHub: [https://github.com/2001hilmafathi-hue](https://github.com/2001hilmafathi-hue)
