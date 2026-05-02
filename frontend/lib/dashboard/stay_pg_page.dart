import 'package:educonnect/models/pg.dart';
import 'package:educonnect/services/api_service.dart';
import 'package:flutter/material.dart';
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
  String _sortBy = "name";
  String _order = "asc";
  String _minRating = "any";
  double _radius = 50.0;

  @override
  void initState() {
    super.initState();
    _fetchPGs();
  }

  void _fetchPGs() {
    setState(() {
      _pgsFuture = _apiService.getPGs(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        lat: 18.52, // Mock Pune Lat
        lon: 73.85, // Mock Pune Lon
        radius: _radius,
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
              const Text(
                "Stay / PG",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "Search PG & stays...",
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
              const SizedBox(height: 25),

              FutureBuilder<List<PG>>(
                future: _pgsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No properties found'));
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
            builder: (context) => PGDetailsPage(pg: pg),
          ),
        );
      },
      child: Container(
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
            /// Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                pg.image ??
                    "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.home, size: 50, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pg.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pg.gender,
                          style: const TextStyle(
                              color: Colors.green, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(pg.rating.toString()),
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
                          pg.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${pg.rent} / month",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        pg.foodIncluded ? "Food Included" : "No Food",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
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
}