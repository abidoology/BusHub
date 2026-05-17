import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../services/firestore_service.dart';
import 'bus_details_screen.dart';

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
  final _stationController = TextEditingController();
  final _fareController = TextEditingController();

  final List<String> _stations = [];
  final Map<String, double> _faresFromSource = {};

  bool _isLoading = false;

  @override
  void dispose() {
    _busIdController.dispose();
    _busNameController.dispose();
    _stationController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  // ✅ Capitalize Each Word + numbers allowed (Uttara 7, Mirpur 10)
  bool _isValidCapitalized(String text) {
    final regex =
        RegExp(r'^([A-Z][a-z]*)(\s[A-Z0-9][a-z]*)*$');
    return regex.hasMatch(text.trim());
  }

  // ================= ADD STATION =================
  void _addStation() {
    String stationName = _stationController.text.trim();
    String fareText = _fareController.text.trim();

    if (stationName.isEmpty || fareText.isEmpty) {
      _showError('Please enter both station name and fare');
      return;
    }

    if (!_isValidCapitalized(stationName)) {
      _showError(
        'Station name must be Capitalize Each Word\n'
        'Numbers allowed\n'
        'Example: Uttara 7, Mirpur 10',
      );
      return;
    }

    double? fare = double.tryParse(fareText);
    if (fare == null || fare < 0) {
      _showError('Please enter a valid fare amount');
      return;
    }

    if (_stations.contains(stationName)) {
      _showError('This station already exists');
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

  void _removeStation(String station) {
    setState(() {
      _stations.remove(station);
      _faresFromSource.remove(station);
    });
  }

  // ================= SAVE BUS =================
  Future<void> _saveBus() async {
    if (!_formKey.currentState!.validate()) return;

    if (_stations.length < 2) {
      _showError('Please add at least 2 stations');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ❌ Prevent duplicate Bus ID
      bool exists = await _firestoreService.busIdExists(
        _busIdController.text.trim(),
      );

      if (exists) {
        _showError('Bus ID already exists. Please use a different Bus ID');
        setState(() => _isLoading = false);
        return;
      }

      BusModel bus = BusModel(
        busId: _busIdController.text.trim(),
        busName: _busNameController.text.trim(),
        stations: _stations,
        faresFromSource: _faresFromSource,
      );

      await _firestoreService.addBus(bus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bus added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BusDetailsScreen(),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ================= UI =================
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
              decoration: _inputDecoration('Bus ID', Icons.tag),
              validator: (v) => v!.isEmpty ? 'Bus ID required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _busNameController,
              decoration:
                  _inputDecoration('Bus Name / Number', Icons.directions_bus),
              validator: (v) => v!.isEmpty ? 'Bus name required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Stations (Capitalized + Numbers)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stationController,
              decoration: _inputDecoration(
                'Station Name (e.g., Uttara 7)',
                Icons.location_on,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fareController,
              keyboardType: TextInputType.number,
              decoration:
                  _inputDecoration('Fare from Source (Tk)', Icons.payments),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addStation,
              icon: const Icon(Icons.add),
              label: const Text('Add Station'),
            ),
            const SizedBox(height: 20),
            if (_stations.isNotEmpty)
              ..._stations.map(
                (s) => ListTile(
                  title: Text(s),
                  subtitle: Text('Fare: ${_faresFromSource[s]} Tk'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeStation(s),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBus,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Bus'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
