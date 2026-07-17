# ⚙️ Chapter 7: System Implementation

This chapter details the implementation of the **Dhaka Bus Route & Fare Finder** application, organized by functional modules. The implementation follows the **Model-View-Controller (MVC)** pattern commonly used in Flutter development, with a clear separation between the **UI (Views)**, **Business Logic (Services)**, and **Data Models**.

---

## 📁 7.1 Project Structure

The project follows a standard Flutter project structure with additional organization for scalability.

```text
lib/
├── main.dart                 # Application entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── bus_model.dart
│   ├── location_model.dart
│   └── route_stop_model.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── user_search_screen.dart
│   ├── bus_list_screen.dart
│   ├── admin/
│   │   ├── admin_login_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   ├── add_bus_screen.dart
│   │   ├── edit_bus_screen.dart
│   │   ├── bus_details_screen.dart
│   │   └── map_route_picker.dart
│   └── route_picker_screen.dart
└── services/                 # Business logic
    ├── firestore_service.dart
    ├── osm_route_service.dart
    └── initial_data_service.dart
```

---

## 🧩 7.2 Module Implementation

### 📋 Table 7.1: Implemented Modules and Their Functions

| Module | Key Files | Primary Functions |
|:--------|:----------|:------------------|
| Data Models | `bus_model.dart`, `location_model.dart`, `route_stop_model.dart` | Define data structures and Firestore serialization using `toMap()` and `fromMap()`. |
| Database Service | `firestore_service.dart` | CRUD operations, search buses, fare calculation, and Firestore communication. |
| Mapping Service | `osm_route_service.dart` | OpenStreetMap integration for routing, geocoding, and place search. |
| Authentication | `admin_login_screen.dart` | Administrator authentication using Firebase Authentication. |
| Admin Management | `admin_dashboard_screen.dart`, `add_bus_screen.dart`, `edit_bus_screen.dart`, `bus_details_screen.dart` | Bus management interface. |
| User Search | `user_search_screen.dart` | Search buses and display routes. |
| Bus List | `bus_list_screen.dart` | Display all buses and complete routes. |
| Map Integration | `map_route_picker.dart`, `user_search_screen.dart` | Interactive OpenStreetMap integration using Flutter Map. |

---

## 🚌 7.3 Module 1: Data Models

### 🎯 Purpose

To represent the core data entities of the application in a structured and type-safe manner.

### 📝 Implementation Details

#### 🚌 A. BusModel (`bus_model.dart`)

**Purpose**

Represents a bus with its route, stops, and fare information.

**Key Attributes**

- `documentId`
- `busId`
- `busName`
- `stations`
- `faresFromSource`
- `routeStops`

**Business Logic**

- `toMap()`
- `fromMap()`
- `copyWith()`

##### 💻 Code Explanation

```dart
class BusModel {
  final String? documentId;
  final String busId;
  final String busName;
  final List<String> stations;
  final Map<String, double> faresFromSource;
  final List<RouteStopModel> routeStops;

  // Constructor
  BusModel({...});

  // Serialize to Firestore
  Map<String, dynamic> toMap() {
    final map = {
      'busId': busId,
      'busName': busName,
      'stations': routeStops.isNotEmpty
          ? routeStops.map((stop) => stop.name).toList()
          : stations,
      'faresFromSource': faresFromSource,
    };
    if (routeStops.isNotEmpty) {
      map['route'] = routeStops.map((stop) => stop.toMap()).toList();
    }
    return map;
  }

  // Deserialize from Firestore
  factory BusModel.fromMap(Map<String, dynamic> map, String documentId) {
    final routeStops = (map['route'] as List<dynamic>?)
        ?.map((entry) => RouteStopModel.fromMap(entry as Map<String, dynamic>))
        .toList() ??
        const [];
    // ... other fields
    return BusModel(
      documentId: documentId,
      // ... assign fields
    );
  }
}
```

---

#### 📍 B. RouteStopModel (`route_stop_model.dart`)

**Purpose**

Represents a single stop with GPS coordinates and fare information.

**Key Attributes**

- `name`
- `latitude`
- `longitude`
- `fare`

**Implementation**

Uses the same Firestore serialization pattern as `BusModel`.

---

#### 📍 C. LocationModel (`location_model.dart`)

**Purpose**

Represents a unique bus stop for dropdown menus.

**Key Attributes**

- `locationId`
- `locationName`

**Implementation**

Uses Firestore serialization methods similar to the other models.

---

## 🗄️ 7.4 Module 2: Database Service (FirestoreService)

### 🎯 Purpose

