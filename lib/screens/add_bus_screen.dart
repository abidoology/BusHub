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

  bool _isLoading = false;

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
          ],
        ),
      ),
    );
  }
}