import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add user data
  Future<void> addUser(String uid, String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  // Add parking spot
  Future<void> addParkingSpot({
    required String title,
    required String description,
    required double price,
    required bool available,
    required String userId,
  }) async {
    await _db.collection('parkings').add({
      'title': title,
      'description': description,
      'price': price,
      'available': available,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get all parking spots
  Stream<QuerySnapshot> getParkingSpots() {
    return _db.collection('parkings').orderBy('timestamp', descending: true).snapshots();
  }

  getParkings() {}
}