Centralizes all Cloud Firestore operations and provides a clean API for the application.

### 📝 Key Methods and Business Logic

#### 📍 A. Location Management

Functions include:

- `getLocations()`
- `addLocation(String locationName)`

##### 💻 Code

```dart
Future<void> addLocation(String locationName) async {
  try {
    // Check for existing location
    final snapshot = await _firestore
        .collection(_locationsCollection)
        .where('locationName', isEqualTo: locationName)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return; // Location already exists
    }
    
    // Add new location
    await _firestore.collection(_locationsCollection).add({
      'locationName': locationName,
      'locationId': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  } catch (e) {
    throw Exception('Error adding location: $e');
  }
}
```

---

#### 🚌 B. Bus Management

Functions include:

- `getAllBuses()`
- `busIdExists()`
- `addBus()`
- `updateBus()`
- `deleteBus()`

---

#### 🔍 C. Search and Fare Logic

Functions include:

- `searchBuses()`
- `calculateFare()`
- `getStationsWithFares()`
- `getRouteSegment()`

##### 💻 Search Logic

```dart
Stream<List<BusModel>> searchBuses(String source, String destination) {
  return _firestore.collection(_busesCollection).snapshots().map((snapshot) {
    List<BusModel> matchingBuses = [];
    String sourceLC = source.toLowerCase();
    String destinationLC = destination.toLowerCase();
    
    for (var doc in snapshot.docs) {
      BusModel bus = BusModel.fromMap(doc.data(), doc.id);
      
      // Check if both source and destination exist in stations (case-insensitive)
      int sourceIndex = bus.stations
          .indexWhere((s) => s.toLowerCase() == sourceLC);
      int destIndex = bus.stations
          .indexWhere((s) => s.toLowerCase() == destinationLC);
      
      if (sourceIndex != -1 && destIndex != -1 && sourceIndex != destIndex) {
        matchingBuses.add(bus);
      }
    }
    return matchingBuses;
  });
}
```

##### 💻 Fare Calculation

```dart
double calculateFare(BusModel bus, String source, String destination) {
  double sourceFare = bus.faresFromSource[source] ?? 0.0;
  double destinationFare = bus.faresFromSource[destination] ?? 0.0;
  
  double fare = (destinationFare - sourceFare).abs();
  
  // Minimum fare is 10 Taka
  if (fare < 10) fare = 10;
  
  return fare;
}
```

---

## 🗺️ 7.5 Module 3: Mapping Service (OSMRouteService)

### 🎯 Purpose

Integrates OpenStreetMap services for searching, routing, and reverse geocoding.

### 🌐 API Endpoints Used

- Nominatim Search API:
```https://nominatim.openstreetmap.org/search?q={query}&format=jsonv2&limit=8&countrycodes=bd``` 
- Nominatim Reverse API
```https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lon}&format=jsonv2```
- OSRM Routing API
```https://router.project-osrm.org/route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=geojson ```

### 📝 Key Methods

- `searchPlaces()`
- `reverseGeocode()`
- `routeBetween()`
- `buildPolylineFromStops()`

##### 💻 Code

```dart
Future<List<LatLng>> routeBetween(LatLng start, LatLng end) async {
  // Check cache first
  final cacheKey = '${start.latitude},${start.longitude}|${end.latitude},${end.longitude}';
  if (_routeCache.containsKey(cacheKey)) {
    return _routeCache[cacheKey]!;
  }
  
  // Build OSRM URL
  final uri = Uri.parse(
    '$_osrmBase/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=false',
  );
  
  final response = await _client.get(uri);
  // ... process response and decode GeoJSON
  return points;
}
```

### 💡 Design Decisions

- Route caching
- GeoJSON parsing
- Error handling with fallback routing

---

## 🔍 7.6 Module 4: User Search Screen

### 🎯 Purpose

Provides users with an interface to search buses and view routes.

### 🧩 Key Components and Flow

#### 🔎 A. Search Form

Contains:

- Source dropdown
- Destination dropdown
- Search button
- Reset button

##### 💻 Code

