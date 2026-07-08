import 'route_stop_model.dart';

// Bus Model - represents a bus with its stations and fares
// This is used to store and retrieve bus data from Firestore

class BusModel {
  final String? documentId; // Firestore document ID
  final String busId; // Unique bus ID
  final String busName; // Bus name/number
  final List<String> stations; // Ordered list of station names
  final Map<String, double> faresFromSource; // Fare from source to each station
  final List<RouteStopModel> routeStops; // Optional geo-aware route stops

  BusModel({
    this.documentId,
    required this.busId,
    required this.busName,
    required this.stations,
    required this.faresFromSource,
    this.routeStops = const [],
  });

  // Convert BusModel to Map for Firestore
  // This is used when saving data to Firebase
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

  // Create BusModel from Firestore document
  // This is used when reading data from Firebase
  factory BusModel.fromMap(Map<String, dynamic> map, String documentId) {
    final routeStops = (map['route'] as List<dynamic>?)
            ?.map((entry) => RouteStopModel.fromMap(entry as Map<String, dynamic>))
            .toList() ??
        const [];

    final fareSource = map['faresFromSource'] as Map<String, dynamic>?;

    return BusModel(
      documentId: documentId,
      busId: map['busId'] ?? documentId,
      busName: map['busName'] ?? '',
      stations: List<String>.from(map['stations'] ?? []),
      faresFromSource: fareSource == null
          ? <String, double>{}
          : Map<String, double>.from(
              fareSource.map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            ),
      routeStops: routeStops,
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
    List<RouteStopModel>? routeStops,
  }) {
    return BusModel(
      documentId: documentId ?? this.documentId,
      busId: busId ?? this.busId,
      busName: busName ?? this.busName,
      stations: stations ?? this.stations,
      faresFromSource: faresFromSource ?? this.faresFromSource,
      routeStops: routeStops ?? this.routeStops,
    );
  }
}
