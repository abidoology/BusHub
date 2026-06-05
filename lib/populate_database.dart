// Run this file to populate the database with sample data
// Usage: flutter run lib/populate_database.dart -d chrome

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBHzJzFF9FrCy5ywJqE37rKUfrbSKj1xrw",
        authDomain: "dhaka-route-and-fare.firebaseapp.com",
        projectId: "dhaka-route-and-fare",
        storageBucket: "dhaka-route-and-fare.firebasestorage.app",
        messagingSenderId: "1008390294160",
        appId: "1:1008390294160:android:351df6f48c6b529026a615",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const PopulateApp());
}

class PopulateApp extends StatelessWidget {
  const PopulateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Populate Database',
      home: PopulateScreen(),
    );
  }
}

class PopulateScreen extends StatefulWidget {
  const PopulateScreen({Key? key}) : super(key: key);

  @override
  State<PopulateScreen> createState() => _PopulateScreenState();
}

class _PopulateScreenState extends State<PopulateScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _status = 'Ready to populate database';
  bool _isLoading = false;
  bool _isComplete = false;

  Future<void> _populateDatabase() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting...';
    });

    try {
      // Add locations
      setState(() => _status = 'Adding locations...');
      
      List<String> locations = [
        'Mohakhali',
        'Gulshan',
        'Banani',
        'Mirpur',
        'Dhanmondi',
        'Motijheel',
        'Uttara',
        'Farmgate',
        'Sadarghat',
        'Gabtoli',
        'Shahbagh',
        'Jatrabari',
        'Sayedabad',
        'Mohammadpur',
        'Azimpur',
      ];

      for (String location in locations) {
        await _firestore.collection('locations').add({
          'locationName': location,
          'locationId': DateTime.now().millisecondsSinceEpoch.toString(),
        });
      }

      setState(() => _status = 'Locations added! Adding buses...');

      // Add buses
      List<Map<String, dynamic>> buses = [
        {
          'busName': 'Dhaka Express',
          'busId': 'DE-001',
          'stations': ['Mohakhali', 'Gulshan', 'Banani', 'Uttara'],
          'faresFromSource': {
            'Mohakhali': 0.0,
            'Gulshan': 20.0,
            'Banani': 30.0,
            'Uttara': 50.0,
          },
        },
        {
          'busName': 'City Service',
          'busId': 'CS-002',
          'stations': ['Mirpur', 'Farmgate', 'Shahbagh', 'Motijheel'],
          'faresFromSource': {
            'Mirpur': 0.0,
            'Farmgate': 25.0,
            'Shahbagh': 35.0,
            'Motijheel': 50.0,
          },
        },
        {
          'busName': 'Green Line',
          'busId': 'GL-003',
          'stations': ['Gabtoli', 'Mirpur', 'Farmgate', 'Gulshan', 'Uttara'],
          'faresFromSource': {
            'Gabtoli': 0.0,
            'Mirpur': 20.0,
            'Farmgate': 35.0,
            'Gulshan': 45.0,
            'Uttara': 60.0,
          },
        },
        {
          'busName': 'Shohagh Paribahan',
          'busId': 'SP-004',
          'stations': ['Dhanmondi', 'Azimpur', 'Shahbagh', 'Gulshan'],
          'faresFromSource': {
            'Dhanmondi': 0.0,
            'Azimpur': 15.0,
            'Shahbagh': 25.0,
            'Gulshan': 40.0,
          },
        },
        {
          'busName': 'Turag Express',
          'busId': 'TE-005',
          'stations': ['Sadarghat', 'Motijheel', 'Shahbagh', 'Farmgate', 'Mohakhali'],
          'faresFromSource': {
            'Sadarghat': 0.0,
            'Motijheel': 20.0,
            'Shahbagh': 30.0,
            'Farmgate': 40.0,
            'Mohakhali': 50.0,
          },
        },
      ];

      for (var bus in buses) {
        await _firestore.collection('buses').add(bus);
      }

      setState(() {
        _status = '✓ Database populated successfully!\n\n15 Locations added\n5 Buses added\n\nYou can now close this window and use the app.';
        _isLoading = false;
        _isComplete = true;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Populate Database'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isComplete ? Icons.check_circle : Icons.cloud_upload,
                size: 80,
                color: _isComplete ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              if (!_isLoading && !_isComplete)
                ElevatedButton(
                  onPressed: _populateDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Populate Database',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
