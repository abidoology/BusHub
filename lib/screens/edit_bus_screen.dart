// Edit Bus Screen - Admin can edit existing bus details
// Can modify bus name, stations, and fares

import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../services/firestore_service.dart';

class EditBusScreen extends StatefulWidget {
  final BusModel bus;

  const EditBusScreen({Key? key, required this.bus}) : super(key: key);

  @override
  State<EditBusScreen> createState() => _EditBusScreenState();
}

class _EditBusScreenState extends State<EditBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers
  late TextEditingController _busIdController;
  late TextEditingController _busNameController;
  final _stationController = TextEditingController();
  final _fareController = TextEditingController();

  // Lists to store stations and fares
  late List<String> _stations;
  late Map<String, double> _faresFromSource;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing bus data
    _busIdController = TextEditingController(text: widget.bus.busId);
    _busNameController = TextEditingController(text: widget.bus.busName);
    _stations = List.from(widget.bus.stations);
    _faresFromSource = Map.from(widget.bus.faresFromSource);
  }

  @override
  void dispose() {
    _busIdController.dispose();
    _busNameController.dispose();
    _stationController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  // ✅ Capitalize Each Word validation
  bool _isValidCapitalized(String text) {
    final regex = RegExp(r'^([A-Z][a-z]*)(\s[A-Z0-9][a-z]*)*$');
    return regex.hasMatch(text.trim());
  }

  // Add new station to the list
  void _addStation() {
    String stationName = _stationController.text.trim();
    String fareText = _fareController.text.trim();

    if (stationName.isEmpty || fareText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both station name and fare'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ❌ Station format validation
    if (!_isValidCapitalized(stationName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Station name must be in Capitalize Each Word format\n'
            'Example: Airport, Khilkhet Bazar',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? fare = double.tryParse(fareText);
    if (fare == null || fare < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid fare amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _stations.add(stationName);
      _faresFromSource[stationName] = fare;
      _stationController.clear();
      _fareController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Station added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Remove station from the list
  void _removeStation(String station) {
    setState(() {
      _stations.remove(station);
      _faresFromSource.remove(station);
    });
  }

  // Update station fare
  void _editStationFare(String station, double currentFare) {
    final fareController = TextEditingController(text: currentFare.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Fare for $station'),
        content: TextField(
          controller: fareController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Fare from Source (Tk)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              double? newFare = double.tryParse(fareController.text);
              if (newFare != null && newFare >= 0) {
                setState(() {
                  _faresFromSource[station] = newFare;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Update bus in Firestore
  Future<void> _updateBus() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_stations.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 stations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      double firstStationFare = _faresFromSource[_stations.first] ?? 0.0;

      Map<String, double> adjustedFares = {};
      for (String station in _stations) {
        double fare = _faresFromSource[station] ?? 0.0;
        adjustedFares[station] = fare - firstStationFare;
      }

      BusModel updatedBus = BusModel(
        busId: _busIdController.text.trim(),
        busName: _busNameController.text.trim(),
        stations: _stations,
        faresFromSource: adjustedFares,
      );

      if (widget.bus.documentId == null) {
        throw Exception('Document ID is missing');
      }

      await _firestoreService.updateBus(
        widget.bus.documentId!,
        updatedBus,
      );

      for (String station in _stations) {
        await _firestoreService.addLocation(station);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _busIdController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Bus ID',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _busNameController,
              decoration: InputDecoration(
                labelText: 'Bus Name / Number',
                prefixIcon: const Icon(Icons.directions_bus),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bus name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Stations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Add new station card (UNCHANGED UI)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Station',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _stationController,
                      decoration: InputDecoration(
                        labelText: 'Station Name',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fareController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fare from Source (Tk)',
                        prefixIcon: const Icon(Icons.payments),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addStation,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Station'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Existing stations list (UNCHANGED)
            if (_stations.isNotEmpty) ...[
              const Text(
                'Current Stations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _stations.length,
                itemBuilder: (context, index) {
                  String station = _stations[index];
                  double fare = _faresFromSource[station] ?? 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(station),
                      subtitle: Text('Fare: ${fare.toStringAsFixed(0)} Tk'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _editStationFare(station, fare),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeStation(station),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateBus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Bus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
