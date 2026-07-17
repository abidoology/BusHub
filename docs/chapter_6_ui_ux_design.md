# 🎨 Chapter 6: UI / UX Design

This chapter presents the User Interface (UI) and User Experience (UX) design of the **Dhaka Bus Route & Fare Finder** application. The interface is designed with simplicity, accessibility, and ease of navigation in mind to provide an intuitive experience for both passengers and administrators.

The application uses a **green color theme**, symbolizing trust, safety, and sustainability, making it suitable for a public transportation service.

---

## 🏠 6.1 Home Screen

### 🎯 Purpose

The **Home Screen** is the entry point of the application. It introduces the application and provides quick navigation to the main features.

### 🧩 Components

#### 📌 AppBar

- Application title: **Dhaka Bus Route & Fare**
- Admin Login icon button

#### 📄 Body

##### 👋 Greeting Section

- Application logo
- Welcome message
- Short introduction

##### ✨ Feature Card

Displays the application's key features.

##### 🚀 Action Buttons

- **View Bus Details**
- **Search Buses**

### 🔀 Navigation

| Action | Destination |
|:--------|:------------|
| View Bus Details | `BusListScreen` |
| Search Buses | `UserSearchScreen` |
| Admin Icon | `AdminLoginScreen` |

<img width="400" height="800" alt="d19977de-24a7-45da-bdc5-119c47d9001a" src="https://github.com/user-attachments/assets/f1e8ca9d-7bde-4ea7-8d2f-fe391468bdbe" />


> **📌 Figure 6.1:** Home Screen

---

## 🔍 6.2 User Search Screen

### 🎯 Purpose

Allows users to search for buses between two locations while providing an interactive map and search results.

### 🧩 Components

#### 📌 AppBar

- Title: **Search Buses**

#### 🔎 Search Form

Contains:

- Source dropdown
- Destination dropdown
- **Search Buses** button
- Reset button

#### 🗺️ Map Section

Displays:

- OpenStreetMap
- Current location
- Selected route
- Bus stop markers

#### 📋 Results Section

Displays matching buses using **ExpansionTile** widgets.

Each result shows:

- Bus Name
- Bus ID
- Total Fare
- Route Stops
- Fare List
- **View Route on Map** button

### 🔀 User Interaction

1. Select Source.
2. Select Destination.
3. Click **Search Buses**.
4. View matching buses.
5. Tap **View Route on Map**.
6. View detailed route.
7. Tap **My Location** to center the map.

<img width="300" height="800" alt="WhatsApp Image 2026-07-10 at 10 26 47 PM" src="https://github.com/user-attachments/assets/c0183ac3-e322-4818-84ae-df4ab4d21bd5" />

<img width="380" height="800" alt="add24054-7770-4543-8fe7-963fe9338173" src="https://github.com/user-attachments/assets/1b373061-0f9a-4bb7-aa75-576c5d33d1a5" />

<img width="380" height="800" alt="409c61cd-5487-47c1-9d7b-8199158f6685" src="https://github.com/user-attachments/assets/50fc287d-f062-4613-8b18-a404ca3fefc4" />


> **📌 Figure 6.2:** User Search Screen

---

## 🚌 6.3 Bus Details (List) Screen

### 🎯 Purpose

Displays all buses available in the system along with their complete routes.

### 🧩 Components

#### 📌 AppBar

- Title: **View Bus Details**

#### 🔍 Search Bar

Allows filtering buses by:

- Bus Name

#### 📃 Bus List

Each card displays:

- Bus Name
- Bus ID
- Total Stations

#### 📄 Route Details Bottom Sheet

Displays:

- Complete route
- Ordered bus stops
- Start point
- End point

### 🔀 Navigation

| Action | Result |
|:--------|:-------|
| Tap Bus Card | Opens Route Details Bottom Sheet |

<img width="380" height="800" alt="b2f34a9e-002d-498d-812a-d1cb4659c03b" src="https://github.com/user-attachments/assets/93bb77f5-f0b1-4d8f-9233-278357344ba0" />
<img width="380" height="800" alt="a79c35a0-7f57-402e-adaf-f4a776a98cb7" src="https://github.com/user-attachments/assets/0e9f0449-d4ca-4d6a-8f4d-e91d079d55c6" />

> **📌 Figure 6.3:** Bus Details Screen

---

## 👨‍💼 6.4 Admin Dashboard Screen

### 🎯 Purpose

Acts as the central control panel for administrators.

### 🧩 Components

#### 📌 AppBar

- Title: **Admin Dashboard**
- Logout button

#### 📄 Body

##### 👋 Welcome Section

Displays an administrator greeting.

##### ⚙️ Dashboard Buttons

- ➕ Add Bus
- 📋 Bus Details
- 📥 Load Sample Data

### 🔀 Navigation

| Button | Destination |
|:--------|:------------|
| Add Bus | `AddBusScreen` |
| Bus Details | `BusDetailsScreen` |
| Load Sample Data | Executes `InitialDataService` |

<img width="380" height="800" alt="e8afa408-3a45-4239-9354-d443d1ae1fcf" src="https://github.com/user-attachments/assets/6bdc1afd-7bbe-4e91-aa9f-8a484372d549" />
<img width="380" height="800" alt="623696cf-d800-4626-bbb1-19cb43c003d6" src="https://github.com/user-attachments/assets/fde90769-9d73-4834-8382-81de5d55ec5f" />

> **📌 Figure 6.4:** Admin Dashboard Screen

---

## ✏️ 6.5 Add / Edit Bus Screens

### 🎯 Purpose

Provides forms for creating new buses and updating existing bus information.

### 🧩 Components

#### 📌 AppBar

Displays either:

- **Add New Bus**
- **Edit Bus**

#### 📝 Bus Information Form

Fields include:

- Bus ID *(Add Screen only)*
- Bus Name

#### 🛣️ Route Management

Displays:

- Current route
- Stop order
- Fare information

#### 🗺️ Route Picker Button

Opens:

- `MapRoutePicker`

#### 📍 Stop List

Displays:

- Stop Number
- Stop Name
- Fare
- Delete button

#### 💾 Save Button

- Save Bus
- Update Bus

### 🔀 User Interaction

1. Enter Bus ID.
2. Enter Bus Name.
3. Open **MapRoutePicker**.
4. Add route stops.
5. Define fares.
6. Save the bus.
7. Data is stored in Cloud Firestore.

<img width="380" height="800" alt="2c41d9ea-9912-43a9-b02e-751371798b5a" src="https://github.com/user-attachments/assets/5326c1bd-bfee-4616-a698-3e5d5dc3f2eb" />
<img width="380" height="800" alt="5b7461df-ccaa-4e50-9f1b-c40c01c3f851" src="https://github.com/user-attachments/assets/7a28db1b-b517-4ba8-ab0a-0f4f93e02fe8" />

> **📌 Figure 6.5:** Add Bus Screen

<img width="380" height="800" alt="f138c527-dbdf-44a9-aeeb-5c9ddf2c2a01" src="https://github.com/user-attachments/assets/cba11e6a-14d2-46ec-9313-85dabfc7a8d0" />

> **📌 Figure 6.6:** Edit Bus Screen

---
