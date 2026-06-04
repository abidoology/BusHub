// Location Model - represents a location/station in Dhaka
// This is used to populate dropdown menus

class LocationModel {
  final String locationId; // Unique location ID
  final String locationName; // Display name of the location

  LocationModel({
    required this.locationId,
    required this.locationName,
  });

  // Convert LocationModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'locationName': locationName,
    };
  }

  // Create LocationModel from Firestore document
  factory LocationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LocationModel(
      locationId: map['locationId'] ?? documentId,
      locationName: map['locationName'] ?? '',
    );
  }
}
