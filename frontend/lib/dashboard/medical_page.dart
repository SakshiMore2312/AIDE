import 'package:educonnect/models/hospital.dart';
import 'package:educonnect/services/api_service.dart';
import 'package:flutter/material.dart';
import 'widgets/filter_bottom_sheet.dart';

class MedicalPage extends StatefulWidget {
  const MedicalPage({super.key});

  @override
  State<MedicalPage> createState() => _MedicalPageState();
}

class _MedicalPageState extends State<MedicalPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Hospital>> _hospitalsFuture;
  String _searchQuery = "";
  bool _bloodBank = false;
  bool _ambulance = false;
  String _sortBy = "name";
  String _order = "asc";
  String _minRating = "any";
  double _radius = 50.0;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  void _fetchHospitals() {
    setState(() {
      _hospitalsFuture = _apiService.getHospitals(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        lat: 18.52, // Mock Pune Lat
        lon: 73.85, // Mock Pune Lon
        radius: _radius,
        bloodBank: _bloodBank,
        ambulance: _ambulance,
        sortBy: _sortBy,
        order: _order,
        minRating: _minRating,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Title
              const Text(
                "Medical",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              /// 🔹 Location
              Row(
                children: const [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Bangalore, Karnataka",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) {
                          _searchQuery = val;
                          _fetchHospitals();
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "Search hospitals...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => FilterBottomSheet(
                          initialRadius: _radius,
                          initialSortBy: _sortBy,
                          initialOrder: _order,
                          initialMinRating: _minRating,
                          onApply: (r, s, o, m) {
                            setState(() {
                              _radius = r;
                              _sortBy = s;
                              _order = o;
                              _minRating = m;
                            });
                            _fetchHospitals();
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// 🔹 Blood Bank & Ambulance Buttons
              Row(
                children: [
                  _medicalChip(
                    icon: Icons.bloodtype_outlined,
                    label: "Blood Bank",
                    borderColor: Colors.red,
                    isSelected: _bloodBank,
                    onTap: () {
                      _bloodBank = !_bloodBank;
                      _fetchHospitals();
                    },
                  ),
                  const SizedBox(width: 12),
                  _medicalChip(
                    icon: Icons.local_hospital_outlined,
                    label: "Ambulance",
                    borderColor: Colors.blue,
                    isSelected: _ambulance,
                    onTap: () {
                      _ambulance = !_ambulance;
                      _fetchHospitals();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),

              /// 🔹 Hospitals Found
              FutureBuilder<List<Hospital>>(
                future: _hospitalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hospitals found'));
                  }

                  final hospitals = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${hospitals.length} hospitals found",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...hospitals
                          .map((hospital) => _medicalHospitalCard(hospital))
                          .toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Reusable Button Widget
  Widget _medicalChip({
    required IconData icon,
    required String label,
    required Color borderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? borderColor.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? borderColor : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? borderColor : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? borderColor : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Hospital Card Widget
  Widget _medicalHospitalCard(Hospital hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  hospital.image ??
                      "https://images.unsplash.com/photo-1586773860418-d37222d8fce3",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.local_hospital,
                        size: 50, color: Colors.grey),
                  ),
                ),
              ),

              /// Distance Badge
              if (hospital.distance != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${hospital.distance!.toStringAsFixed(1)} km",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),

          /// 🔹 Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(hospital.rating.toString()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Available Beds: ${hospital.availableBeds}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Emergency: ${hospital.emergencyContact}",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}