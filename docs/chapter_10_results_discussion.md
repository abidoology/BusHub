# 📊 Chapter 10: Results and Discussion

This chapter presents the results of the project and provides a discussion of the outcomes, challenges, and overall impact of the **Dhaka Bus Route & Fare Finder** application.

---

## ✅ 10.1 Features Implemented

The application successfully implements all planned features.

### 👤 A. User-Facing Features

1. **Bus Search**
   - Users can search for buses between any two locations from a comprehensive list of Dhaka bus stops.

2. **Route Details**
   - Detailed route information, including all stops and calculated fares, is displayed.

3. **Interactive Map**
   - Bus routes are visualized on an interactive **OpenStreetMap** with markers for each stop.

4. **My Location**
   - Users can center the map on their current GPS location (with permission).

5. **Bus List**
   - Users can browse all available buses and view their complete routes.

---

### 👨‍💼 B. Admin Features

1. **Secure Authentication**
   - Administrator login using email and password through Firebase Authentication.

2. **Bus Management**
   - Administrators can add, edit, and delete bus information.

3. **Route Management**
   - Administrators can define routes with stop locations (latitude and longitude) and fare details.

4. **Data Initialization**
   - A utility is provided to load sample data into the database.

5. **Location Management**
   - The system automatically populates the locations list while preventing duplicate entries.

---

## ⚡ 10.2 Performance

### 📱 A. Application Performance

- **Load Time**
  - The application loads within **1.5–2 seconds** on a standard 4G connection.

- **Search Response**
  - Bus search results appear within **1–2 seconds**, depending on the number of available buses.

- **Map Rendering**
  - OpenStreetMap tiles and route polylines render smoothly on both Android and iOS devices.

- **Memory Usage**
  - The application consumes approximately **150–200 MB** of RAM on a mobile device, which is acceptable for a Flutter application.

---

### 🌐 B. Network Performance

- **Firebase Queries**
  - Database queries are optimized using indexes and by limiting the amount of fetched data.

- **OSRM Routing**
  - Route generation requests typically complete within **500–1000 ms**.

- **Nominatim Search**
  - Place search requests typically complete within **200–500 ms**.

---
