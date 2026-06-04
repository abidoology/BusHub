// Firestore Service - handles all Firebase operations
// This class provides methods to read and write data from/to Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';
import '../models/location_model.dart';

class FirestoreService {
  // Get Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final String _busesCollection = 'buses';
  final String _locationsCollection = 'locations';

  // ==================== LOCATION METHODS ====================

  // Get all locations for dropdown menus
  Stream<List<LocationModel>> getLocations() {
    return _firestore
        .collection(_locationsCollection)
        .snapshots()
        .map((snapshot) {
      List<LocationModel> locations = snapshot.docs
          .map((doc) => LocationModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by location name
      locations.sort((a, b) => a.locationName.compareTo(b.locationName));
      
      return locations;
    }).handleError((error) {
      // Return empty list on error instead of throwing
      return <LocationModel>[];
    });
  }

  // Add a new location to Firestore (prevents duplicates)
  Future<void> addLocation(String locationName) async {
    try {
      final snapshot = await _firestore
          .collection(_locationsCollection)
          .where('locationName', isEqualTo: locationName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return;
      }

      await _firestore.collection(_locationsCollection).add({
        'locationName': locationName,
        'locationId': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      throw Exception('Error adding location: $e');
    }
  }

  // ==================== BUS METHODS ====================

  // ✅ Check if Bus ID already exists
  Future<bool> busIdExists(String busId) async {
    final snapshot = await _firestore
        .collection(_busesCollection)
        .where('busId', isEqualTo: busId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get all buses
  Stream<List<BusModel>> getAllBuses() {
    return _firestore
        .collection(_busesCollection)
        .orderBy('busName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new bus to Firestore
  Future<void> addBus(BusModel bus) async {
    try {
      await _firestore.collection(_busesCollection).add(bus.toMap());
    } catch (e) {
      throw Exception('Error adding bus: $e');
    }
  }

  // Update an existing bus
  Future<void> updateBus(String documentId, BusModel bus) async {
    try {
      await _firestore
          .collection(_busesCollection)
          .doc(documentId)
          .update(bus.toMap());
    } catch (e) {
      throw Exception('Error updating bus: $e');
    }
  }

  // Delete a bus from Firestore
  Future<void> deleteBus(String documentId) async {
    try {
      await _firestore.collection(_busesCollection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Error deleting bus: $e');
    }
  }

  // ==================== SEARCH & FARE LOGIC ====================

  // Search buses between two locations (case-insensitive)
  Stream<List<BusModel>> searchBuses(String source, String destination) {
    return _firestore.collection(_busesCollection).snapshots().map((snapshot) {
      List<BusModel> matchingBuses = [];

      String sourceLC = source.toLowerCase();
      String destinationLC = destination.toLowerCase();

      for (var doc in snapshot.docs) {
        BusModel bus = BusModel.fromMap(doc.data(), doc.id);

        int sourceIndex = bus.stations
            .indexWhere((s) => s.toLowerCase() == sourceLC);
        int destIndex = bus.stations
            .indexWhere((s) => s.toLowerCase() == destinationLC);

        if (sourceIndex != -1 && destIndex != -1) {
          matchingBuses.add(bus);
        }
      }

      return matchingBuses;
    });
  }

  // Calculate fare between two stations (minimum 10 taka)
  double calculateFare(BusModel bus, String source, String destination) {
    double sourceFare = bus.faresFromSource[source] ?? 0.0;
    double destinationFare = bus.faresFromSource[destination] ?? 0.0;

    double fare = (destinationFare - sourceFare).abs();

    if (fare < 10) fare = 10;

    return fare;
  }

  // Get stations between source & destination with fares
  Map<String, double> getStationsWithFares(
    BusModel bus,
    String source,
    String destination,
  ) {
    Map<String, double> stationsWithFares = {};

    String sourceLC = source.toLowerCase();
    String destinationLC = destination.toLowerCase();

    int sourceIndex = bus.stations
        .indexWhere((s) => s.toLowerCase() == sourceLC);
    int destIndex = bus.stations
        .indexWhere((s) => s.toLowerCase() == destinationLC);

    if (sourceIndex == -1 || destIndex == -1) {
      return stationsWithFares;
    }

    double sourceFare = bus.faresFromSource[source] ?? 0.0;
    bool isReverse = sourceIndex > destIndex;

    if (isReverse) {
      for (int i = sourceIndex; i >= destIndex; i--) {
        String station = bus.stations[i];
        double stationFare = bus.faresFromSource[station] ?? 0.0;
        
        // For reverse route, calculate fare as difference between source and this station
        double fare = (sourceFare - stationFare).abs();

        if (station.toLowerCase() != sourceLC && fare < 10) fare = 10;

        stationsWithFares[station] = fare;
      }
    } else {
      for (int i = sourceIndex; i <= destIndex; i++) {
        String station = bus.stations[i];
        double fare =
            (bus.faresFromSource[station] ?? 0.0) - sourceFare;

        if (station.toLowerCase() != sourceLC && fare < 10) fare = 10;

        stationsWithFares[station] = fare;
      }
    }

    return stationsWithFares;
  }
}
