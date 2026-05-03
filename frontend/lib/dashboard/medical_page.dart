import 'package:aide/models/hospital.dart';
import 'package:aide/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'subpage/medical_details.dart' as sub;

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
  String _sortBy = "distance";
  String _order = "asc";
  String _minRating = "any";
  double _radius = 10.0;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  void _fetchHospitals() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lon = prefs.getDouble('lon');

    setState(() {
      _hospitalsFuture = _apiService.getHospitals(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        lat: lat, 
        lon: lon, 
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _fetchHospitals();
                  },
                  decoration: InputDecoration(
                    hintText: "Search in Medical...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
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
          const SizedBox(height: 12),

          /// 🔹 SORTING INDICATOR
          Row(
            children: [
              const Icon(Icons.sort, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "Sorted by $_sortBy ($_order)",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// 🔹 Categories (Blood Bank & Ambulance)
          const Text("Medical Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _medicalChip(
                  icon: Icons.bloodtype_outlined,
                  label: "Blood Bank",
                  borderColor: Colors.red,
                  isSelected: _bloodBank,
                  onTap: () {
                    setState(() {
                      _bloodBank = !_bloodBank;
                    });
                    _fetchHospitals();
                  },
                ),
                _medicalChip(
                  icon: Icons.local_hospital_outlined,
                  label: "Ambulance",
                  borderColor: Colors.blue,
                  isSelected: _ambulance,
                  onTap: () {
                    setState(() {
                      _ambulance = !_ambulance;
                    });
                    _fetchHospitals();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// 🔹 Hospitals Found
          Expanded(
            child: FutureBuilder<List<Hospital>>(
              future: _hospitalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hospitals available'));
                }

                final hospitals = snapshot.data!;
                return ListView.builder(
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    return _medicalHospitalCard(hospitals[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Reusable Vertical Card Widget
  Widget _medicalChip({
    required IconData icon,
    required String label,
    required Color borderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? borderColor.withOpacity(isDark ? 0.3 : 0.2) 
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
          border: Border.all(
            color: isSelected ? borderColor : borderColor.withOpacity(0.3), 
            width: 1.5
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: borderColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: isSelected 
                    ? (isDark ? Colors.white : Colors.black) 
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Hospital Card Widget
  Widget _medicalHospitalCard(Hospital hospital) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => sub.MedicalDetailsPage(hospital: hospital),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
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
                  top: Radius.circular(16),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_border, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hospital.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        "Beds: ${hospital.availableBeds}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Emergency: ${hospital.emergencyContact}",
                  style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
