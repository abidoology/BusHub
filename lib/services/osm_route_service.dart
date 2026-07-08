import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_stop_model.dart';

class RouteSuggestion {
  final String name;
  final LatLng point;

  const RouteSuggestion({required this.name, required this.point});
}

class OSMRouteService {
  OSMRouteService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, List<RouteSuggestion>> _searchCache = {};
  final Map<String, List<LatLng>> _routeCache = {};

  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const String _osrmBase = 'https://router.project-osrm.org';

  Future<List<RouteSuggestion>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    if (_searchCache.containsKey(trimmed)) {
      return _searchCache[trimmed]!;
    }

    final uri = Uri.parse(
      '$_nominatimBase/search?q=${Uri.encodeComponent(trimmed)}&format=jsonv2&addressdetails=1&limit=8&countrycodes=bd',
    );

    final response = await _client.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'bushub/1.0 (Flutter)',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search places');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    final suggestions = decoded.map((entry) {
      final map = entry as Map<String, dynamic>;
      return RouteSuggestion(
        name: map['display_name'] ?? '',
        point: LatLng(
          double.parse(map['lat'] as String),
          double.parse(map['lon'] as String),
        ),
      );
    }).toList();

    _searchCache[trimmed] = suggestions;
    return suggestions;
  }

  Future<RouteSuggestion?> reverseGeocode(LatLng point) async {
    final uri = Uri.parse(
      '$_nominatimBase/reverse?lat=${point.latitude}&lon=${point.longitude}&format=jsonv2&addressdetails=1',
    );

    final response = await _client.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'bushub/1.0 (Flutter)',
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final displayName = decoded['display_name'] as String?;
    if (displayName == null || displayName.isEmpty) {
      return null;
    }

    return RouteSuggestion(name: displayName, point: point);
  }

  Future<List<LatLng>> routeBetween(LatLng start, LatLng end) async {
    final cacheKey = '${start.latitude},${start.longitude}|${end.latitude},${end.longitude}';
    if (_routeCache.containsKey(cacheKey)) {
      return _routeCache[cacheKey]!;
    }

    final uri = Uri.parse(
      '$_osrmBase/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=false',
    );

    final response = await _client.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'bushub/1.0 (Flutter)',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load route geometry');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = decoded['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      return const [];
    }

    final geometry = routes.first['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    final points = coordinates
        .map(
          (entry) => LatLng(
            (entry[1] as num).toDouble(),
            (entry[0] as num).toDouble(),
          ),
        )
        .toList();

    _routeCache[cacheKey] = points;
    return points;
  }

  Future<List<LatLng>> buildPolylineFromStops(List<RouteStopModel> stops) async {
    if (stops.length < 2) {
      return stops
          .map((stop) => LatLng(stop.latitude, stop.longitude))
          .toList();
    }

    final polyline = <LatLng>[];
    for (var index = 0; index < stops.length - 1; index++) {
      final start = LatLng(stops[index].latitude, stops[index].longitude);
      final end = LatLng(stops[index + 1].latitude, stops[index + 1].longitude);
      final segment = await routeBetween(start, end);

      if (segment.isEmpty) {
        polyline.add(start);
        polyline.add(end);
      } else {
        if (polyline.isNotEmpty && polyline.last == segment.first) {
          polyline.addAll(segment.skip(1));
        } else {
          polyline.addAll(segment);
        }
      }
    }

    return polyline;
  }
}