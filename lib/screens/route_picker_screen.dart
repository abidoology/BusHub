import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_stop_model.dart';
import '../services/osm_route_service.dart';

class RoutePickerScreen extends StatefulWidget {
  final List<RouteStopModel> initialStops;

  const RoutePickerScreen({super.key, this.initialStops = const []});

  @override
  State<RoutePickerScreen> createState() => _RoutePickerScreenState();
}

class _RoutePickerScreenState extends State<RoutePickerScreen> {
  final OSMRouteService _routeService = OSMRouteService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();

  final List<RouteStopModel> _stops = [];

  Future<List<RouteSuggestion>>? _suggestionsFuture;
  Future<List<LatLng>>? _polylineFuture;

  RouteSuggestion? _selectedCandidate;
  int? _selectedStopIndex;
  bool _isLoadingRoute = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _stops.addAll(widget.initialStops);
    _rebuildRoutePreview();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  void _updateSuggestions(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestionsFuture = Future.value(const []);
        _selectedCandidate = null;
      });
      return;
    }

    setState(() {
      _suggestionsFuture = _routeService.searchPlaces(query);
    });
  }

  void _selectCandidate(RouteSuggestion suggestion) {
    setState(() {
      _selectedCandidate = suggestion;
      _statusMessage = suggestion.name;
    });
  }

  void _selectMapPoint(LatLng point) async {
    final suggestion = await _routeService.reverseGeocode(point);
    if (!mounted) {
      return;
    }

    if (suggestion == null) {
      setState(() {
        _selectedCandidate = RouteSuggestion(
          name: 'Selected point (${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)})',
          point: point,
        );
        _statusMessage = 'Map point selected';
      });
      return;
    }

    setState(() {
      _selectedCandidate = suggestion;
      _statusMessage = suggestion.name;
    });
  }

  void _addSelectedStop() {
    final candidate = _selectedCandidate;
    if (candidate == null) {
      _showSnackBar('Select a location first');
      return;
    }

    final fare = double.tryParse(_fareController.text.trim());
    if (fare == null || fare < 0) {
      _showSnackBar('Enter a valid fare');
      return;
    }

    setState(() {
      _stops.add(
        RouteStopModel(
          name: candidate.name,
          latitude: candidate.point.latitude,
          longitude: candidate.point.longitude,
          fare: fare,
        ),
      );
      _fareController.clear();
      _selectedCandidate = null;
      _searchController.clear();
      _suggestionsFuture = Future.value(const []);
    });

    _rebuildRoutePreview();
  }

  void _editStop(int index) {
    final stop = _stops[index];
    final nameController = TextEditingController(text: stop.name);
    final fareController = TextEditingController(text: stop.fare.toString());

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Stop Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fareController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fare',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final fare = double.tryParse(fareController.text.trim());
              if (fare == null || fare < 0 || nameController.text.trim().isEmpty) {
                return;
              }

              setState(() {
                _stops[index] = RouteStopModel(
                  name: nameController.text.trim(),
                  latitude: stop.latitude,
                  longitude: stop.longitude,
                  fare: fare,
                );
              });
              Navigator.pop(context);
              _rebuildRoutePreview();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
      if (_selectedStopIndex == index) {
        _selectedStopIndex = null;
      }
    });
    _rebuildRoutePreview();
  }

  Future<void> _reorderStops(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
    _rebuildRoutePreview();
  }

  void _rebuildRoutePreview() {
    setState(() {
      _isLoadingRoute = true;
      _polylineFuture = _stops.length >= 2
          ? _routeService.buildPolylineFromStops(_stops)
          : Future.value(
              _stops
                  .map((stop) => LatLng(stop.latitude, stop.longitude))
                  .toList(),
            );
    });

    _polylineFuture?.whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    });
  }

  void _fitMapToStops(List<LatLng> points) {
    if (points.isEmpty) {
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      try {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(48),
          ),
        );
      } catch (_) {
        // Ignore fit errors when the map is not ready yet.
      }
    });
  }

  void _saveAndExit() {
    if (_stops.length < 2) {
      _showSnackBar('Add at least 2 stops');
      return;
    }
    Navigator.pop(context, List<RouteStopModel>.from(_stops));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    for (var index = 0; index < _stops.length; index++) {
      final stop = _stops[index];
      final isSelected = _selectedStopIndex == index;
      markers.add(
        Marker(
          point: LatLng(stop.latitude, stop.longitude),
          width: 120,
          height: 60,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStopIndex = index;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    stop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(Icons.location_pin, color: Colors.red, size: 34),
              ],
            ),
          ),
        ),
      );
    }

    if (_selectedCandidate != null) {
      markers.add(
        Marker(
          point: _selectedCandidate!.point,
          width: 110,
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Icon(Icons.place, color: Colors.orange, size: 30),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Route Stops'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveAndExit,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _updateSuggestions,
                  decoration: InputDecoration(
                    hintText: 'Search a location with Nominatim',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _updateSuggestions('');
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fareController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fare for selected stop',
                          prefixIcon: Icon(Icons.payments),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addSelectedStop,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stop'),
                    ),
                  ],
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(23.8103, 90.4125),
                        initialZoom: 12,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onTap: (tapPosition, point) {
                          _selectMapPoint(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'bushub',
                        ),
                        FutureBuilder<List<LatLng>>(
                          future: _polylineFuture,
                          builder: (context, snapshot) {
                            final points = snapshot.data ?? const <LatLng>[];
                            if (points.isNotEmpty) {
                              _fitMapToStops(points);
                            }
                            return PolylineLayer(
                              polylines: [
                                if (points.length >= 2)
                                  Polyline(
                                    points: points,
                                    strokeWidth: 4,
                                    color: Colors.green,
                                  ),
                              ],
                            );
                          },
                        ),
                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                    if (_isLoadingRoute)
                      const Positioned(
                        top: 12,
                        right: 12,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 18,
                              height: 18,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 88,
              child: FutureBuilder<List<RouteSuggestion>>(
                future: _suggestionsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final suggestions = snapshot.data!;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ActionChip(
                        label: Text(
                          suggestion.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => _selectCandidate(suggestion),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _stops.isEmpty
                ? Center(
                    child: Text(
                      'Add stops in order. Route preview will update automatically.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _stops.length,
                    onReorder: _reorderStops,
                    itemBuilder: (context, index) {
                      final stop = _stops[index];
                      return Card(
                        key: ValueKey('$index-${stop.name}'),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(stop.name),
                          subtitle: Text(
                            '${stop.latitude.toStringAsFixed(5)}, ${stop.longitude.toStringAsFixed(5)} • Fare ${stop.fare.toStringAsFixed(0)} Tk',
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
