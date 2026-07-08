// lib/screens/admin/add_bus_screen.dart
import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/route_stop_model.dart';
import '../services/firestore_service.dart';
import 'map_route_picker.dart';

class AddBusScreen extends StatefulWidget {
  const AddBusScreen({Key? key}) : super(key: key);

  @override
  State<AddBusScreen> createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _busIdController = TextEditingController();
  final _busNameController = TextEditingController();
  final List<RouteStopModel> _routeStops = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _busIdController.dispose();
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

  Future<void> _saveBus() async {
    if (!_formKey.currentState!.validate()) return;

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
      // Check duplicate bus ID
      bool exists = await _firestoreService.busIdExists(
        _busIdController.text.trim(),
      );

      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus ID already exists. Please use a different Bus ID'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Add locations to locations collection
      for (final stop in _routeStops) {
        await _firestoreService.addLocation(stop.name);
      }

      BusModel bus = BusModel(
        busId: _busIdController.text.trim(),
        busName: _busNameController.text.trim(),
        stations: _routeStops.map((stop) => stop.name).toList(),
        faresFromSource: {
          for (final stop in _routeStops) stop.name: stop.fare,
        },
        routeStops: List<RouteStopModel>.from(_routeStops),
      );

      await _firestoreService.addBus(bus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bus added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _busIdController,
              decoration: const InputDecoration(
                labelText: 'Bus ID',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Bus ID required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _busNameController,
              decoration: const InputDecoration(
                labelText: 'Bus Name / Number',
                prefixIcon: Icon(Icons.directions_bus),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Bus name required' : null,
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
                    Text(
                      'No stops added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Tap "Add Route" to start',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
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
                onPressed: _isLoading ? null : _saveBus,
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
                        'Save Bus',
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