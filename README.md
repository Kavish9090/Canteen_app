# Canteen App

## Project Overview
Canteen App is a Flutter-based mobile application designed to simplify food ordering in canteens. It provides separate interfaces for students to place orders and administrators to manage the menu and fulfillment process.

## Features

### Student Side
- User authentication via Firebase
- Digital menu with item categories
- Cart management (Add/Remove items)
- Real-time order status tracking
- View past order history

### Admin Side
- Sales and order dashboard
- Menu management (Add/Update/Delete items)
- Order processing and status updates
- Sales reports and analytics

## Technologies Used
- Flutter & Dart
- Firebase (Authentication, Firestore, Storage)
- Provider (State Management)

## Project Structure
```text
canteen_app/
├── android/          # Platform-specific Android files
├── lib/
│   ├── models/       # Data models
│   ├── providers/    # State management
│   ├── screens/      # UI Screens
│   ├── services/     # Firebase integrations
│   ├── utils/        # Constants and theme
│   ├── widgets/      # Reusable components
│   └── main.dart     # Entry point
├── pubspec.yaml      # Dependencies
└── README.md         # Documentation
```

## Steps to Run the Project
1. **Clone the repository**:
   ```bash
   git clone https://github.com/Kavish9090/Canteen_app.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Firebase Setup**:
   - Add your `google-services.json` in `android/app/`.
   - Enable Authentication, Firestore, and Storage in Firebase Console.
4. **Run the app**:
   ```bash
   flutter run
   ```

## Future Improvements
- Integration of digital payment gateways
- Push notifications for order updates
- QR code-based order validation
- Dark mode support

## Author
**Kavish**
