import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'reservation_screen.dart';
import 'booking_confirmed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? userName;
  List<DocumentSnapshot> _userParkingSpots = [];
  bool _showParkingSpots = false;
  bool _isAvailable = true;

  // Add these variables for duration selection
  String selectedDuration = '2hr';
  final List<String> durationOptions = ['1hr', '2hr', '4hr', '8hr', 'All Day'];

  final _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'price': TextEditingController(),
    'search': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _listenToUserParkingSpots();
  }

  void _listenToUserParkingSpots() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    FirebaseFirestore.instance
        .collection('parkings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) setState(() => _userParkingSpots = snapshot.docs);
    });
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() => userName = doc.data()?['name'] ?? 'Guest');
        }
      } catch (e) {
        if (mounted) setState(() => userName = 'Guest');
      }
    } else {
      setState(() => userName = 'Guest');
    }
  }

  final List<Map<String, String>> _parkingData = [
    {
      'name': 'Central Mall Parking',
      'address': '123 Main Street, Mumbai',
      'price': '₹50/hr',
      'distance': '0.5 km away',
      'image': 'assets/parking1.png',
    },
    {
      'name': 'City Center Plaza',
      'address': '456 Park Avenue, Delhi',
      'price': '₹60/hr',
      'distance': '1.2 km away',
      'image': 'assets/parking2.png',
    },
    {
      'name': 'Downtown Parking',
      'address': '789 Market Road, Bangalore',
      'price': '₹40/hr',
      'distance': '0.8 km away',
      'image': 'assets/parking3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove backgroundColor from Scaffold, use a gradient container instead
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00BCD4), // Cyan
              Color(0xFF2196F3), // Blue
              Color(0xFF9C27B0), // Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeView(),
              _buildBookingView(),
              _buildAccountView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _showParkingSpots = false;
        }),
        selectedItemColor: const Color(0xFF2196F3), // Match login/splash blue
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Reservations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "ParkEase",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White for contrast on gradient
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controllers['search'],
              decoration: const InputDecoration(
                hintText: 'Search for parking',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/india_map.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: _buildParkingList(), // This is correct now!
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4A9B8E), Color(0xFF6BB6AA)],
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(painter: IndiaMapPainter()),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: Column(
                children: [
                  _buildZoomButton(Icons.add),
                  const SizedBox(height: 8),
                  _buildZoomButton(Icons.remove),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Icon(icon, color: Colors.black),
    );
  }

  Widget _buildParkingList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text('Parking Options', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _parkingData.length,
            itemBuilder: (context, index) => _buildParkingCard(_parkingData[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildParkingCard(Map<String, String> spot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                spot['image']!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.local_parking, color: Colors.grey, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spot['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(spot['distance']!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text(spot['address']!, style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showDetailedBookingDialog(context, spot),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal, // Changed to teal
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White text for contrast
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingView() {
    return const ReservationScreen();
  }

  Widget _buildAccountView() {
    return const ProfileScreen();
  }

  List<Widget> _buildProfileCards() {
    final cards = [
      {'icon': Icons.add_location, 'title': 'Add Parking', 'onTap': _showAddParkingDialog},
      {'icon': Icons.local_parking, 'title': 'My Parking Spots',
       'onTap': () => setState(() => _showParkingSpots = true)},
      {'icon': Icons.settings, 'title': 'Settings', 'onTap': () {}},
      {'icon': Icons.payment, 'title': 'Payment Options', 'onTap': () {}},
      {'icon': Icons.help_center, 'title': 'Help Center', 'onTap': () {}},
    ];

    return cards.map((card) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(card['icon'] as IconData, color: Colors.teal),
          title: Text(card['title'] as String),
          trailing: card['title'] == 'My Parking Spots' 
              ? const Icon(Icons.arrow_forward_ios, size: 16) 
              : null,
          onTap: card['onTap'] as VoidCallback,
        ),
      ),
    )).toList();
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text("Logout", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildParkingSpotsView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("ParkEase", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _showParkingSpots = false),
                ),
                const SizedBox(width: 8),
                const Text("Locations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _userParkingSpots.isEmpty
                  ? const Center(child: Text("No parking spots added yet."))
                  : ListView.builder(
                      itemCount: _userParkingSpots.length,
                      itemBuilder: (context, index) {
                        final data = _userParkingSpots[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['title'] ?? '', 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(data['description'] ?? '', 
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),
                                Text("₹${data['price']}/hr", 
                                    style: const TextStyle(color: Colors.teal)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.circle, size: 10,
                                        color: (data['available'] == true) ? Colors.green : Colors.red),
                                    const SizedBox(width: 6),
                                    Text(
                                      data['available'] == true ? 'Available' : 'Unavailable',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: (data['available'] == true) ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddParkingDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add New Parking Spot", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ..._buildDialogFields(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: _isAvailable,
                    onChanged: (value) => setState(() => _isAvailable = value ?? true),
                  ),
                  const Text('Available'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearControllers();
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _submitParkingSpot();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text("Submit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDialogFields() {
    final fields = [
      {'controller': 'title', 'label': 'Title', 'maxLines': 1},
      {'controller': 'description', 'label': 'Description', 'maxLines': 3},
      {'controller': 'price', 'label': 'Price (₹/hr)', 'maxLines': 1, 'keyboardType': TextInputType.number},
    ];

    return fields.map((field) => Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: _controllers[field['controller']]!,
        decoration: InputDecoration(
          labelText: field['label'] as String,
          border: const OutlineInputBorder(),
        ),
        maxLines: field['maxLines'] as int,
        keyboardType: field['keyboardType'] as TextInputType? ?? TextInputType.text,
      ),
    )).toList();
  }

  void _clearControllers() {
    _controllers.values.forEach((controller) => controller.clear());
    setState(() => _isAvailable = true);
  }

  Future<void> _submitParkingSpot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in to submit a parking spot.', Colors.red);
      return;
    }

    final title = _controllers['title']!.text.trim();
    final description = _controllers['description']!.text.trim();
    final priceText = _controllers['price']!.text.trim();

    if (title.isEmpty || description.isEmpty || priceText.isEmpty) {
      _showSnackBar('Please fill all fields.', Colors.red);
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null) {
      _showSnackBar('Please enter a valid price.', Colors.red);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('parkings').add({
        'title': title,
        'description': description,
        'price': price,
        'available': _isAvailable,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _showSnackBar('Data successfully submitted!', Colors.teal);
      _clearControllers();
    } catch (e) {
      _showSnackBar('Failed to submit: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Helper for payment selection state in bottom sheet
  String selectedPaymentMethod = 'Credit Card';

  // Replace your existing _showDetailedBookingDialog with this enhanced version
  void _showDetailedBookingDialog(BuildContext context, Map<String, dynamic> spot) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: TimeOfDay.now().minute);
    selectedPaymentMethod = 'Credit Card'; // Reset on open

    // Reset duration selection each time dialog opens
    selectedDuration = '2hr';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.95,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Back button and title
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Parking Spot Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Spot Image
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        spot['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.local_parking, color: Colors.grey, size: 60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Basic Info Section
                  const Text(
                    'Basic Info',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    spot['name']!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spot['address']!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spot['distance']!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  // Enhanced Details Section
                  const Text(
                    'Enhanced Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Size', style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('Standard', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Surface', style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('Paved/Asphalt', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Access', style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('24/7 Access', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Security', style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('CCTV Surveillance', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Booking Section
                  const Text(
                    'Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  // Date Selection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.teal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => selectedDate = date);
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Duration Selection (replaces the time selection section)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: durationOptions.map((duration) {
                            final isSelected = selectedDuration == duration;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedDuration = duration),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.teal : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? Colors.teal : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(
                                      duration,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Duration Summary and Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Duration:', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(
                              '$selectedDuration → Total: ${_calculateTotalCost(selectedDuration, spot['price']!)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Cost', style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(
                              _calculateTotalCost(selectedDuration, spot['price']!),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amenities Section
                  const Text(
                    'Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAmenityChip('EV Charging', Icons.electric_car),
                      _buildAmenityChip('Covered/Indoor Accessibility', Icons.roofing),
                      _buildAmenityChip('Well Lit Area', Icons.lightbulb),
                      _buildAmenityChip('CCTV Security', Icons.security),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Payment Methods Section
                  const Text(
                    'Payment Methods',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _buildPaymentOption('Credit Card', Icons.credit_card, selectedPaymentMethod, setState),
                      _buildPaymentOption('UPI', Icons.payment, selectedPaymentMethod, setState),
                      _buildPaymentOption('Wallet', Icons.account_balance_wallet, selectedPaymentMethod, setState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Reviews Section
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('4.8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (index) =>
                                    Icon(Icons.star, color: Colors.amber, size: 16)),
                                ),
                                Text('Based on 127 reviews', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReviewItem('Tom Taylor', 'Amazing location, easy to find and convenient.', 5),
                        const SizedBox(height: 12),
                        _buildReviewItem('Sophie Bennett', 'Good value for money, very safe parking.', 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Availability Section
                  const Text(
                    'Availability',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 12),
                        const Text(
                          'Available for selected time',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Get Directions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Directions to ${spot['name']} not implemented yet.', Colors.blue);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text('Get Directions', style: TextStyle(color: Colors.white)),
                      icon: const Icon(Icons.directions, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Book Slot Button (Updated)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final bookingDetails = {
                          'bookingId': 'PB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          'address': spot['address'] ?? '123 Elm Street, Anytown',
                          'level': 'Underground',
                          'spotNumber': 'Vehicle Plate: ABC 123, Sedan',
                          'date': '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          'time': '$selectedDuration (${selectedStartTime.format(context)} - ${selectedEndTime.format(context)})',
                          'duration': selectedDuration,
                          'totalCost': _calculateTotalCost(selectedDuration, spot['price']!),
                          'parkingName': spot['name'] ?? 'Parking Spot',
                          'paymentMethod': selectedPaymentMethod,
                        };

                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingConfirmedScreen(
                              bookingDetails: bookingDetails,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Book Slot',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: Colors.teal.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon, String selectedMethod, StateSetter setState) {
    final isSelected = (label == selectedMethod);
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = label),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.teal : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? Colors.teal : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 16, color: isSelected ? Colors.teal : Colors.black)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.teal, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String reviewer, String comment, int rating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(reviewer, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(rating, (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // Add this helper method for total cost calculation
  String _calculateTotalCost(String duration, String pricePerHour) {
    final priceMatch = RegExp(r'₹(\d+)').firstMatch(pricePerHour);
    final hourlyRate = int.tryParse(priceMatch?.group(1) ?? '50') ?? 50;

    int totalCost;
    switch (duration) {
      case '1hr':
        totalCost = hourlyRate * 1;
        break;
      case '2hr':
        totalCost = hourlyRate * 2;
        break;
      case '4hr':
        totalCost = hourlyRate * 4;
        break;
      case '8hr':
        totalCost = hourlyRate * 8;
        break;
      case 'All Day':
        totalCost = hourlyRate * 24;
        break;
      default:
        totalCost = hourlyRate * 2;
    }
    return '₹$totalCost';
  }
}

class IndiaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final scaleX = size.width / 400;
    final scaleY = size.height / 600;

    // Simplified India outline
    final points = [
      [100, 50], [200, 30], [320, 80], [380, 150], [370, 250],
      [350, 350], [320, 450], [280, 520], [200, 550], [120, 530],
      [80, 480], [60, 400], [50, 300], [70, 200], [90, 100]
    ];

    path.moveTo(points[0][0] * scaleX, points[0][1] * scaleY);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i][0] * scaleX, points[i][1] * scaleY);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Add location markers
    final markerPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final cities = [[120, 300], [180, 150], [200, 400]]; // Mumbai, Delhi, Bangalore
    
    for (final city in cities) {
      canvas.drawCircle(Offset(city[0] * scaleX, city[1] * scaleY), 4, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}