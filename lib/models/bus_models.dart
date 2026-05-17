// Bus Model - represents a bus with its stations and fares

class BusModel {
  final String? documentId;
  final String busId;
  final String busName;

  BusModel({
    this.documentId,
    required this.busId,
    required this.busName,
  });
}