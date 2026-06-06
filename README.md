# Canteen App 🍔

## Project Overview
**Canteen App** is a comprehensive Flutter-based mobile application designed to streamline the food ordering process in educational institutions or corporate canteens. It features separate interfaces for students and administrators, ensuring a seamless experience from ordering to fulfillment.

## Features

### 🎓 Student Features
- **Smart Login/Signup**: Secure authentication using Firebase.
- **Browse Menu**: Explore available food items with categories.
- **Cart Management**: Add items to cart and manage quantities.
- **Real-time Order Tracking**: Monitor the status of orders from "Pending" to "Ready".
- **Order History**: View past orders and detailed summaries.
- **Profile Management**: Maintain personal details and application settings.

### 🛠️ Admin/Staff Features
- **Dashboard**: High-level overview of daily sales and orders.
- **Menu Management**: Add, update, or remove menu items with image support.
- **Order Fulfillment**: Track and update live orders (Pending, Preparing, Ready, Delivered).
- **Sales Reports**: Generate and view detailed sales analytics and reports.

## Technologies Used
- **Flutter & Dart**: For a cross-platform mobile experience.
- **Firebase Authentication**: Secure user login and management.
- **Cloud Firestore**: Real-time NoSQL database for menu and orders.
- **Firebase Storage**: Storing high-quality food images.
- **Provider**: Robust state management.
- **Cloud Messaging**: For real-time order notifications.

## Project Structure
```text
canteen_app/
├── android/
├── ios/
├── lib/
│   ├── models/       # Data structures (Order, Menu, User)
│   ├── providers/    # State management logic
│   ├── screens/      # Student and Admin UI interfaces
│   ├── services/     # Firebase and external API integrations
│   ├── utils/        # Styles, constants, and configurations
│   ├── widgets/      # Reusable UI components
│   └── main.dart     # App entry point
├── test/
├── pubspec.yaml
└── README.md
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
3. **Configure Firebase**:
   - Create a project on [Firebase Console](https://console.firebase.google.com/).
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
4. **Run the app**:
   ```bash
   flutter run
   ```

## Future Improvements
- **Payment Gateway Integration**: Direct payments via UPI/Wallets.
- **Loyalty Points**: Reward systems for frequent users.
- **Dark Mode Support**: Personalized UI themes.
- **Multi-Canteen Support**: Managing multiple outlets in one app.

## Author
**Kavish**
