import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ListParkingScreen extends StatefulWidget {
  const ListParkingScreen({super.key});

  @override
  State<ListParkingScreen> createState() => _ListParkingScreenState();
}

class _ListParkingScreenState extends State<ListParkingScreen> {
  String _title = '';
  String _description = '';
  String _address = '';
  String _parkingType = '';
  String _vehicleType = '';
  String _pricePerHour = '';
  String _pricePerDay = '';
  bool _isAvailable = true;
  bool _isGettingLocation = false;

  // Text controller for address field
  final TextEditingController _addressController = TextEditingController();

  // Amenities
  bool _hasCCTV = false;
  bool _hasSecurityGuard = false;
  bool _hasWellLit = false;
  bool _hasEVCharging = false;
  bool _hasWheelchairAccess = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4), // Cyan
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'List Your Parking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white, // White text for contrast
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Earn money from your parking space",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF00BCD4), // Cyan accent
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              // Location Details Section
              _buildSectionTitle('Location Details'),
              const SizedBox(height: 16),
              _buildAddressField(), // Updated address field with location button
              const SizedBox(height: 20),

              // Parking Information Section
              _buildSectionTitle('Parking Information'),
              const SizedBox(height: 16),
              _buildInputField('Parking Type', 1, (val) => _parkingType = val),
              const SizedBox(height: 16),
              _buildInputField('Vehicle Type', 1, (val) => _vehicleType = val),
              const SizedBox(height: 16),
              _buildInputField('Title', 1, (val) => _title = val),
              const SizedBox(height: 16),
              _buildInputField('Description', 3, (val) => _description = val),
              const SizedBox(height: 20),

              // Pricing Section
              _buildSectionTitle('Pricing'),
              const SizedBox(height: 16),
              _buildInputField('Price per Hour (₹)', 1, (val) => _pricePerHour = val, isNumber: true),
              const SizedBox(height: 16),
              _buildInputField('Price per Day (₹)', 1, (val) => _pricePerDay = val, isNumber: true),
              const SizedBox(height: 20),

              // Amenities Section
              _buildSectionTitle('Amenities'),
              const SizedBox(height: 16),
              _buildAmenitiesSection(),
              const SizedBox(height: 20),

              // Availability Section
              _buildSectionTitle('Availability'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isAvailable,
                    onChanged: (value) => setState(() => _isAvailable = value ?? true),
                    activeColor: const Color(0xFF00BCD4), // Cyan
                  ),
                  const Text(
                    'Available for booking',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Submit Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitParkingSpot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4), // Cyan
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter Address',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Container(
              margin: const EdgeInsets.all(4),
              child: ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                ),
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location, size: 16),
                label: Text(
                  _isGettingLocation ? 'Getting...' : 'Current',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
          maxLines: 2,
          onChanged: (value) => _address = value,
        ),
      ],
    );
  }

  Widget _buildInputField(String label, int maxLines, Function(String) onChanged, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2), // Cyan
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAmenityCheckbox('CCTV', _hasCCTV, (val) => setState(() => _hasCCTV = val)),
            ),
            Expanded(
              child: _buildAmenityCheckbox('Security Guard', _hasSecurityGuard, (val) => setState(() => _hasSecurityGuard = val)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAmenityCheckbox('Well-lit', _hasWellLit, (val) => setState(() => _hasWellLit = val)),
            ),
            Expanded(
              child: _buildAmenityCheckbox('EV Charging', _hasEVCharging, (val) => setState(() => _hasEVCharging = val)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAmenityCheckbox('Wheelchair Accessible', _hasWheelchairAccess, (val) => setState(() => _hasWheelchairAccess = val)),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityCheckbox(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          activeColor: const Color(0xFF00BCD4), // Cyan
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled. Please enable them.', Colors.red);
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied.', Colors.red);
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied. Please enable them in settings.', Colors.red);
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street! + ', ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += place.subLocality! + ', ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality! + ', ';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += place.administrativeArea! + ', ';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += place.country!;
        }

        // Remove trailing comma and space
        address = address.replaceAll(RegExp(r', $'), '');

        setState(() {
          _address = address;
          _addressController.text = address;
        });

        _showSnackBar('Location retrieved successfully!', const Color(0xFF4CAF50));
      } else {
        _showSnackBar('Could not get address for this location.', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error getting location: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _title = '';
      _description = '';
      _address = '';
      _parkingType = '';
      _vehicleType = '';
      _pricePerHour = '';
      _pricePerDay = '';
      _isAvailable = true;
      _hasCCTV = false;
      _hasSecurityGuard = false;
      _hasWellLit = false;
      _hasEVCharging = false;
      _hasWheelchairAccess = false;
    });
    _addressController.clear();
  }

  Future<void> _submitParkingSpot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in to submit a parking spot.', Colors.red);
      return;
    }

    final title = _title.trim();
    final description = _description.trim();
    final address = _address.trim();
    final parkingType = _parkingType.trim();
    final vehicleType = _vehicleType.trim();
    final pricePerHourText = _pricePerHour.trim();
    final pricePerDayText = _pricePerDay.trim();

    if (title.isEmpty || description.isEmpty || address.isEmpty || 
        parkingType.isEmpty || vehicleType.isEmpty || 
        pricePerHourText.isEmpty) {
      _showSnackBar('Please fill all required fields.', Colors.red);
      return;
    }

    final pricePerHour = double.tryParse(pricePerHourText);
    if (pricePerHour == null) {
      _showSnackBar('Please enter a valid price per hour.', Colors.red);
      return;
    }

    final pricePerDay = pricePerDayText.isNotEmpty ? double.tryParse(pricePerDayText) : null;
    if (pricePerDayText.isNotEmpty && pricePerDay == null) {
      _showSnackBar('Please enter a valid price per day.', Colors.red);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('parkings').add({
        'title': title,
        'description': description,
        'address': address,
        'parkingType': parkingType,
        'vehicleType': vehicleType,
        'pricePerHour': pricePerHour,
        'pricePerDay': pricePerDay,
        'available': _isAvailable,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'amenities': {
          'cctv': _hasCCTV,
          'securityGuard': _hasSecurityGuard,
          'wellLit': _hasWellLit,
          'evCharging': _hasEVCharging,
          'wheelchairAccessible': _hasWheelchairAccess,
        },
      });
      
      _showSnackBar('Parking spot submitted for approval!', const Color(0xFF4A90E2));
      _clearFields();
      // Navigate back to profile screen after successful submission
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to submit: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}