// Bus Model - represents a bus with its stations and fares

class BusModel {
  final String? documentId;
  final String busId;
  final String busName;

  // Ordered list of stations
  final List<String> stations;

  // Fare from source to each station
  final Map<String, double> faresFromSource;

  BusModel({
    this.documentId,
    required this.busId,
    required this.busName,
    required this.stations,
    required this.faresFromSource,
  });

  // Convert BusModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busName': busName,
      'stations': stations,
      'faresFromSource': faresFromSource,
    };
  }
}