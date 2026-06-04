// User Search Screen - Main user interface for searching buses
// Uses dropdown menus for source and destination selection

import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/location_model.dart';
import '../services/firestore_service.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _firestoreService = FirestoreService();

  // Selected values
  String? _selectedSource;
  String? _selectedDestination;

  // Search state
  bool _hasSearched = false;

  // Search for buses
  void _searchBuses() {
    if (_selectedSource == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both source and destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSource == _selectedDestination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and destination cannot be the same'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _hasSearched = true;
    });
  }

  // Reset search
  void _resetSearch() {
    setState(() {
      _selectedSource = null;
      _selectedDestination = null;
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Buses'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Source dropdown
                StreamBuilder<List<LocationModel>>(
                  stream: _firestoreService.getLocations(),
                  builder: (context, snapshot) {
                    // Show loading indicator while connecting
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingDropdown('Loading locations...');
                    }

                    // Show error if any
                    if (snapshot.hasError) {
                      return _buildLoadingDropdown('Error loading locations');
                    }

                    // Show message if no data
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyDropdown(
                        'No locations available',
                        'Please contact admin to add locations',
                      );
                    }

                    List<String> locations =
                        snapshot.data!.map((loc) => loc.locationName).toList();
                    
                    // Remove duplicates while preserving order
                    locations = locations.toSet().toList();

                    return _buildDropdown(
                      label: 'From (Source)',
                      icon: Icons.location_on,
                      value: _selectedSource,
                      items: locations,
                      onChanged: (value) {
                        setState(() {
                          _selectedSource = value;
                          _hasSearched = false;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Destination dropdown
                StreamBuilder<List<LocationModel>>(
                  stream: _firestoreService.getLocations(),
                  builder: (context, snapshot) {
                    // Show loading indicator while connecting
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingDropdown('Loading locations...');
                    }

                    // Show error if any
                    if (snapshot.hasError) {
                      return _buildLoadingDropdown('Error loading locations');
                    }

                    // Show message if no data
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyDropdown(
                        'No locations available',
                        'Please contact admin to add locations',
                      );
                    }

                    List<String> locations =
                        snapshot.data!.map((loc) => loc.locationName).toList();
                    
                    // Remove duplicates while preserving order
                    locations = locations.toSet().toList();

                    return _buildDropdown(
                      label: 'To (Destination)',
                      icon: Icons.location_on,
                      value: _selectedDestination,
                      items: locations,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value;
                          _hasSearched = false;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Search button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _searchBuses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            SizedBox(width: 8),
                            Text(
                              'Search Buses',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _resetSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  // Build dropdown widget
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(label),
                value: value,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build loading dropdown placeholder
  Widget _buildLoadingDropdown(String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Build empty dropdown placeholder with message
  Widget _buildEmptyDropdown(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Build search results section
  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Select locations and search for buses',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<BusModel>>(
      stream: _firestoreService.searchBuses(
        _selectedSource!,
        _selectedDestination!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No buses found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different locations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        List<BusModel> buses = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: buses.length,
          itemBuilder: (context, index) {
            BusModel bus = buses[index];

            // Get stations between source and destination with fares
            Map<String, double> stationsWithFares =
                _firestoreService.getStationsWithFares(
              bus,
              _selectedSource!,
              _selectedDestination!,
            );

            // Calculate total fare
            double totalFare = _firestoreService.calculateFare(
              bus,
              _selectedSource!,
              _selectedDestination!,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  bus.busName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Bus ID: ${bus.busId}'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total Fare: ${totalFare.toStringAsFixed(0)} Tk',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Route & Fares:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List all stations with fares
                        ...stationsWithFares.entries.map((entry) {
                          String station = entry.key;
                          double fare = entry.value;

                          // Check if this is source or destination
                          bool isSource = station == _selectedSource;
                          bool isDestination = station == _selectedDestination;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  isSource || isDestination
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSource || isDestination
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        station,
                                        style: TextStyle(
                                          fontWeight: isSource || isDestination
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (!isSource)
                                        Text(
                                          '${fare.toStringAsFixed(0)} Tk from $_selectedSource',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
