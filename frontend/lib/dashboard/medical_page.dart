import 'package:educonnect/models/hospital.dart';
import 'package:educonnect/services/api_service.dart';
import 'package:flutter/material.dart';

class MedicalPage extends StatefulWidget {
  const MedicalPage({super.key});

  @override
  State<MedicalPage> createState() => _MedicalPageState();
}

class _MedicalPageState extends State<MedicalPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Hospital>> _hospitalsFuture;

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _apiService.getHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search hospitals...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 Blood Bank & Ambulance Buttons
              Row(
                children: [
                  _medicalChip(
                    icon: Icons.bloodtype_outlined,
                    label: "Blood Bank",
                    borderColor: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _medicalChip(
                    icon: Icons.local_hospital_outlined,
                    label: "Ambulance",
                    borderColor: Colors.blue,
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
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  /// 🔹 Hospital Card Widget
  Widget _medicalHospitalCard(Hospital hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      color: Colors.white,
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