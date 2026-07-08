class RouteStopModel {
  final String name;
  final double latitude;
  final double longitude;
  final double fare;

  const RouteStopModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fare,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'fare': fare,
    };
  }

  factory RouteStopModel.fromMap(Map<String, dynamic> map) {
    return RouteStopModel(
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      fare: (map['fare'] as num?)?.toDouble() ?? 0.0,
    );
  }
}