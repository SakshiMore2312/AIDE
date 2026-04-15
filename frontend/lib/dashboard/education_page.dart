import 'package:educonnect/dashboard/subpage/EducationDetailsPage.dart';
import 'package:educonnect/models/college.dart';
import 'package:educonnect/services/api_service.dart';
import 'package:flutter/material.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final ApiService _apiService = ApiService();
  late Future<List<College>> _collegesFuture;

  @override
  void initState() {
    super.initState();
    _collegesFuture = _apiService.getColleges();
  }

  Widget institutionCard({
    required BuildContext context,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
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
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.school, size: 50, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
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
                          color: category == "College"
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: category == "College"
                                ? Colors.blue
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("⭐ $rating"),
                  const SizedBox(height: 6),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fees,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
        children: [
          /// SEARCH
          TextField(
            decoration: InputDecoration(
              hintText: "Search institutions...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<College>>(
              future: _collegesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No institutions found'));
                }

                final colleges = snapshot.data!;
                return ListView.builder(
                  itemCount: colleges.length,
                  itemBuilder: (context, index) {
                    final college = colleges[index];
                    return institutionCard(
                      context: context,
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