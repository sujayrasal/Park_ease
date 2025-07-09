import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'list_parking_screen.dart';
import 'my_vehicles_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;
  String? userPhone;
  List<DocumentSnapshot> _userParkingSpots = [];
  bool _showParkingSpots = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToUserParkingSpots();
  }

  // Updated method to load more user data
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Set email from Firebase Auth
        userEmail = user.email;
        // Load additional data from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              userName = data['name'] ?? 'Guest';
              userPhone = data['phone'];
            } else {
              userName = 'Guest';
            }
          });
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

  // Updated navigation to EditProfileScreen
  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    // Refresh user data when returning from edit profile
    if (result != null || mounted) {
      _loadUserData();
    }
  }

  // Navigation to ListParkingScreen
  Future<void> _navigateToListParking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ListParkingScreen(),
      ),
    );
    // Refresh parking spots when returning from list parking
    _listenToUserParkingSpots();
  }

  @override
  Widget build(BuildContext context) {
    if (_showParkingSpots) return _buildParkingSpotsView();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'ParkEase',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black for consistency
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar and Info
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal, width: 2), // Teal border
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.teal, // Teal avatar background
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName ?? "Guest",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // Display email if available
            if (userEmail != null)
              Text(
                userEmail!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            // Display phone if available
            if (userPhone != null && userPhone!.isNotEmpty)
              Text(
                userPhone!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            if (userEmail == null && (userPhone == null || userPhone!.isEmpty))
              const Text(
                "Joined in 2021",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _navigateToEditProfile, // Updated this line
              child: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.teal, // Changed to teal
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.add_location_alt_outlined,
                    title: 'List Your Parking',
                    onTap: _navigateToListParking, // Updated this line
                  ),
                  _buildMenuItem(
                    icon: Icons.local_parking_outlined,
                    title: 'My Parking Spots',
                    onTap: () => setState(() => _showParkingSpots = true),
                  ),
                  _buildMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: 'My Vehicles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyVehiclesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet & Credits',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    title: 'Support',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline,
                    title: 'Rate the App',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & FAQ',
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                  // Logout Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Changed to teal
                        foregroundColor: Colors.white, // White text
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.teal), // Teal border
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Icon(
          icon,
          color: Colors.black, // Black icon
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildParkingSpotsView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("ParkEase", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black), // Black arrow
                  onPressed: () => setState(() => _showParkingSpots = false),
                ),
                const SizedBox(width: 8),
                const Text("Locations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
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
                                Text("₹${data['pricePerHour']}/hr",
                                    style: const TextStyle(color: Colors.black)), // Black price
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
}