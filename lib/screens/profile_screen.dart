import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  List<DocumentSnapshot> _userParkingSpots = [];
  bool _showParkingSpots = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _listenToUserParkingSpots();
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

  @override
  Widget build(BuildContext context) {
    if (_showParkingSpots) return _buildParkingSpotsView();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("ParkEase", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 12),
            Text(userName ?? "Guest", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Joined in 2025", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ..._buildProfileCards(),
            const Spacer(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
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
              _buildDialogFields('Title', 1, (val) => _title = val),
              const SizedBox(height: 15),
              _buildDialogFields('Description', 3, (val) => _description = val),
              const SizedBox(height: 15),
              _buildDialogFields('Price (₹/hr)', 1, (val) => _price = val, isNumber: true),
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
                        _clearFields();
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

  String _title = '';
  String _description = '';
  String _price = '';

  Widget _buildDialogFields(String label, int maxLines, Function(String) onChanged, {bool isNumber = false}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
    );
  }

  void _clearFields() {
    _title = '';
    _description = '';
    _price = '';
    setState(() => _isAvailable = true);
  }

  Future<void> _submitParkingSpot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in to submit a parking spot.', Colors.red);
      return;
    }

    final title = _title.trim();
    final description = _description.trim();
    final priceText = _price.trim();

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
      _clearFields();
    } catch (e) {
      _showSnackBar('Failed to submit: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}