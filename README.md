# Buzz - Order Management & Service Application

Buzz is a Flutter-based application that allows users to browse services, place orders, and manage their requests with a full-featured order tracking system.

## 🚀 Key Features

### Order Management System (Newly Implemented)
*   **My Orders Dashboard**: View all active orders with real-time status updates.
*   **Order History**: Access a complete archive of past and completed orders.
*   **Visual Tracking**: A 4-step progress tracker (Demande → Received → Traitement → Ready) to keep users informed.
*   **Detailed Views**: Full breakdown of order details including price, deadline, and service specifics.

### Payment Integration
*   **Receipt Upload**: Users can stream-line the payment process by uploading photos of their CCP payment receipts directly within the app.
*   **ECCP Info**: Secure entry form for 20-digit CCP account numbers for verification.

### Navigation
*   **Smart Drawer**: Quick navigation between active orders, history, and tracking pages.
*   **Swipe Actions**: Intuitive swipe-to-delete gesture for cancelling pending orders.

## 🏗️ Technical Architecture

This project follows a clean architecture pattern with Provider for state management.

### Key Components
*   **Providers**:
    *   `OrdersProvider`: Manages state for active and archived orders, handles loading states and error propagation.
    *   `UserProvider`, `AuthProvider`, `ServicesProvider`: Core app state.
*   **Services**:
    *   `OrderService`: Handles API calls for creating, fetching, and cancelling orders.
    *   `InvoiceService`: Manages invoice retrieval and payment proof uploads.
*   **UI Components**:
    *   `OrderCard`: Reusable, swipeable widget for order summaries.
    *   `OrderTrackingStepper`: Custom painted widget for visualizing order progress.

### Project Structure
```
lib/
├── api/             # API configuration and endpoints
├── pages/
│   ├── orders/      # [NEW] Order management screens
│   │   ├── order_management_page.dart
│   │   ├── order_history_page.dart
│   │   ├── order_tracking_page.dart
│   │   ├── order_details_page.dart
│   │   ├── payment_upload_page.dart
│   │   └── payment_info_page.dart
├── providers/       # State management
│   └── orders_provider.dart
├── services/        # API integration
│   ├── invoice_service.dart
│   └── order_service.dart
├── Widgets/         # Reusable UI components
│   ├── order_drawer.dart
│   ├── order_card.dart
│   └── order_tracking_stepper.dart
└── routes/          # Navigation configuration
```

## 🛠️ Getting Started

1.  **Clone the repository**
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```

## 🔜 Future Work & Roadmap

*   [ ] **Real-time Notifications**: Push notifications for order status changes.
*   [ ] **In-App Payment**: Direct integration with payment gateways.
*   [ ] **Chat System**: Direct communication channel between user and admin for specific orders.
*   [ ] **Profile Management**: Enhanced user profile with saved payment methods.

## ✅ Recent Updates

*   Implemented full **Order Management System**.
*   Added **Payment Proof Upload** functionality.
*   Integrated **ECCP Account** entry form.
*   Refined **Navigation Routes** and **Side Drawer** implementation.
*   Resolved relative import issues across the new module.
