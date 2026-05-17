// Bus Model - represents a bus with its stations and fares
// This is used to store and retrieve bus data from Firestore

class BusModel {
  final String? documentId; // Firestore document ID
  final String busId; // Unique bus ID
  final String busName; // Bus name/number
  final List<String> stations; // Ordered list of station names
  final Map<String, double> faresFromSource; // Fare from source to each station

  BusModel({
    this.documentId,
    required this.busId,
    required this.busName,
    required this.stations,
    required this.faresFromSource,
  });

  // Convert BusModel to Map for Firestore
  // This is used when saving data to Firebase
  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busName': busName,
      'stations': stations,
      'faresFromSource': faresFromSource,
    };
  }

  // Create BusModel from Firestore document
  // This is used when reading data from Firebase
  factory BusModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BusModel(
      documentId: documentId,
      busId: map['busId'] ?? documentId,
      busName: map['busName'] ?? '',
      stations: List<String>.from(map['stations'] ?? []),
      faresFromSource: Map<String, double>.from(
        (map['faresFromSource'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
    );
  }

  // Create a copy of BusModel with some fields updated
  // This is useful for editing buses
  BusModel copyWith({
    String? documentId,
    String? busId,
    String? busName,
    List<String>? stations,
    Map<String, double>? faresFromSource,
  }) {
    return BusModel(
      documentId: documentId ?? this.documentId,
      busId: busId ?? this.busId,
      busName: busName ?? this.busName,
      stations: stations ?? this.stations,
      faresFromSource: faresFromSource ?? this.faresFromSource,
    );
  }
}
