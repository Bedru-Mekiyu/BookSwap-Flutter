# BookSwap Mobile & API Platform

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/Riverpod-State%20Management-purple)](https://riverpod.dev)
[![Backend](https://img.shields.io/badge/Node.js-Express%20%2F%20MongoDB-green?logo=nodedotjs)](https://nodejs.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**BookSwap** is a full-stack mobile platform that enables users to list, discover, and exchange physical and digital books seamlessly. Built with a modern **Flutter** frontend utilizing **Riverpod** for robust state management and a **Node.js/MongoDB** backend service, BookSwap simplifies community-driven book sharing with role-based features for users and administrators.

---

## Key Features

### User Platform
- **User Authentication**: Secure sign-up, login, profile management, and password updates.
- **Book Catalog & Discovery**: Browse available books with search, genre filtering, and detail views.
- **My Book Collection**: Add, edit, and maintain personal listings (including photos, metadata, and optional PDF links).
- **Swap Requests**: Initiate, track, accept, or decline swap requests between community members.

### Admin Dashboard
- **Platform Analytics**: High-level overview of users, total listings, and transaction metrics.
- **User Management**: View user registries, adjust user statuses, or add new accounts.
- **Content Moderation**: Manage book listings across the platform.

---

## Tech Stack & Architecture

- **Frontend**: Flutter (Dart), Flutter Riverpod (State Management), Dio (HTTP Client), SharedPreferences (Local Storage).
- **Backend**: Node.js, Express.js, Mongoose (MongoDB ODM), Bcrypt (Password Hashing).
- **Communication**: RESTful API endpoints with JWT/Bearer token authentication.

### Directory Overview
```
BookSwap-Flutter/
├── Frontend/             # Mobile Client Application
│   ├── lib/
│   │   ├── core/        # Dio HTTP client, Interceptors, Global Utilities
│   │   ├── providers/   # Riverpod State Providers (Auth, Admin, Book)
│   │   ├── *.dart       # Screen Views (Home, Login, Admin Dashboard, Swap Requests, etc.)
├── backend/              # Node.js API Service
│   ├── models/          # Mongoose Schemas (User, Book, Swap Request)
└── docs/                # Architecture and System Documentation
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0 or higher)
- [Node.js](https://nodejs.org/) (v16 or higher)
- [MongoDB](https://www.mongodb.com/) (Local instance or MongoDB Atlas)

---

### Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the `backend/` directory:
   ```env
   PORT=4000
   MONGO_URI=mongodb://localhost:27017/bookswap
   JWT_SECRET=your_jwt_secret_key
   ```

4. **Start the API Server:**
   ```bash
   npm start
   ```

---

### Mobile App Setup (Frontend)

1. **Navigate to the Frontend directory:**
   ```bash
   cd Frontend
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL:**
   Update `Frontend/lib/core/dio_client.dart` with your backend server URL (e.g., `http://10.0.2.2:4000` for Android Emulator or your server IP address).

4. **Run the Application:**
   ```bash
   flutter run
   ```

---

## Quality & Testing

To run Flutter code analysis and verify code health:

```bash
cd Frontend
flutter analyze
```

---

## License

Distributed under the MIT License. See `LICENSE` for details.
