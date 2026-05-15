// Admin Dashboard Screen - Main admin control panel

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_bus_screen.dart';
import 'bus_details_screen.dart';
import '../services/initial_data_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  // Initialize database with sample data
  Future<void> _initializeData(BuildContext context) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Sample Data'),
        content: const Text(
          'This will add sample locations and buses to your database.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Load Data'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading sample data...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      final initialDataService = InitialDataService();
      await initialDataService.initializeDatabase();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Sample data loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    // If confirmed, logout
    if (confirm == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome message
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.dashboard,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Manage buses and routes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Add Bus button
                  _buildDashboardButton(
                    context,
                    icon: Icons.add_circle,
                    title: 'Add Bus',
                    description: 'Add a new bus with stations and fares',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddBusScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Bus Details button
                  _buildDashboardButton(
                    context,
                    icon: Icons.directions_bus,
                    title: 'Bus Details',
                    description: 'View, edit, and delete existing buses',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BusDetailsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Initialize Data button
                  _buildDashboardButton(
                    context,
                    icon: Icons.cloud_upload,
                    title: 'Load Sample Data',
                    description: 'Add sample locations and buses to database',
                    color: Colors.green,
                    onTap: () => _initializeData(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build dashboard buttons
  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),

            const SizedBox(width: 20),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
