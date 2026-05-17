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

  late TextEditingController _busIdController;
  late TextEditingController _busNameController;
  final _stationController = TextEditingController();
  final _fareController = TextEditingController();

  late List<String> _stations;
  late Map<String, double> _faresFromSource;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _busIdController = TextEditingController(text: widget.bus.busId);
    _busNameController = TextEditingController(text: widget.bus.busName);
    _stations = List.from(widget.bus.stations);
    _faresFromSource = Map.from(widget.bus.faresFromSource);
  }

  void _addStation() {
    String station = _stationController.text.trim();
    double? fare = double.tryParse(_fareController.text);

    if (station.isEmpty || fare == null) return;

    setState(() {
      _stations.add(station);
      _faresFromSource[station] = fare;
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
  void dispose() {
    _busIdController.dispose();
    _busNameController.dispose();
    _stationController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bus'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Station Logic Added'),
      ),
    );
  }
}