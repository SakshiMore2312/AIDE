import 'package:educonnect/models/pg.dart';
import 'package:educonnect/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subpage/stay_details.dart';
import 'widgets/filter_bottom_sheet.dart';

class StayPGPage extends StatefulWidget {
  const StayPGPage({super.key});

  @override
  State<StayPGPage> createState() => _StayPGPageState();
}

class _StayPGPageState extends State<StayPGPage> {
  final ApiService _apiService = ApiService();
  late Future<List<PG>> _pgsFuture;
  String _searchQuery = "";
  String _sortBy = "distance";
  String _order = "asc";
  String _minRating = "any";
  double _radius = 50.0;
  String? _selectedGender; 
  String _selectedCategory = "Stay"; // Default to Stay

  @override
  void initState() {
    super.initState();
    _fetchPGs();
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color color, String typeValue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _selectedCategory == typeValue;
    return GestureDetector(
      onTap: () {
        if (_selectedCategory != typeValue) {
          setState(() {
            _selectedCategory = typeValue;
          });
          _fetchPGs();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(isDark ? 0.3 : 0.2) 
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3), 
            width: 1.5
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
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

  void _fetchPGs() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lon = prefs.getDouble('lon');

    setState(() {
      if (_selectedCategory == "PG") {
        _pgsFuture = _apiService.getPGs(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          lat: lat,
          lon: lon,
          radius: _radius,
          gender: _selectedGender,
          sortBy: _sortBy,
          order: _order,
          minRating: _minRating,
        );
      } else {
        _pgsFuture = _apiService.getHostels(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          lat: lat,
          lon: lon,
          radius: _radius,
          gender: _selectedGender,
          sortBy: _sortBy,
          order: _order,
          minRating: _minRating,
        );
      }
    });
  }

  Widget _stayChip(BuildContext context, String title, IconData icon, Color color, String? genderValue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _selectedGender == genderValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedGender == genderValue) {
            _selectedGender = null;
          } else {
            _selectedGender = genderValue;
          }
        });
        _fetchPGs();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(isDark ? 0.3 : 0.2) 
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3), 
            width: 1.5
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Stay / PG Services",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              /// Search
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
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
                          _fetchPGs();
                        },
                        decoration: InputDecoration(
                          icon: const Icon(Icons.search),
                          hintText: "Search in $_selectedCategory...",
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
                            _fetchPGs();
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

              /// SORTING INDICATOR
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

              /// CATEGORIES
              const Text("Stay Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryCard(context, "Stay", Icons.apartment, Colors.blue, "Stay"),
                    _categoryCard(context, "PG", Icons.hotel, Colors.orange, "PG"),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              const SizedBox(height: 10),

              FutureBuilder<List<PG>>(
                future: _pgsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  final pgs = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${pgs.length} properties found",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...pgs.map((pg) => _pgCard(context, pg)).toList(),
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

  Widget _pgCard(BuildContext context, PG pg) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PGDetailsPage(pg: pg, type: _selectedCategory),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pg.image ?? "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.home, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pg.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedCategory,
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pg.address,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${pg.rent}/mo",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              "${pg.rating} ${pg.distance != null ? '(${pg.distance!.toStringAsFixed(1)} km)' : ''}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}