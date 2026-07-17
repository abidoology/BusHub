# 🏗️ Chapter 4: System Analysis and Design

This chapter presents the architectural design, workflow, system modules, user roles, data flow, and UML diagrams of the **Dhaka Bus Route & Fare Finder** application.

---

## 🏛️ 4.1 Overall Architecture

The application follows a **Three-Tier Client–Server Architecture**, separating the presentation layer, backend services, and external data services.

<img width="2527" height="2641" alt="01" src="https://github.com/user-attachments/assets/823c910c-a4b5-4ed0-9aec-335771f1c0e2" />

> **📌 Figure 4.1:** System Architecture Diagram

### 🧱 Description of Tiers

#### 📱 Client Tier

- Runs the Flutter mobile application.
- Handles user interactions.
- Displays the user interface.
- Sends requests to Firebase and external APIs.
- Receives and renders application data.

#### ☁️ Server Tier

Firebase acts as the backend server.

- Firebase Authentication manages Admin login.
- Cloud Firestore stores buses and locations.
- Processes requests between the application and the database.

#### 🌍 Data Tier

External services provide mapping and routing functionality.

| Service | Purpose |
|:---------|:--------|
| OpenStreetMap (OSM) | Provides map tiles |
| OSRM API | Generates routes and polylines |
| Nominatim API | Performs geocoding and reverse geocoding |

---

## 🔄 4.2 System Workflow

The workflow describes how data moves through the system from user input to route visualization.

<img width="3711" height="4000" alt="02" src="https://github.com/user-attachments/assets/be2750b5-70ae-4b58-85b3-e8e702528bc1" />

> **📌 Figure 4.2:** System Workflow Diagram

---

## 🧩 4.3 Module Description

The system is divided into several functional modules.

### 🔐 Authentication Module

Responsible for administrator authentication.

**Screen**

- `AdminLoginScreen`

**Functions**

- Admin Login
- Session Management
- Firebase Authentication

---

### 🚌 Admin Module

Responsible for managing bus information.

**Screens**

- `AdminDashboardScreen`
- `AddBusScreen`
- `EditBusScreen`
- `BusDetailsScreen`
- `MapRoutePicker`

**Functions**

- Add Bus
- Edit Bus
- Delete Bus
- Manage Bus Routes

---

### 🔎 User Search Module

Allows users to search for buses between two locations.

**Screen**

- `UserSearchScreen`

**Functions**

- Select Source
- Select Destination
- Search Buses

---

### 📚 Bus Details Module

Displays bus information and routes.

**Screen**

- `BusListScreen`

**Functions**

- View Bus List
- View Complete Route
- View Fare Information

---

### 🗺️ Mapping Module

Responsible for displaying maps and routes.

**Components**

- `flutter_map`
- `OSMRouteService`
- OpenStreetMap
- OSRM API
- Nominatim API

**Functions**

- Display Maps
- Draw Routes
- Display Bus Stops
- Search Locations

---

### 📡 Location Module

Responsible for GPS functionality.

**Package**

- `Geolocator`

**Functions**

- Request Location Permission
- Detect Current Location
- Center Map on User Location

---

### 🗄️ Data Service Module

Handles all communication with Cloud Firestore.

**Class**

- `FirestoreService`

**Functions**

- Read Data
- Write Data
- Update Records
- Delete Records

---

## 👥 4.4 User Roles

The application supports two user roles.

### 👤 General User (Unauthenticated)

Users can:

- Search buses
- View bus routes
- View maps
- View bus details

> Login is **not required**.

---

### 👨‍💼 Administrator (Admin)

Administrators can perform all General User operations plus:

- Login securely
- Add Bus
- Edit Bus
- Delete Bus
- Manage Locations

---

## 🔄 4.5 Data Flow

The system exchanges data in two primary directions.

### 📥 Read Flow

The application retrieves data from:

- Cloud Firestore
- OpenStreetMap
- OSRM API
- Nominatim API

Examples:

- `getLocations()`
- `getAllBuses()`

---

### 📤 Write Flow

Administrators send updated information to Firestore.

Examples:

- `addBus()`
- `updateBus()`
- `deleteBus()`

The application also temporarily stores:

- GPS location
- Route stop information

---

## 🎯 4.6 Use Case Diagram

The Use Case Diagram illustrates the interactions between users and the system.

<img width="4638" height="1606" alt="03" src="https://github.com/user-attachments/assets/ee54b3b8-0a9f-49bf-9549-f143e6a4e087" />

> **📌 Figure 4.3:** Use Case Diagram

---

## 📖 4.7 Use Case Description

### 📋 Table 4.1: Use Case Description — Search Buses

| Element | Description |
|:---------|:------------|
| Use Case Name | Search Buses |
| Actors | General User, Administrator |
| Description | Allows users to search for buses between a selected source and destination. |
| Preconditions | The application is open and an internet connection is available. |
| Postconditions | Matching buses are displayed successfully. |
| Flow of Events | 1. Open the User Search Screen.<br>2. Select the source location.<br>3. Select the destination location.<br>4. Click **Search Buses**.<br>5. The system queries Firestore.<br>6. Matching buses are displayed. |
| Alternate Flow | If either source or destination is missing, the system displays **"Please select both source and destination."** |
| Exception Flow | If the Firestore request fails due to a network error, an error message and retry option are shown. |
| Includes | N/A |
| Extends | View Route on Map |

---

## 🔄 4.8 Activity Diagram — Search Buses

The Activity Diagram illustrates the complete workflow for searching buses.

<img width="2090" height="4684" alt="04" src="https://github.com/user-attachments/assets/b5241339-fc2b-4482-ab94-d1e745a08773" />

> **📌 Figure 4.4:** Activity Diagram for Searching Buses

---

## 📡 4.9 Sequence Diagram — Search Buses

The Sequence Diagram shows the interaction between the User Interface, Firestore, and Mapping Services during a bus search.

<img width="4121" height="2735" alt="05" src="https://github.com/user-attachments/assets/7359af5a-3cad-4bcc-b09e-07db0dca7cd8" />

> **📌 Figure 4.5:** Sequence Diagram for Searching Buses

---

## 🏗️ 4.10 Class Diagram

The Class Diagram illustrates the relationships among screens, services, models, and external APIs used in the application.

<img width="3369" height="4764" alt="06" src="https://github.com/user-attachments/assets/b7af71eb-cf5a-4f7c-a7c4-6b49214af014" />

> **📌 Figure 4.6:** Class Diagram

---