```dart
Widget _buildDropdown({...}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(label),
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

#### 🚀 B. Search Execution

Steps:

1. Validate selections.
2. Call `FirestoreService.searchBuses()`.
3. Display results using `StreamBuilder`.

---

#### 📋 C. Results Display

Each result displays:

- Bus information
- Stops
- Fare details
- Route button

---

#### 🗺️ D. Map Integration

Features:

- Flutter Map
- OpenStreetMap
- User location
- Route polyline
- Stop markers

##### 💻 Code

```dart
void _showBusRouteDetails(BusModel bus, String source, String destination) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      // Build route map with OSRM routing
      return _buildRouteMap(routeSegment, source, destination);
    },
  );
}
```

---

## 👨‍💼 7.7 Module 5: Admin Management

### 🎯 Purpose

Provides administrative functionality for managing buses.

---

### 🔐 A. Admin Login (`AdminLoginScreen`)

Features:

- Firebase Authentication
- Form validation
- Error handling

##### 💻 Code

```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    // Navigate to Admin Dashboard
  } on FirebaseAuthException catch (e) {
    // Handle specific error codes
    String errorMessage = 'Login failed';
    if (e.code == 'user-not-found') {
      errorMessage = 'No admin found with this email';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password';
    }
    // Show error message
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

### ➕ B. Add Bus (`AddBusScreen`)

Features:

- Bus form
- Route management
- Duplicate Bus ID validation
- Automatic location creation

##### 💻 Code

```dart
Future<void> _saveBus() async {
  // Validate form
  if (!_formKey.currentState!.validate()) return;
  
  // Validate route stops
  if (_routeStops.length < 2) {
    // Show error
    return;
  }
  
  // Check duplicate Bus ID
  bool exists = await _firestoreService.busIdExists(_busIdController.text.trim());
  if (exists) {
    // Show error
    return;
  }
  
  // Add locations to locations collection
  for (final stop in _routeStops) {
    await _firestoreService.addLocation(stop.name);
  }
  
  // Create and save BusModel
  BusModel bus = BusModel(
    busId: _busIdController.text.trim(),
    busName: _busNameController.text.trim(),
    stations: _routeStops.map((stop) => stop.name).toList(),
    faresFromSource: {
      for (final stop in _routeStops) stop.name: stop.fare,
    },
    routeStops: List<RouteStopModel>.from(_routeStops),
  );
  
  await _firestoreService.addBus(bus);
}
```

---

### ✏️ C. Edit/Delete Bus

Screens:

- `BusDetailsScreen`
- `EditBusScreen`

Functions:

- View buses
- Edit buses
- Delete buses

---

## 🗺️ 7.8 Module 6: Map Route Picker

### 🎯 Purpose

Allows administrators to define bus routes interactively.

### ✨ Key Features

- Search locations
- Tap-to-select
- Enter fare
- Drag-and-drop stop ordering
- Route preview
- Save route

### 📝 Business Logic

Functions include:

- `_searchPlaces()`
- `_addStop()`
- `_rebuildRoute()`
- `_reorderStops()`

##### 💻 Code

```dart
Future<void> _rebuildRoute() async {
  if (_stops.length < 2) {
    setState(() {
      _routePoints = _stops
          .map((stop) => LatLng(stop.latitude, stop.longitude))
          .toList();
    });
    return;
  }
  
  setState(() => _isLoadingRoute = true);
  
  try {
    final points = await _routeService.buildPolylineFromStops(_stops);
    setState(() {
      _routePoints = points;
      _isLoadingRoute = false;
    });
    
    // Fit map to route
    if (points.isNotEmpty) {
      try {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
        );
      } catch (_) {}
    }
  } catch (e) {
    setState(() {
      _isLoadingRoute = false;
      // Fallback to direct connection
      _routePoints = _stops
          .map((stop) => LatLng(stop.latitude, stop.longitude))
          .toList();
    });
  }
}
```

---

## 📦 7.9 Module 7: Initial Data Service

### 🎯 Purpose

Provides sample data for testing and demonstration.

### 📝 Implementation

Functions include:

- `addInitialLocations()`
- `addSampleBuses()`
- `initializeDatabase()`
- `hasData()`

##### 💻 Code

```dart
Future<void> initializeDatabase() async {
  // Check if data already exists
  bool dataExists = await hasData();
  if (dataExists) {
    print('✓ Database already has data. Skipping initialization.');
    return;
  }
  
  await addInitialLocations();
  await addSampleBuses();
  print('✓ Database initialization complete!');
}

Future<bool> hasData() async {
  try {
    final locationsSnapshot = await _firestore.collection('locations').limit(1).get();
    final busesSnapshot = await _firestore.collection('buses').limit(1).get();
    return locationsSnapshot.docs.isNotEmpty || busesSnapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
}
```

---

## 🚀 7.10 Module 8: Main Application

### 🎯 Purpose

Acts as the application's entry point.

### 📝 Implementation (`main.dart`)

Responsibilities:

- Initialize Firebase
- Configure Flutter
- Launch the application
- Apply application theme

##### 💻 Code

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dhaka Bus Route & Fare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

---
