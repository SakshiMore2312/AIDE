import 'package:aide/dashboard/subpage/EducationDetailsPage.dart';
import 'package:aide/models/college.dart';
import 'package:aide/services/api_service.dart';
import 'package:aide/dashboard/widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final ApiService _apiService = ApiService();
  late Future<List<College>> _collegesFuture;
  String _searchQuery = "";
  String _sortBy = "distance";
  String _order = "asc";
  String _minRating = "any";
  String _selectedType = "Colleges"; // Set default to Colleges
  double _radius = 50.0;

  @override
  void initState() {
    super.initState();
    _fetchColleges();
  }

  void _fetchColleges() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lon = prefs.getDouble('lon');

    setState(() {
      if (_selectedType == "Colleges") {
        _collegesFuture = _apiService.getColleges(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          lat: lat,
          lon: lon,
          radius: _radius,
          sortBy: _sortBy,
          order: _order,
        );
      } else if (_selectedType == "Coaching") {
        _collegesFuture = _apiService.getCoaching(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          lat: lat,
          lon: lon,
          radius: _radius,
          sortBy: _sortBy,
          order: _order,
        );
      } else if (_selectedType == "Mess") {
        _collegesFuture = _apiService.getMess(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          lat: lat,
          lon: lon,
          radius: _radius,
          sortBy: _sortBy,
          order: _order,
        );
      } else {
        _collegesFuture = _apiService.getSchools(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          lat: lat,
          lon: lon,
          radius: _radius,
          sortBy: _sortBy,
          order: _order,
        );
      }
    });
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color color, String categoryValue) {
    final isSelected = _selectedType == categoryValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (_selectedType != categoryValue) {
          setState(() {
            _selectedType = categoryValue;
          });
          _fetchColleges();
        }
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

  Widget institutionCard({
    required BuildContext context,
    required int id,
    required String name,
    required String category,
    required String image,
    required String location,
    required String fees,
    required String rating,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EducationDetailsPage(
              id: id,
              name: name,
              category: category,
              image: image,
              location: location,
              fees: fees,
              rating: rating,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.school, size: 50, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                            rating.split(' ')[0], // Extract just the number
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          "Price: $fees",
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
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SEARCH
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _fetchColleges();
                  },
                  decoration: InputDecoration(
                    hintText: "Search in Colleges...",
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
                        _fetchColleges();
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
          const Text("Education Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryCard(context, "Colleges", Icons.school, Colors.blue, "Colleges"),
                _categoryCard(context, "Coaching", Icons.menu_book, Colors.orange, "Coaching"),
                _categoryCard(context, "Mess", Icons.restaurant, Colors.red, "Mess"),
                _categoryCard(context, "Schools", Icons.school_outlined, Colors.green, "Schools"),
              ],
            ),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: FutureBuilder<List<College>>(
              future: _collegesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                final colleges = snapshot.data!;
                return ListView.builder(
                  itemCount: colleges.length,
                  itemBuilder: (context, index) {
                    final college = colleges[index];
                    return institutionCard(
                      context: context,
                      id: college.id,
                      name: college.name,
                      category: college.type,
                      image: college.image ??
                          "https://images.unsplash.com/photo-1596495577886-d920f1fb7238",
                      location: college.address,
                      fees: "₹${college.fees}/year",
                      rating:
                          "${college.rating} ${college.distance != null ? '(${college.distance!.toStringAsFixed(1)} km)' : ''}",
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
