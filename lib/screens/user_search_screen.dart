// lib/screens/user_search_screen.dart
// User Search Screen - Main user interface for searching buses
// Uses dropdown menus for source and destination selection

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/bus_model.dart';
import '../models/location_model.dart';
import '../models/route_stop_model.dart';
import '../services/firestore_service.dart';
import '../services/osm_route_service.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _firestoreService = FirestoreService();
  final MapController _mapController = MapController();

  static const LatLng _dhakaCenter = LatLng(23.8103, 90.4125);
  static const double _dhakaZoom = 12.0;

  // Selected values
  String? _selectedSource;
  String? _selectedDestination;

  // Map state
  LatLng? _userLocation;
  bool _isFetchingLocation = false;

  // Search state
  bool _hasSearched = false;

  // Search for buses
  void _searchBuses() {
    if (_selectedSource == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both source and destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSource == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and destination cannot be the same'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _hasSearched = true;
    });
  }

  // Reset search
  void _resetSearch() {
    setState(() {
      _selectedSource = null;
      _selectedDestination = null;
      _hasSearched = false;
    });
  }

  Future<void> _centerOnUserLocation() async {
    if (_isFetchingLocation) {
      return;
    }

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final position = await _determineCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }

      setState(() {
        _userLocation = userLocation;
      });

      _mapController.move(userLocation, 16);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_formatLocationError(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<Position> _determineCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable them and try again.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  String _formatLocationError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }

  // Show bus route details with map
  void _showBusRouteDetails(BusModel bus, String source, String destination) {
    final stationsWithFares = _firestoreService.getStationsWithFares(
      bus,
      source,
      destination,
    );

    final totalFare = _firestoreService.calculateFare(
      bus,
      source,
      destination,
    );

    // Get route segment with coordinates
    final routeSegment = _firestoreService.getRouteSegment(
      bus,
      source,
      destination,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus.busName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bus ID: ${bus.busId}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total Fare: ${totalFare.toStringAsFixed(0)} Tk',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Map with route
                  SizedBox(
                    height: 280,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildRouteMap(
                          routeSegment,
                          source,
                          destination,
                        ),
                      ),
                    ),
                  ),

                  // Stop list with fares
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: stationsWithFares.length,
                      itemBuilder: (context, index) {
                        final entry = stationsWithFares.entries.toList()[index];
                        final station = entry.key;
                        final fare = entry.value;
                        final isSource = station == source;
                        final isDestination = station == destination;

                        // Find if this stop has coordinates
                        final routeStop = routeSegment.firstWhere(
                          (stop) => stop.name == station,
                          orElse: () => RouteStopModel(
                            name: station,
                            latitude: 0.0,
                            longitude: 0.0,
                            fare: fare,
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSource || isDestination
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSource || isDestination
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isSource || isDestination
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      station,
                                      style: TextStyle(
                                        fontWeight: isSource || isDestination
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (routeStop.latitude != 0.0 ||
                                        routeStop.longitude != 0.0)
                                      Text(
                                        '📍 ${routeStop.latitude.toStringAsFixed(4)}, ${routeStop.longitude.toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSource || isDestination
                                      ? Colors.green.shade100
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${fare.toStringAsFixed(0)} Tk',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSource || isDestination
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build route map with OSM routing
  Widget _buildRouteMap(
    List<RouteStopModel> routeStops,
    String source,
    String destination,
  ) {
    if (routeStops.isEmpty || routeStops.length < 2) {
      return const Center(
        child: Text('Route not available for this segment'),
      );
    }

    // Check if stops have coordinates
    final hasCoordinates = routeStops.any(
      (stop) => stop.latitude != 0.0 || stop.longitude != 0.0,
    );

    if (!hasCoordinates) {
      return const Center(
        child: Text('No location data available for this route'),
      );
    }

    return FutureBuilder<List<LatLng>>(
      future: OSMRouteService().buildPolylineFromStops(routeStops),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<LatLng> points = snapshot.data ?? [];

        // If OSRM fails, use direct points
        if (points.isEmpty || points.length < 2) {
          points = routeStops.map((stop) {
            // Skip stops without coordinates
            if (stop.latitude == 0.0 && stop.longitude == 0.0) {
              return null;
            }
            return LatLng(stop.latitude, stop.longitude);
          }).whereType<LatLng>().toList();
        }

        if (points.isEmpty || points.length < 2) {
          return const Center(
            child: Text('Route cannot be displayed'),
          );
        }

        // Create markers
        final markers = <Marker>[];
        final validStops = routeStops.where(
          (stop) => stop.latitude != 0.0 || stop.longitude != 0.0,
        ).toList();

        for (int i = 0; i < validStops.length; i++) {
          final stop = validStops[i];
          final isSource = stop.name == source;
          final isDestination = stop.name == destination;

          markers.add(
            Marker(
              point: LatLng(stop.latitude, stop.longitude),
              width: 120,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  // Show stop name on tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(stop.name),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSource ? Colors.blue : 
                           isDestination ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSource ? Icons.flag : 
                        isDestination ? Icons.flag : Icons.location_on,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Fit bounds to show all points
        try {
          final bounds = LatLngBounds.fromPoints(points);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(32),
                ),
              );
            }
          });
        } catch (_) {
          // Ignore fit errors
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: points.first,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'bushub',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 5,
                    color: Colors.green,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Buses'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // Search form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<List<LocationModel>>(
                  stream: _firestoreService.getLocations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingDropdown('Loading locations...');
                    }

                    if (snapshot.hasError) {
                      return _buildLoadingDropdown('Error loading locations');
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyDropdown(
                        'No locations available',
                        'Please contact admin to add locations',
                      );
                    }

                    List<String> locations =
                        snapshot.data!.map((loc) => loc.locationName).toList();
                    locations = locations.toSet().toList();

                    return _buildDropdown(
                      label: 'From (Source)',
                      icon: Icons.location_on,
                      value: _selectedSource,
                      items: locations,
                      onChanged: (value) {
                        setState(() {
                          _selectedSource = value;
                          _hasSearched = false;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<LocationModel>>(
                  stream: _firestoreService.getLocations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingDropdown('Loading locations...');
                    }

                    if (snapshot.hasError) {
                      return _buildLoadingDropdown('Error loading locations');
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyDropdown(
                        'No locations available',
                        'Please contact admin to add locations',
                      );
                    }

                    List<String> locations =
                        snapshot.data!.map((loc) => loc.locationName).toList();
                    locations = locations.toSet().toList();

                    return _buildDropdown(
                      label: 'To (Destination)',
                      icon: Icons.location_on,
                      value: _selectedDestination,
                      items: locations,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value;
                          _hasSearched = false;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _searchBuses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            SizedBox(width: 8),
                            Text(
                              'Search Buses',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _resetSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map section
          _buildMapSection(),

          // Search results
          _buildSearchResults(),
        ],
      ),
    );
  }

  // Build map section with user location
  Widget _buildMapSection() {
    final markers = <Marker>[
      if (_userLocation != null)
        Marker(
          point: _userLocation!,
          width: 140,
          height: 90,
          child: _buildLocationMarker(),
        ),
    ];

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OpenStreetMap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Interactive map centered on Dhaka, Bangladesh',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _userLocation ?? _dhakaCenter,
                        initialZoom: _userLocation == null ? _dhakaZoom : 16,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'bushub',
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FloatingActionButton(
                        heroTag: 'my_location_button',
                        onPressed:
                            _isFetchingLocation ? null : _centerOnUserLocation,
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        mini: true,
                        child: _isFetchingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userLocation == null
                  ? 'Tap My Location to request permission and mark your current position.'
                  : 'You are here',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'You are here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 42,
        ),
      ],
    );
  }

  // Updated dropdown with separators between items
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(label),
                value: value,
                items: [
                  // Add a divider at the top
                  const DropdownMenuItem<String>(
                    value: null,
                    enabled: false,
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                  ),
                  ...items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item),
                          // Add divider after each item except the last one
                          if (items.indexOf(item) != items.length - 1)
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 8,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: onChanged,
                // Customize dropdown style
                dropdownColor: Colors.white,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                // Add elevation for better visibility
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDropdown(String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropdown(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select locations and search for buses',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: StreamBuilder<List<BusModel>>(
        stream: _firestoreService.searchBuses(
          _selectedSource!,
          _selectedDestination!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No buses found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try different locations',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final buses = snapshot.data!;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];

              final stationsWithFares = _firestoreService.getStationsWithFares(
                bus,
                _selectedSource!,
                _selectedDestination!,
              );

              final totalFare = _firestoreService.calculateFare(
                bus,
                _selectedSource!,
                _selectedDestination!,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.green,
                    ),
                  ),
                  title: Text(
                    bus.busName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Bus ID: ${bus.busId}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Fare: ${totalFare.toStringAsFixed(0)} Tk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Route & Fares:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...stationsWithFares.entries.map((entry) {
                            final station = entry.key;
                            final fare = entry.value;

                            final isSource = station == _selectedSource;
                            final isDestination = station == _selectedDestination;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    isSource || isDestination
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSource || isDestination
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          station,
                                          style: TextStyle(
                                            fontWeight: isSource || isDestination
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (!isSource)
                                          Text(
                                            '${fare.toStringAsFixed(0)} Tk from $_selectedSource',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}