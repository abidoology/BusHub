// Initial Data Service - Populates database with sample locations and buses
// Run this once to set up initial data

import 'package:cloud_firestore/cloud_firestore.dart';

class InitialDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add initial locations
  Future<void> addInitialLocations() async {
    List<String> locations = [
      'Postogola',
      'Dholairpar',
      'Jatrabari',
      'Janapoth Moor',
      'Sayapabad',
      'Mugdapara', 
      'Bashabo',
      'Khilgaon',
      'Malibagh Railgate',
      'Rampura Bazar',
      'Rampura Bridge',
      'Merul Badda',
      'Badda',
      'Uttar Badda',
      'Bashtola',
      'Notun Bazar',
      'Nadda',
      'Bashundhara',
      'Jamuna Future Park',
      'Kuril Chourasta',
      'Kuril Bishwa Road',
      'Khilkhet',
      'Airport',
      'Jashimuddin',
      'Rajlakshmi',
      'Azampur',
      'House Building',
      'Dia Bari',
      'Japan Garden City',
      'Ring Road',
      'Adabor',
      'Shyamoli',
      'Agargaon',
      'Zia Uddyan',
      'Bijoy Sarani',
      'Old Airport',
      'Jahangir Gate',
      'Chairman Bari',
      'Sainik Club',
      'Kakali',
      'Banani',
      'Staff Road',
      'MES',
      'Shewra',
      'Abdullahpur',
      'Bosila',
      'Mohammadpur',
      'Asad Gate',
      'College Gate',
      'Shyamoli',
      'Kallyanpur',
      'Darussalam',
      'Technical',
      'Bangla College',
      'Tolarbag',
      'Ansar Camp',
      'Mirpur 1',
      'Mirpur 2',
      'Mirpur 10',
      'Mirpur 11',
      'Purobi',
      'Kalshi',
      'ECB Square',
      'Sign Board',
      'Matuail',
      'Rayerbag',
      'Shonir Akhra',
      'Jatrabari',
      'Sayapabad',
      'Gulistan',
      'Chankhar Pul',
      'Bakshi Bazar',
      'Azimpur',
      'Nilkhet',
      'New Market',
      'City College',
      'Kalabagan',
      'Asad Gate',
      'Dhanmondi 27',
      'Dhanmondi 32',
      'Khamar Bari',
      'Farmgate',
      'Jahangir Gate',
      'Mohakhali',
      'Chairman Bari',
      'Sainik Club',
      'Kamarpara',
      'Dhour',
      'Tongi',
      'Station Road',
      'Mill Gate',
      'Board Bazar',
      'Gazipur Chourasta',

    ];

    try {
      for (String location in locations) {
        await _firestore.collection('locations').add({
          'locationName': location,
          'locationId': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        print('Added location: $location');
      }
      print('✓ All locations added successfully!');
    } catch (e) {
      print('Error adding locations: $e');
      rethrow;
    }
  }

  // Add sample buses
  Future<void> addSampleBuses() async {
    List<Map<String, dynamic>> buses = [
      {
        'busName': 'VIP',
        'busId': 'DE-001',
        'stations': ['Azimpur', 'Nilkhet', 'New Market', 'City College', 'Kalabagan', 'Dhanmondi 27', 'Dhanmondi 32', 'Asad Gate', 'Airport', 'Jashimuddin', 'Rajlakshmi', 'Azampur', 'House Building', 'Abdullahpur', 'Tongi', 'Station Road', 'Mill Gate', 'Board Bazar', 'Gazipur Chourasta'],
        'faresFromSource': {
          'Azimpur': 0.0,
          'Nilkhet': 15.0,
          'New Market': 15.0,
          'City College': 20.0,
          'Kalabagan': 20.0,
          'Dhanmondi 27': 20.0,
          'Dhanmondi 32': 20.0,
          'Asad Gate': 30.0,
          'Airport': 80.0,
          'Jashimuddin': 80.0,
          'Rajlakshmi': 80.0,
          'Azampur': 80.0,
          'House Building': 90.0,
          'Abdullahpur': 100.0,
          'Tongi': 110.0,
          'Station Road': 110.0,
          'Mill Gate': 110.0,
          'Board Bazar': 115.0,
          'Gazipur Chourasta': 120.0,
        },
      },
      {
        'busName': 'Raida',
        'busId': 'CS-002',
        'stations': ['Postogola', 'Dholairpar', 'Jatrabari', 'Janapoth Moor', 'Sayapabad', 'Mugdapara', 'Bashabo', 'Khilgaon', 'Malibagh Railgate', 'Rampura Bazar', 'Rampura Bridge', 'Merul Badda', 'Badda', 'Uttar Badda', 'Bashtola', 'Notun Bazar', 'Nadda', 'Bashundhara', 'Jamuna Future Park', 'Kuril Chourasta', 'Kuril Bishwa Road', 'Khilkhet', 'Airport', 'Jashimuddin', 'Rajlakshmi', 'Azampur', 'House Building', 'Dia Bari'],
        'faresFromSource': {
          'Postogola': 0.0,
          'Dholairpar': 10.0,
          'Jatrabari': 10.0,
          'Janapoth Moor': 15.0,
          'Sayapabad': 15.0,
          'Mugdapara': 20.0,
          'Bashabo': 20.0,
          'Khilgaon': 30.0,
          'Malibagh Railgate': 35.0,
          'Rampura Bazar': 40.0,
          'Rampura Bridge': 40.0,
          'Merul Badda': 45.0,
          'Badda': 45.0,
          'Uttar Badda': 45.0,
          'Bashtola': 45.0,
          'Notun Bazar': 50.0,
          'Nadda': 55.0,
          'Bashundhara': 55.0,
          'Jamuna Future Park': 55.0,
          'Kuril Chourasta': 55.0,
          'Kuril Bishwa Road': 55.0,
          'Khilkhet': 60.0,
          'Airport': 60.0,
          'Jashimuddin': 60.0,
          'Rajlakshmi': 60.0,
          'Azampur': 60.0,
          'House Building': 70.0,
          'Dia Bari': 80.0, 
        },
      },
      {
        'busName': 'Bhuiya Paribahan',
        'busId': 'GL-003',
        'stations': ['Japan Garden City', 'Ring Road', 'Adabor', 'Shyamoli', 'Shishu Mela', 'Agargaon', 'Zia Uddyan', 'Bijoy Sarani', 'Old Airport', 'Jahangir Gate', 'Mohakhali', 'Chairman Bari', 'Sainik Club', 'Kakali', 'Banani', 'Staff Road', 'MES', 'Shewra', 'Kuril Bishwa Road', 'Khilkhet', 'Airport', 'Jashimuddin', 'Rajlakshmi', 'Azampur', 'House Building', 'Abdullahpur'],
        'faresFromSource': {
          'Japan Garden City': 0.0,
          'Ring Road': 10.0,
          'Adabor': 10.0,
          'Shyamoli': 10.0,
          'Shishu Mela': 10.0,
          'Agargaon': 15.0,
          'Zia Uddyan': 15.0,
          'Bijoy Sarani': 20.0,
          'Old Airport': 20.0,
          'Jahangir Gate': 25.0,
          'Mohakhali': 30.0,
          'Chairman Bari': 30.0,
          'Sainik Club': 30.0,
          'Kakali': 35.0,
          'Banani': 35.0,
          'Staff Road': 35.0,
          'MES': 35.0,
          'Shewra': 35.0,
          'Kuril Bishwa Road': 40.0,
          'Khilkhet': 40.0,
          'Airport': 40.0,
          'Jashimuddin': 45.0,
          'Rajlakshmi': 45.0,
          'Azampur': 45.0,
          'House Building': 45.0,
          'Abdullahpur': 50.0,
        },
      },
      {
        'busName': 'Paristhan',
        'busId': 'SP-004',
        'stations': ['Bosila', 'Mohammadpur', 'Asad Gate', 'College Gate', 'Shyamoli', 'Kallyanpur', 'Darussalam', 'Technical', 'Bangla College', 'Tolarbag', 'Ansar Camp', 'Mirpur 1', 'Mirpur 2', 'Mirpur 10', 'Mirpur 11', 'Purobi', 'Kalshi', 'ECB Square', 'MES', 'Shewra', 'Kuril Bishwa Road', 'Khilkhet', 'Airport', 'Jashimuddin', 'Rajlakshmi', 'House Building', 'Abdullahpur'],
        'faresFromSource': {
          'Bosila': 0.0,
          'Mohammadpur': 10.0,
          'Asad Gate': 15.0,
          'College Gate': 15.0,
          'Shyamoli': 20.0,
          'Kallyanpur': 20.0,
          'Darussalam': 20.0,
          'Technical': 20.0,
          'Bangla College': 25.0,
          'Tolarbag': 25.0,
          'Ansar Camp': 25.0,
          'Mirpur 1': 30.0,
          'Mirpur 2': 30.0,
          'Mirpur 10': 30.0,
          'Mirpur 11': 30.0,
          'Purobi': 30.0,
          'Kalshi': 40.0,
          'ECB Square': 40.0,
          'MES': 50.0,
          'Shewra': 50.0,
          'Kuril Bishwa Road': 50.0,
          'Khilkhet': 50.0,
          'Airport': 60.0,
          'Jashimuddin': 60.0,
          'Rajlakshmi': 60.0,
          'House Building': 70.0,
          'Abdullahpur': 70.0,
        },
      },
      {
        'busName': 'Turag Express',
        'busId': 'TE-005',
        'stations': [
          'Sadarghat',
          'Motijheel',
          'Shahbagh',
          'Farmgate',
          'Mohakhali'
        ],
        'faresFromSource': {
          'Sadarghat': 0.0,
          'Motijheel': 20.0,
          'Shahbagh': 30.0,
          'Farmgate': 40.0,
          'Mohakhali': 50.0,
        },
      },
      {
        'busName': 'Uttara Line',
        'busId': 'UL-006',
        'stations': ['Uttara', 'Mirpur', 'Mohammadpur', 'Dhanmondi'],
        'faresFromSource': {
          'Uttara': 0.0,
          'Mirpur': 25.0,
          'Mohammadpur': 40.0,
          'Dhanmondi': 50.0,
        },
      },
      {
        'busName': 'Sayedabad Express',
        'busId': 'SE-007',
        'stations': ['Sayedabad', 'Jatrabari', 'Gulshan', 'Banani'],
        'faresFromSource': {
          'Sayedabad': 0.0,
          'Jatrabari': 20.0,
          'Gulshan': 40.0,
          'Banani': 50.0,
        },
      },
      {
        'busName': 'Bikash Paribahan',
        'busId': 'SE-007',
        'stations': ['Sign Board', 'Matuail', 'Rayerbag', 'Shonir Akhra', 'Jatrabari', 'Sayapabad', 'Gulistan', 'Chankhar Pul', 'Bakshi Bazar', 'Azimpur', 'Nilkhet', 'New Market', 'City College', 'Kalabagan', 'Dhanmondi 27', 'Dhanmondi 32', 'Khamar Bari', 'Farmgate', 'Airport', 'Jashimuddin', 'Rajlakshmi', 'Azampur', 'House Building', 'Abdullahpur', 'Kamarpara', 'Dhour'],
        'faresFromSource': {
          'Sign Board': 0.0,
          'Matuail': 10.0,
          'Rayerbag': 10.0,
          'Shonir Akhra': 20.0,
          'Jatrabari': 20.0,
          'Sayapabad': 20.0,
          'Gulistan': 20.0,
          'Chankhar Pul': 25.0,
          'Bakshi Bazar': 25.0,
          'Azimpur': 30.0,
          'Nilkhet': 30.0,
          'New Market': 30.0,
          'City College': 30.0,
          'Kalabagan': 35.0,
          'Dhanmondi 27': 35.0,
          'Dhanmondi 32': 35.0,
          'Khamar Bari': 40.0,
          'Farmgate': 40.0,
          'Airport': 80.0,
          'Jashimuddin': 85.0,
          'Rajlakshmi': 85.0,
          'Azampur': 85.0,
          'House Building': 90.0,
          'Abdullahpur': 100.0,
          'Kamarpara': 110.0,
          'Dhour': 115.0,
        },
      },
    ];

    try {
      for (var bus in buses) {
        await _firestore.collection('buses').add(bus);
        print('Added bus: ${bus['busName']}');
      }
      print('✓ All sample buses added successfully!');
    } catch (e) {
      print('Error adding buses: $e');
      rethrow;
    }
  }

  // Initialize all data
  Future<void> initializeDatabase() async {
    print('Starting database initialization...');
    
    // Check if data already exists
    bool dataExists = await hasData();
    if (dataExists) {
      print('✓ Database already has data. Skipping initialization.');
      return;
    }
    
    await addInitialLocations();
    print('---');
    await addSampleBuses();
    print('---');
    print('✓ Database initialization complete!');
  }

  // Check if database has data
  Future<bool> hasData() async {
    try {
      final locationsSnapshot =
          await _firestore.collection('locations').limit(1).get();
      final busesSnapshot = await _firestore.collection('buses').limit(1).get();

      return locationsSnapshot.docs.isNotEmpty || busesSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking data: $e');
      return false;
    }
  }
}
