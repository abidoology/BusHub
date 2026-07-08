// lib/screens/map_route_picker.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_stop_model.dart';
import '../services/osm_route_service.dart';

class MapRoutePicker extends StatefulWidget {
  final List<RouteStopModel> initialStops;
  final Function(List<RouteStopModel>) onSave;

  const MapRoutePicker({
    Key? key,
    this.initialStops = const [],
    required this.onSave,
  }) : super(key: key);

  @override
  State<MapRoutePicker> createState() => _MapRoutePickerState();
}

class _MapRoutePickerState extends State<MapRoutePicker> {
  final OSMRouteService _routeService = OSMRouteService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();

  final List<RouteStopModel> _stops = [];
  RouteSuggestion? _selectedCandidate;
  int? _editingIndex;
  bool _isLoading = false;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _stops.addAll(widget.initialStops);
    _rebuildRoute();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _selectedCandidate = null;
      });
      return;
    }

    try {
      final results = await _routeService.searchPlaces(query);
      if (!mounted) return;
      
      setState(() {
        if (results.isNotEmpty) {
          _selectedCandidate = results.first;
          _mapController.move(results.first.point, 16);
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _addStop() {
    if (_selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location first')),
      );
      return;
    }

    final fare = double.tryParse(_fareController.text.trim());
    if (fare == null || fare < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fare')),
      );
      return;
    }

    setState(() {
      _stops.add(RouteStopModel(
        name: _selectedCandidate!.name,
        latitude: _selectedCandidate!.point.latitude,
        longitude: _selectedCandidate!.point.longitude,
        fare: fare,
      ));
      _selectedCandidate = null;
      _searchController.clear();
      _fareController.clear();
    });

    _rebuildRoute();
  }

  void _editStop(int index) {
    setState(() {
      _editingIndex = index;
      final stop = _stops[index];
      _searchController.text = stop.name;
      _fareController.text = stop.fare.toString();
      _selectedCandidate = RouteSuggestion(
        name: stop.name,
        point: LatLng(stop.latitude, stop.longitude),
      );
      _mapController.move(LatLng(stop.latitude, stop.longitude), 16);
    });
  }

  void _updateStop() {
    if (_editingIndex == null || _selectedCandidate == null) return;

    final fare = double.tryParse(_fareController.text.trim());
    if (fare == null || fare < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fare')),
      );
      return;
    }

    setState(() {
      _stops[_editingIndex!] = RouteStopModel(
        name: _selectedCandidate!.name,
        latitude: _selectedCandidate!.point.latitude,
        longitude: _selectedCandidate!.point.longitude,
        fare: fare,
      );
      _editingIndex = null;
      _selectedCandidate = null;
      _searchController.clear();
      _fareController.clear();
    });

    _rebuildRoute();
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
      }
    });
    _rebuildRoute();
  }

  void _reorderStops(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
    _rebuildRoute();
  }

  void _rebuildRoute() async {
    if (_stops.length < 2) {
      setState(() {
        _routePoints = _stops
            .map((stop) => LatLng(stop.latitude, stop.longitude))
            .toList();
      });
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final points = await _routeService.buildPolylineFromStops(_stops);
      if (!mounted) return;
      
      setState(() {
        _routePoints = points;
        _isLoadingRoute = false;
      });

      // Fit map to route
      if (points.isNotEmpty) {
        try {
          final bounds = LatLngBounds.fromPoints(points);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(48),
            ),
          );
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _routePoints = _stops
              .map((stop) => LatLng(stop.latitude, stop.longitude))
              .toList();
        });
      }
    }
  }

  void _saveAndReturn() {
    if (_stops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 stops')),
      );
      return;
    }
    widget.onSave(_stops);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingIndex != null ? 'Edit Stop' : 'Route Picker'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveAndReturn,
            child: const Text(
              'Save Route',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Add/Update controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _searchPlaces,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Fare',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _editingIndex != null ? _updateStop : _addStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(_editingIndex != null ? Icons.update : Icons.add),
                ),
              ],
            ),
          ),

          // Map
          SizedBox(
            height: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(23.8103, 90.4125),
                        initialZoom: 12,
                        onTap: (_, point) async {
                          final suggestion = await _routeService.reverseGeocode(point);
                          if (suggestion != null && mounted) {
                            setState(() {
                              _selectedCandidate = suggestion;
                              _searchController.text = suggestion.name;
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'bushub',
                        ),
                        PolylineLayer(
                          polylines: [
                            if (_routePoints.length >= 2)
                              Polyline(
                                points: _routePoints,
                                strokeWidth: 4,
                                color: Colors.green,
                              ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Stops markers
                            ..._stops.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stop = entry.value;
                              final isEditing = _editingIndex == index;
                              return Marker(
                                point: LatLng(stop.latitude, stop.longitude),
                                width: 80,
                                height: 40,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isEditing ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        stop.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            // Selected candidate marker
                            if (_selectedCandidate != null)
                              Marker(
                                point: _selectedCandidate!.point,
                                width: 80,
                                height: 30,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Selected',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_isLoadingRoute)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Stop list
          Expanded(
            child: _stops.isEmpty
                ? const Center(
                    child: Text('Add stops using the search above'),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stops.length,
                    onReorder: _reorderStops,
                    itemBuilder: (context, index) {
                      final stop = _stops[index];
                      return Card(
                        key: ValueKey('${index}-${stop.name}'),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _editingIndex == index
                                ? Colors.orange
                                : Colors.green,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(stop.name),
                          subtitle: Text(
                            'Fare: ${stop.fare.toStringAsFixed(0)} Tk',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editStop(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeStop(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}