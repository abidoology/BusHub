import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

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

  // ================= VALIDATION =================
  bool _isValidCapitalized(String text) {
    final regex = RegExp(r'^([A-Z][a-z]*)(\s[A-Z0-9][a-z]*)*$');
    return regex.hasMatch(text.trim());
  }

  // ================= ADD STATION =================
  void _addStation() {
    String stationName = _stationController.text.trim();
    String fareText = _fareController.text.trim();

    if (stationName.isEmpty || fareText.isEmpty) return;

    if (!_isValidCapitalized(stationName)) return;

    double? fare = double.tryParse(fareText);
    if (fare == null || fare < 0) return;

    if (_stations.contains(stationName)) return;

    setState(() {
      _stations.add(stationName);
      _faresFromSource[stationName] = fare;
      _stationController.clear();
      _fareController.clear();
    });
  }

  void _removeStation(String station) {
    setState(() {
      _stations.remove(station);
      _faresFromSource.remove(station);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bus'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _busIdController,
              decoration: const InputDecoration(labelText: 'Bus ID'),
            ),
            TextFormField(
              controller: _busNameController,
              decoration: const InputDecoration(labelText: 'Bus Name'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _stationController,
              decoration: const InputDecoration(labelText: 'Station'),
            ),
            TextField(
              controller: _fareController,
              decoration: const InputDecoration(labelText: 'Fare'),
              keyboardType: TextInputType.number,
            ),

            ElevatedButton(
              onPressed: _addStation,
              child: const Text('Add Station'),
            ),

            const SizedBox(height: 10),

            ..._stations.map(
              (s) => ListTile(
                title: Text(s),
                subtitle: Text('Fare: ${_faresFromSource[s]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeStation(s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}