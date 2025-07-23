import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'list_parking_screen.dart';
import 'my_vehicles_screen.dart';

// Theme Provider Class
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

class ProfileScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const ProfileScreen({super.key, required this.themeProvider});

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
        userEmail = user.email;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              userName = data['name'] ?? user.email ?? 'User';
              userPhone = data['phone'];
            } else {
              userName = user.email ?? 'User';
            }
          });
        }
      } catch (e) {
        if (mounted) setState(() => userName = user.email ?? 'User');
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
    final isDarkMode = widget.themeProvider.isDarkMode;
    
    if (_showParkingSpots) return _buildParkingSpotsView();
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'ParkEase',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          // Theme Toggle Button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.themeProvider.toggleTheme,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                  color: isDarkMode ? Colors.yellow : Colors.grey[700],
                  size: 24,
                ),
              ),
            ),
          ),
        ],
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
                border: Border.all(
                  color: isDarkMode ? Colors.tealAccent : Colors.teal, 
                  width: 2
                ),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: isDarkMode ? Colors.tealAccent : Colors.teal,
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // Display email if available
            if (userEmail != null)
              Text(
                userEmail!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
            // Display phone if available
            if (userPhone != null && userPhone!.isNotEmpty)
              Text(
                userPhone!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
            if (userEmail == null && (userPhone == null || userPhone!.isEmpty))
              Text(
                "Joined in 2021",
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _navigateToEditProfile,
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  color: isDarkMode ? Colors.tealAccent : Colors.teal,
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
                    onTap: _navigateToListParking,
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.local_parking_outlined,
                    title: 'My Parking Spots',
                    onTap: () => setState(() => _showParkingSpots = true),
                    isDarkMode: isDarkMode,
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
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet & Credits',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    title: 'Support',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline,
                    title: 'Rate the App',
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & FAQ',
                    onTap: () {},
                    isDarkMode: isDarkMode,
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
                        backgroundColor: isDarkMode ? Colors.tealAccent : Colors.teal,
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isDarkMode ? Colors.tealAccent : Colors.teal
                          ),
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
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildParkingSpotsView() {
    final isDarkMode = widget.themeProvider.isDarkMode;
    
    return SafeArea(
      child: Container(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "ParkEase", 
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: isDarkMode ? Colors.white : Colors.black
                )
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back, 
                      color: isDarkMode ? Colors.white : Colors.black
                    ),
                    onPressed: () => setState(() => _showParkingSpots = false),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Locations", 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: isDarkMode ? Colors.white : Colors.black
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _userParkingSpots.isEmpty
                    ? Center(
                        child: Text(
                          "No parking spots added yet.",
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.black
                          )
                        )
                      )
                    : ListView.builder(
                        itemCount: _userParkingSpots.length,
                        itemBuilder: (context, index) {
                          final data = _userParkingSpots[index].data() as Map<String, dynamic>;
                          return Card(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black
                                    )
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['description'] ?? '',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey
                                    )
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹${data['pricePerHour']}/hr",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black
                                    )
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle, 
                                        size: 10,
                                        color: (data['available'] == true) ? Colors.green : Colors.red
                                      ),
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
      ),
    );
  }
}