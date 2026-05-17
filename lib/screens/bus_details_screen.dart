import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../services/firestore_service.dart';

class BusDetailsScreen extends StatelessWidget {
  const BusDetailsScreen({Key? key}) : super(key: key);

  void _showBusDetailsDialog(BuildContext context, BusModel bus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(bus.busName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bus ID: ${bus.busId}'),
            const SizedBox(height: 12),

            const Text(
              'Stations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            ...bus.stations.map((s) {
              double fare = bus.faresFromSource[s] ?? 0;

              return ListTile(
                title: Text(s),
                subtitle: Text('Fare: $fare Tk'),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Details'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<BusModel>>(
        stream: firestoreService.getAllBuses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No buses'));
          }

          final buses = snapshot.data!;

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];

              return Card(
                child: ListTile(
                  title: Text(bus.busName),
                  subtitle: Text('${bus.stations.length} stations'),
                  onTap: () => _showBusDetailsDialog(context, bus),
                ),
              );
            },
          );
        },
      ),
    );
  }
}