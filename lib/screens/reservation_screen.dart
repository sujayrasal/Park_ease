import 'package:flutter/material.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeBookings = [
      {'name': '123 Elm Street', 'address': '123 Elm Street, Anytown', 'price': '₹50/hr',
       'time': 'Today, 10:00 AM - 12:00 PM', 'status': 'Active', 'image': 'assets/parking1.png'},
      {'name': '456 Oak Avenue', 'address': '456 Oak Avenue, Anytown', 'price': '₹60/hr',
       'time': 'Tomorrow, 2:00 PM - 4:00 PM', 'status': 'Active', 'image': 'assets/parking2.png'},
    ];
    
    final pastBookings = [
      {'name': '789 Maple Lane', 'address': '789 Maple Lane, Anytown', 'price': '₹40/hr',
       'time': 'Yesterday, 8:00 AM - 10:00 AM', 'status': 'Completed', 'image': 'assets/parking3.png'},
    ];

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text("ParkEase", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const TabBar(
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingList(activeBookings),
                  _buildBookingList(pastBookings),
                ],
              ),
            ),
          ],
        ),
      ),
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
          subtitle: Text(spot['address']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          trailing: Text(
            spot['status']!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: spot['status'] == 'Active' ? Colors.teal : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}