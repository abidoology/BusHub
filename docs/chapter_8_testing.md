# 🧪 Chapter 8: Testing

This chapter presents the testing process carried out for the **Dhaka Bus Route & Fare Finder** application. The objective of testing is to verify that all functional and non-functional requirements are satisfied and that the system performs reliably under different scenarios.

---

## ✅ 8.1 Test Cases

### 👤 A. Functional Test Cases (User Search)

#### 📋 Table 8.1: Test Cases for User Search

| Test Case ID | Test Description | Test Steps | Expected Result | Actual Result | Status |
|:-------------|:-----------------|:-----------|:----------------|:--------------|:------:|
| TC-U-01 | Valid Search | 1. Navigate to User Search Screen.<br>2. Select Source: **Mohakhali**.<br>3. Select Destination: **Gulshan**.<br>4. Click **Search Buses**. | Bus list appears with relevant buses and fare. | Bus list displayed correctly. | ✅ Pass |
| TC-U-02 | No Source Selected | 1. Navigate to User Search Screen.<br>2. Leave Source empty.<br>3. Select Destination: **Gulshan**.<br>4. Click **Search Buses**. | Error: **"Please select both source and destination."** | Error message displayed. | ✅ Pass |
| TC-U-03 | No Destination Selected | 1. Navigate to User Search Screen.<br>2. Select Source: **Mohakhali**.<br>3. Leave Destination empty.<br>4. Click **Search Buses**. | Error: **"Please select both source and destination."** | Error message displayed. | ✅ Pass |
| TC-U-04 | Same Source & Destination | 1. Navigate to User Search Screen.<br>2. Select Source: **Mohakhali**.<br>3. Select Destination: **Mohakhali**.<br>4. Click **Search Buses**. | Error: **"Source and destination cannot be the same."** | Error message displayed. | ✅ Pass |
| TC-U-05 | No Buses Found | 1. Navigate to User Search Screen.<br>2. Select Source: **Mohakhali**.<br>3. Select Destination: **Uttara**.<br>4. Click **Search Buses**. | Message: **"No buses found."** | No buses found message displayed. | ✅ Pass |
| TC-U-06 | View Route on Map | 1. Perform a valid search (TC-U-01).<br>2. Click **View Route on Map**. | Bottom sheet opens with map and route polyline. | Map with route displayed. | ✅ Pass |

---

### 👨‍💼 B. Functional Test Cases (Admin Panel)

#### 📋 Table 8.2: Test Cases for Admin Panel

| Test Case ID | Test Description | Test Steps | Expected Result | Actual Result | Status |
|:-------------|:-----------------|:-----------|:----------------|:--------------|:------:|
| TC-A-01 | Valid Admin Login | 1. Navigate to Admin Login.<br>2. Enter valid email and password.<br>3. Click **Login**. | Navigate to Admin Dashboard. | Dashboard displayed. | ✅ Pass |
| TC-A-02 | Invalid Admin Login | 1. Navigate to Admin Login.<br>2. Enter invalid credentials.<br>3. Click **Login**. | Error: **"Wrong password"** or **"No admin found."** | Error message displayed. | ✅ Pass |
| TC-A-03 | Add New Bus | 1. Login as Admin.<br>2. Click **Add Bus**.<br>3. Fill the form with valid data.<br>4. Define route using Map Route Picker.<br>5. Click **Save Bus**. | Bus added to Firestore and success message displayed. | Bus added successfully. | ✅ Pass |
| TC-A-04 | Add Bus with Duplicate ID | 1. Login as Admin.<br>2. Click **Add Bus**.<br>3. Enter an existing Bus ID.<br>4. Click **Save Bus**. | Error: **"Bus ID already exists."** | Error message displayed. | ✅ Pass |
| TC-A-05 | Edit Bus | 1. Login as Admin.<br>2. Click **Bus Details**.<br>3. Select a bus and click **Edit**.<br>4. Change bus name.<br>5. Click **Update Bus**. | Bus information updated in Firestore. | Bus updated successfully. | ✅ Pass |
| TC-A-06 | Delete Bus | 1. Login as Admin.<br>2. Click **Bus Details**.<br>3. Select a bus and click **Delete**.<br>4. Confirm deletion. | Bus removed from Firestore. | Bus deleted successfully. | ✅ Pass |

---

### ⚙️ C. Non-Functional Test Cases

#### 📋 Table 8.3: Non-Functional Test Cases

| Test Case ID | Test Description | Test Steps | Expected Result | Actual Result | Status |
|:-------------|:-----------------|:-----------|:----------------|:--------------|:------:|
| TC-NF-01 | Performance – Load Time | 1. Open User Search Screen.<br>2. Measure the time required to load locations. | Locations load within **2–3 seconds**. | Approximately **1.5 seconds** on a 4G connection. | ✅ Pass |
| TC-NF-02 | Usability – Intuitive UI | 1. Ask a non-technical user to search for a bus. | User completes the task without assistance. | Task completed with minimal guidance. | ✅ Pass |
| TC-NF-03 | Portability – Cross-Platform | 1. Run the application on Android and iOS devices. | Application functions correctly on both platforms. | Consistent behavior observed on both platforms. | ✅ Pass |

---
