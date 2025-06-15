import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? userName;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null && mounted) {
          setState(() {
            userName = doc.data()!['name'] ?? 'Guest';
          });
        } else {
          setState(() {
            userName = 'Guest';
          });
        }
      } catch (e) {
        setState(() {
          userName = 'Guest';
        });
      }
    } else {
      setState(() {
        userName = 'Guest';
      });
    }
  }

  final List<Map<String, String>> parkingData = [
    {
      'name': '123 Elm Street',
      'address': 'Downtown, Anytown',
      'price': '\$5/hr',
      'image': 'assets/parking1.png',
    },
    {
      'name': '456 Oak Avenue',
      'address': 'Midtown, Anytown',
      'price': '\$6/hr',
      'image': 'assets/parking2.png',
    },
    {
      'name': '789 Maple Lane',
      'address': 'Uptown, Anytown',
      'price': '\$4/hr',
      'image': 'assets/parking3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ParkEase"),
        backgroundColor: Colors.teal,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeView(),
          _buildSearchView(),
          _buildBookingView(),
          _buildAccountView(),
          _buildAddView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: parkingData.length,
      itemBuilder: (context, index) {
        final spot = parkingData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  spot['image']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spot['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(spot['address']!, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(spot['price']!, style: const TextStyle(color: Colors.teal)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showBookingDialog(context, spot),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parkings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No parking spots available."));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(data['description'] ?? '', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text("\$${data['price'].toString()}/hr", style: const TextStyle(color: Colors.teal)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: (data['available'] == true) ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data['available'] == true ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            color: (data['available'] == true) ? Colors.green : Colors.red,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingView() {
    final List<Map<String, String>> activeBookings = [
      {
        'name': '123 Elm Street',
        'address': '123 Elm Street, Anytown',
        'price': '\$5/hr',
        'time': 'Today, 10:00 AM - 12:00 PM',
        'status': 'Active',
        'image': 'assets/parking1.png'
      },
      {
        'name': '456 Oak Avenue',
        'address': '456 Oak Avenue, Anytown',
        'price': '\$6/hr',
        'time': 'Tomorrow, 2:00 PM - 4:00 PM',
        'status': 'Active',
        'image': 'assets/parking2.png'
      },
    ];

    final List<Map<String, String>> pastBookings = [
      {
        'name': '789 Maple Lane',
        'address': '789 Maple Lane, Anytown',
        'price': '\$4/hr',
        'time': 'Yesterday, 8:00 AM - 10:00 AM',
        'status': 'Completed',
        'image': 'assets/parking3.png'
      },
    ];

    TabController tabController = TabController(length: 2, vsync: this);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("My Bookings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        TabBar(
          controller: tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildBookingList(activeBookings),
              _buildBookingList(pastBookings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList(List<Map<String, String>> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final spot = bookings[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(spot['image']!, width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(spot['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(spot['address']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          trailing: Text(
            spot['status']!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: spot['status'] == 'Active' ? Colors.teal : Colors.grey,
            ),
          ),
          isThreeLine: true,
        );
      },
    );
  }

  Widget _buildAccountView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            userName != null && userName!.isNotEmpty ? userName! : "Guest",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Joined in 2025", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ListTile(leading: Icon(Icons.payment), title: Text("Payment Methods")),
          ListTile(leading: Icon(Icons.support), title: Text("Support")),
          ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
          const Spacer(),
          SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Parking Spot", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Checkbox(
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value ?? true;
                  });
                },
              ),
              const Text('Available'),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitParkingSpot,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitParkingSpot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a parking spot.'), backgroundColor: Colors.red),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final priceText = _priceController.text.trim();

    if (title.isEmpty || description.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.red),
      );
      return;
    }

    double? price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price.'), backgroundColor: Colors.red),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data successfully submitted!'), backgroundColor: Colors.teal),
      );

      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() => _isAvailable = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showBookingDialog(BuildContext context, Map<String, String> spot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Book ${spot['name']}"),
        content: Text("Confirm booking for ${spot['price']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Confirm")),
        ],
      ),
    );
  }
}