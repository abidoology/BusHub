# 📖 Chapter 3: Requirement Analysis
## 🚀 3.1 Functional Requirements

Functional requirements define the specific features and behaviours that the system must provide for both administrators and users.

### 📋 Table 3.1: Functional Requirements

| ID | Module | Requirement | Description |
|:---------|:-------|:------------|:------------|
| FR-01 | Authentication | Admin Login | System must allow Admin to log in using email and password via Firebase Authentication. |
| FR-02 | Admin Dashboard | View Dashboard | Admin must be able to access a dashboard for managing bus information. |
| FR-03 | Admin - Buses | Add Bus | Admin can add a new bus with Bus ID, name, and complete route including stops and fares. |
| FR-04 | Admin - Buses | Edit Bus | Admin can update existing bus information and routes. |
| FR-05 | Admin - Buses | Delete Bus | Admin can remove a bus and all associated route information. |
| FR-06 | Admin - Buses | View Bus List | Admin can view the complete list of registered buses. |
| FR-07 | Admin - Locations | Add Location | The system automatically stores newly added bus stops in the `locations` collection for search suggestions. |
| FR-08 | User - Search | Select Source & Destination | Users can select source and destination from dropdown lists populated from Firestore. |
| FR-09 | User - Search | Search Buses | Users can search available buses between selected locations. |
| FR-10 | User - Results | Display Results | The system displays matching buses with fare details and expandable stop information. |
| FR-11 | User - Results | View Route on Map | Users can view the selected route segment on an interactive OpenStreetMap. |
| FR-12 | User - Map | Display Route | The system retrieves routing data from OSRM and displays it as a polyline on the map. |
| FR-13 | User - Map | Show Stops on Map | Bus stops along the selected route are displayed as map markers. |
| FR-14 | User - Map | My Location | Users can center the map on their current GPS location (with permission). |
| FR-15 | User - Bus List | View All Buses | Users can browse all buses and their complete routes in a bottom sheet. |

---

## ⚙️ 3.2 Non-Functional Requirements

Non-functional requirements describe the quality attributes and operational characteristics of the system.

### 📋 Table 3.2: Non-Functional Requirements

| ID | Attribute | Requirement |
|:---|:----------|:------------|
| NFR-01 | Performance | Bus data and routes should load within **2–3 seconds** on a standard 4G connection. |
| NFR-02 | Security | Firestore Security Rules must protect all data, and admin actions require authentication. |
| NFR-03 | Reliability | The application should provide reliable service with minimal downtime using Firebase infrastructure. |
| NFR-04 | Scalability | The system should efficiently support thousands of buses and concurrent users. |
| NFR-05 | Usability | The interface should be simple, intuitive, and easy to navigate. |
| NFR-06 | Maintainability | Source code should be modular, reusable, well-documented, and follow Flutter coding standards. |
| NFR-07 | Portability | The application should run on both Android and iOS platforms. |
| NFR-08 | Availability | The application should remain available 24/7 through Firebase cloud services. |

---

## 💻 3.3 Software Requirements

The following software components are required for development and deployment.

- **Operating System:** Android 5.0+, iOS 12.0+, or Web Browser (Testing)
- **Development IDE:** Android Studio, Visual Studio Code (VS Code)
- **SDK:** Flutter SDK (≥ 3.0.0), Dart SDK (≥ 2.18.0)
- **Backend:** Firebase (Cloud Firestore & Firebase Authentication)
- **Version Control:** Git

---

## 🖥️ 3.4 Hardware Requirements

### 📋 Table 3.3: Hardware Requirements

| Device | Specification |
|:-------|:--------------|
| Development Machine | **Minimum:** Intel Core i3, 8 GB RAM, 100 GB HDD<br>**Recommended:** Intel Core i5, 16 GB RAM, SSD |
| Target Smartphone | Android 5.0+ / iOS 12.0+, GPS Sensor, Internet Connectivity |

---

## 🛠️ 3.5 Technology Stack

The project uses the following technologies.

### 📋 Table 3.4: Technology Stack

| Tier | Technology | Purpose |
|:-----|:-----------|:--------|
| Frontend | Flutter | Cross-platform UI Framework |
| Backend | Firebase | Backend as a Service (BaaS) |
| Database | Cloud Firestore | NoSQL Cloud Database |
| Authentication | Firebase Authentication | Secure User Authentication |
| Maps | Flutter Map | OpenStreetMap UI Widget |
| Routing | OSRM / OpenRouteService | Route Calculation Service |
| Geocoding | Nominatim | Search & Reverse Geocoding |
| Location | Geolocator | GPS Location Access |
| Programming Language | Dart | Flutter Development Language |

---

## ✅ Rationale for Technology Selection

### 🎨 Flutter

- Build Android and iOS applications from a **single codebase**.
- Fast development using **Hot Reload**.
- High performance with a rich widget ecosystem.

---

### ☁️ Firebase (Cloud Firestore & Firebase Authentication)

- Fully managed cloud backend.
- Real-time NoSQL database.
- Secure authentication system.
- Highly scalable and reliable infrastructure.

---

### 🗺️ OpenStreetMap (OSM) & Flutter Map

- Free and open-source alternative to Google Maps.
- No API usage cost.
- Highly customizable map rendering.
- Excellent integration with Flutter.

---

### 🚗 OSRM & 📍 Nominatim

**OSRM**
- Provides fast route calculation.
- Generates route geometry for map visualization.

**Nominatim**
- Supports place searching.
- Performs forward and reverse geocoding.

Both services work seamlessly with OpenStreetMap data.

---

### 📡 Geolocator

- Cross-platform Flutter plugin.
- Provides accurate GPS location.
- Enables the **My Location** feature.
- Handles location permissions consistently across Android and iOS.

---
