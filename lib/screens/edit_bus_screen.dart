// lib/screens/admin/edit_bus_screen.dart
import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/route_stop_model.dart';
import '../services/firestore_service.dart';
import 'map_route_picker.dart';

class EditBusScreen extends StatefulWidget {
  final BusModel bus;

  const EditBusScreen({Key? key, required this.bus}) : super(key: key);

  @override
  State<EditBusScreen> createState() => _EditBusScreenState();
}

class _EditBusScreenState extends State<EditBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _busNameController;
  final List<RouteStopModel> _routeStops = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _busNameController = TextEditingController(text: widget.bus.busName);
    _routeStops.addAll(widget.bus.routeStops);
  }

  @override
  void dispose() {
    _busNameController.dispose();
    super.dispose();
  }

  void _openRoutePicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapRoutePicker(
          initialStops: _routeStops,
          onSave: (updatedStops) {
            setState(() {
              _routeStops
                ..clear()
                ..addAll(updatedStops);
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateBus() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_routeStops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 stops'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.bus.documentId == null) {
        throw Exception('Document ID is missing');
      }

      // Add new locations
      for (final stop in _routeStops) {
        await _firestoreService.addLocation(stop.name);
      }

      BusModel updatedBus = BusModel(
        busId: widget.bus.busId,
        busName: _busNameController.text.trim(),
        stations: _routeStops.map((stop) => stop.name).toList(),
        faresFromSource: {
          for (final stop in _routeStops) stop.name: stop.fare,
        },
        routeStops: List<RouteStopModel>.from(_routeStops),
      );

      await _firestoreService.updateBus(
        widget.bus.documentId!,
        updatedBus,
      );

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
        setState(() => _isLoading = false);
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
              controller: _busNameController,
              decoration: const InputDecoration(
                labelText: 'Bus Name / Number',
                prefixIcon: Icon(Icons.directions_bus),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Route Stops',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openRoutePicker,
                  icon: const Icon(Icons.route), // Changed from edit_map
                  label: Text(
                    _routeStops.isEmpty ? 'Add Route' : 'Edit Route',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_routeStops.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.route, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No stops added yet'),
                  ],
                ),
              )
            else
              ..._routeStops.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final stop = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(stop.name),
                      subtitle: Text(
                        'Fare: ${stop.fare.toStringAsFixed(0)} Tk',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _routeStops.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}