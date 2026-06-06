# Canteen App 🍔

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

**Canteen App** is a modern, full-stack mobile solution designed to digitalize canteen operations. It bridges the gap between students and canteen staff, reducing wait times and improving order management through real-time synchronization.

---

## 🌟 Features

### 🎓 For Students
- **🔐 Secure Access**: Seamless login and signup using Firebase Auth.
- **🍕 Digital Menu**: Browse categorized food items with vivid images and real-time prices.
- **🛒 Smart Cart**: Easily add/remove items and view a summarized bill before checking out.
- **🕒 Order Tracking**: Get real-time updates on your order status (Pending → Preparing → Ready).
- **📄 History**: Access a complete record of all your past orders and receipts.

### 🛠️ For Admin & Staff
- **📊 Live Dashboard**: Monitor total daily sales and order volume at a glance.
- **🍔 Menu Architect**: Real-time management of menu items (stock availability, pricing, images).
- **📋 Kitchen Queue**: Manage incoming orders and update their status to notify students instantly.
- **📈 Analytical Reports**: Detailed sales breakdowns and performance analytics.

---

## 🚀 Technologies Used
- **Frontend**: Flutter Framework (Dart)
- **Backend**: Google Firebase (Firestore, Authentication, Storage)
- **State Management**: Provider
- **Local Config**: `google-services.json` (Android configuration)

---

## 📂 Project Structure
```text
canteen_app/
├── android/          # Android platform-specific configurations
├── lib/
│   ├── models/       # Data blueprints (User, Menu, Order)
│   ├── providers/    # App state and logic handlers
│   ├── screens/      # All UI Screens (Login, Home, Admin Panel)
│   ├── services/     # Firebase & Database integration logic
│   ├── utils/        # Theme data, constants, and global config
│   ├── widgets/      # Custom reusable UI components
│   └── main.dart     # Entry point of the application
├── pubspec.yaml      # All project dependencies
└── README.md         # Documentation
```

---

## 🛠️ Installation & Setup
To run this project locally, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Kavish9090/Canteen_app.git
   ```
2. **Navigate to project folder**:
   ```bash
   cd Canteen_app
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Firebase Setup**:
   - Create a new project on the [Firebase Console](https://console.firebase.google.com/).
   - Enable **Authentication** (Email/Password), **Firestore**, and **Storage**.
   - Download the `google-services.json` and place it in `android/app/`.
5. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🔮 Future Roadmap
- [ ] **UPI Payment**: Integrate Razorpay or Stripe for digital payments.
- [ ] **Push Notifications**: Immediate alerts when an order is ready for pickup.
- [ ] **Token System**: Auto-generation of QR-based tokens for order validation.
- [ ] **Dark Mode**: A sleek interface for late-night study sessions.

## ✍️ Author
Designed & Developed with ❤️ by **Kavish**
