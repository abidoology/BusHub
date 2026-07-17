# 🔒 Chapter 9: Security

Security is a paramount concern in any application that handles user data and administrative functions. This chapter outlines the security measures implemented in the **Dhaka Bus Route & Fare Finder** application to protect data, prevent unauthorized access, and ensure system integrity.

---

## 🔐 9.1 Authentication

### 👨‍💼 A. Admin Authentication

- The application uses **Firebase Authentication** for admin login.
- Admin credentials (email and password) are stored securely in Firebase Authentication, not locally on the device.
- Authentication is performed over **HTTPS**, ensuring credentials are encrypted during transmission.

#### 💻 Firebase Authentication Sign-in

```dart
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
);
```

---

### 🔄 B. Session Management

- Firebase Authentication manages user sessions automatically.
- When an admin logs in, a secure authentication token is generated and stored.
- The Firebase SDK automatically refreshes expired tokens.
- Session persistence keeps administrators logged in until they manually sign out.

---

### 🔑 C. Password Security

- Passwords are hashed and salted by Firebase Authentication.
- The application enforces a minimum password length of **6 characters** (configurable).
- Firebase Authentication provides protection against brute-force attacks by limiting login attempts.

---

## 🛡️ 9.2 Authorization

### 👥 A. Role-Based Access Control

- The system supports two user roles:
  - **General User**
  - **Administrator (Admin)**
- General users cannot access the Admin Dashboard or perform CRUD operations.
- Administrative privileges are granted only after successful authentication.

---

### 📋 B. Firestore Security Rules

- Firestore Security Rules control database access at the server level.

#### 💻 Rule Example

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /buses/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /locations/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

#### 📝 Explanation

- **allow read: if true;**
  - Anyone can read bus and location data for public search functionality.

- **allow write: if request.auth != null;**
  - Only authenticated administrators can modify the database.

---

### 🔑 C. API Key Security

- Firebase API keys and configuration are stored in:
  - `google-services.json`
  - `firebase_options.dart`
- These configuration files are bundled with the application.
- Firebase Security Rules provide the primary layer of protection rather than relying solely on API keys.

---

## ✅ 9.3 Validation

### 💻 A. Client-Side Validation

- **Form Validation**
  - `AddBusScreen` and `EditBusScreen` use `Form` widgets and validators to verify required fields, valid data types, and duplicate Bus IDs.

#### 💻 Example

```dart
TextFormField(
  controller: _busIdController,
  validator: (v) => v!.isEmpty ? 'Bus ID required' : null,
)
```

---

- **Data Type Validation**
  - `MapRoutePicker` validates that the entered fare is a valid numeric value.

#### 💻 Example

```dart
final fare = double.tryParse(_fareController.text.trim());

if (fare == null || fare < 0) {
  return;
}
```

---

- **Business Logic Validation**
  - The `searchBuses()` method verifies that:
    - Source is selected.
    - Destination is selected.
    - Source and destination are different.

---

### ☁️ B. Server-Side Validation

- Firestore Security Rules enforce data validation and access control.
- The Firebase SDK performs additional validation before requests are sent to the server.

---

## 🗄️ 9.4 Database Security

### 🔒 A. Data Encryption

- Cloud Firestore encrypts stored data using **AES-256** encryption.
- All transmitted data is protected using **TLS/SSL** encryption.

---

### 🏢 B. Data Isolation

- The Firestore database is isolated within the **fir-e50da** Firebase project.
- Access to the Firebase Console is controlled using **Google Cloud IAM** permissions.

---

### 🛡️ C. Firebase Security Rules

- Firestore Security Rules restrict write operations to authenticated users only.
- These rules prevent unauthorized database access and data modification.

---

## 🌐 9.5 API Security

### 🔗 A. External API Integration

- All external API requests use **HTTPS**.
- Integrated APIs include:
  - OpenStreetMap
  - Nominatim
  - OSRM
- Public APIs do not require API keys.
- Requests include a custom **User-Agent** header.

#### 💻 Example

```dart
headers: {
  'Accept': 'application/json',
  'User-Agent': 'bushub/1.0 (Flutter)',
}
```

---

### 📱 B. Network Security Configuration (Android)

- The `network_security_config.xml` file allows cleartext traffic for selected domains during development.

#### 💻 Example

```xml
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">firestore.googleapis.com</domain>
        <domain includeSubdomains="true">nominatim.openstreetmap.org</domain>
        <domain includeSubdomains="true">router.project-osrm.org</domain>
    </domain-config>

    <debug-overrides>
        <trust-anchors>
            <certificates src="system"/>
            <certificates src="user"/>
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```

---

## ⚠️ 9.6 Error Handling

- **Graceful Degradation**
  - The application displays user-friendly error messages instead of crashing.

- **Logging**
  - Errors are logged during development for debugging.
  - Production environments can integrate Firebase Crashlytics.

- **User Feedback**
  - SnackBars and AlertDialogs notify users when operations fail.

#### 💻 Example

```dart
try {
  await _firestoreService.addBus(bus);

} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 🔄 9.7 Session Management

- **Login Session**
  - Firebase Authentication manages administrator sessions.

- **Token Expiration**
  - Authentication tokens expire after approximately **1 hour**.
  - Firebase automatically refreshes tokens for authenticated users.

- **Logout**
  - The `_logout()` method terminates the session and returns the user to the application's home screen.

#### 💻 Example

```dart
Future<void> _logout(BuildContext context) async {

  await FirebaseAuth.instance.signOut();

  Navigator.of(context).popUntil(
    (route) => route.isFirst,
  );
}
```

---

## ✅ 9.8 Security Best Practices Followed

1. **Principle of Least Privilege**
   - Users receive only the permissions required for their roles.

2. **Defense in Depth**
   - Multiple security layers are implemented, including client-side validation, Firebase Authentication, and Firestore Security Rules.

3. **Secure Communication**
   - All network communication uses HTTPS/TLS encryption.

4. **Data Minimization**
   - Only essential user and application data are stored.

5. **User Education**
   - Error messages provide meaningful information without exposing sensitive system details.

---
