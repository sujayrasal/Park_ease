import 'package:flutter/material.dart';
import '../models/parking.dart';
import '../services/firestore_service.dart';

class ParkingListView extends StatefulWidget {
  const ParkingListView({super.key});

  @override
  State<ParkingListView> createState() => _ParkingListViewState();
}

class _ParkingListViewState extends State<ParkingListView> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Parking Spots'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title or description',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Parking>>(
              stream: FirestoreService().getParkings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading parking spots"));
                }
                final parkings = snapshot.data
                        ?.where((p) =>
                            p.title.toLowerCase().contains(searchQuery) ||
                            p.description.toLowerCase().contains(searchQuery))
                        .toList() ??
                    [];

                if (parkings.isEmpty) {
                  return const Center(child: Text("No matching parking spots."));
                }

                return ListView.builder(
                  itemCount: parkings.length,
                  itemBuilder: (context, index) {
                    final parking = parkings[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          Icons.local_parking,
                          color: parking.available ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        title: Text(parking.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(parking.description),
                            Text('Price: \$${parking.price}/hr'),
                            Text(parking.available ? "Available" : "Not Available"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}