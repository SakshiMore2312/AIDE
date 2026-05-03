import 'package:flutter/material.dart';
import 'package:aide/models/hospital.dart';
import 'package:aide/services/api_service.dart';

class MedicalDetailsPage extends StatefulWidget {
  final Hospital hospital;

  const MedicalDetailsPage({super.key, required this.hospital});

  @override
  State<MedicalDetailsPage> createState() => _MedicalDetailsPageState();
}

class _MedicalDetailsPageState extends State<MedicalDetailsPage> {
  Map<String, dynamic>? hospitalDetails;
  bool isLoadingDetails = true;
  Key _reviewsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    try {
      final data = await ApiService().getHospital(widget.hospital.id);
      if (mounted) {
        setState(() {
          hospitalDetails = data;
          isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
        });
      }
    }
  }

  void _showReviewDialog() {
    double selectedRating = 5.0;
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Write a Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Share your experience...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (contentController.text.trim().isEmpty) return;
                    try {
                      await ApiService().postHospitalReview(
                        widget.hospital.id,
                        selectedRating,
                        contentController.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {
                          _reviewsKey = UniqueKey();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review posted successfully!")),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget infoCard({required Widget child, required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget contactSection(BuildContext context) {
    if (isLoadingDetails) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ));
    }
    
    final phone = hospitalDetails?['emergency_contact'] ?? "Not Available";
    final website = hospitalDetails?['website'] ?? "Not Available";
    final email = hospitalDetails?['email'] ?? "Not Available";

    return infoCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Emergency Contact",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.phone_outlined, size: 18, color: Colors.red), const SizedBox(width: 8), Text(phone, style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.email_outlined, size: 18, color: Colors.red), const SizedBox(width: 8), Text(email)]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.language_outlined, size: 18, color: Colors.red), const SizedBox(width: 8), Text(website)]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        /// BOOK APPOINTMENT BUTTON
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Book Appointment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),

        body: Column(
          children: [
            /// HEADER IMAGE
            Stack(
              children: [
                Image.network(
                  widget.hospital.image ?? "https://images.unsplash.com/photo-1586773860418-d37222d8fce3",
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.local_hospital, size: 80, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: isDark ? Colors.black54 : Colors.white70,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            /// CONTENT
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hospital.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 18),
                                const SizedBox(width: 4),
                                Text(widget.hospital.rating.toString()),
                              ],
                            ),
                            Text(
                              "Beds: ${widget.hospital.availableBeds}",
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(child: Text(widget.hospital.address, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// TABS
                  TabBar(
                    labelColor: isDark ? Colors.white : Colors.red.shade600,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.red.shade600,
                    tabs: const [
                      Tab(text: "Overview"),
                      Tab(text: "Facilities"),
                      Tab(text: "Reviews"),
                    ],
                  ),

                  /// TAB CONTENT (SCROLLABLE)
                  Expanded(
                    child: TabBarView(
                      children: [
                        /// OVERVIEW
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionTitle("About", context),
                              infoCard(
                                context: context,
                                child: Text(
                                  hospitalDetails?['description'] ?? "No description available.",
                                ),
                              ),

                              sectionTitle("Specialties", context),
                              infoCard(
                                context: context,
                                child: Column(
                                  children: const [
                                    ListTile(
                                        leading: Icon(Icons.favorite, color: Colors.red),
                                        title: Text("Cardiology")),
                                    ListTile(
                                        leading: Icon(Icons.visibility, color: Colors.blue),
                                        title: Text("Ophthalmology")),
                                    ListTile(
                                        leading: Icon(Icons.child_care, color: Colors.green),
                                        title: Text("Pediatrics")),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                              contactSection(context),
                            ],
                          ),
                        ),

                        /// FACILITIES
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionTitle("Available Services", context),
                              infoCard(
                                context: context,
                                child: Column(
                                  children: [
                                    ListTile(
                                        leading: Icon(Icons.bloodtype, color: Colors.red.shade700),
                                        title: const Text("Blood Bank"),
                                        trailing: Icon((hospitalDetails?['blood_bank_available'] ?? false) ? Icons.check_circle : Icons.cancel, color: (hospitalDetails?['blood_bank_available'] ?? false) ? Colors.green : Colors.red),
                                    ),
                                    ListTile(
                                        leading: const Icon(Icons.directions_car, color: Colors.orange),
                                        title: const Text("Ambulance"),
                                        trailing: Icon((hospitalDetails?['ambulance_available'] ?? false) ? Icons.check_circle : Icons.cancel, color: (hospitalDetails?['ambulance_available'] ?? false) ? Colors.green : Colors.red),
                                    ),
                                    const ListTile(
                                        leading: Icon(Icons.local_pharmacy, color: Colors.blue),
                                        title: Text("24/7 Pharmacy"),
                                        trailing: Icon(Icons.check_circle, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                              contactSection(context),
                            ],
                          ),
                        ),

                        /// REVIEWS
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Center(
                                child: GestureDetector(
                                  onTap: _showReviewDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.rate_review_outlined, color: Colors.red.shade600, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Write Your Review",
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              FutureBuilder<List<dynamic>>(
                                key: _reviewsKey,
                                future: ApiService().getHospitalReviews(widget.hospital.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(child: Text('Error loading reviews'));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: Text('No reviews found.'),
                                      ),
                                    );
                                  }
                                  
                                  final reviews = snapshot.data!;
                                  return infoCard(
                                    context: context,
                                    child: Column(
                                      children: reviews.map((r) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: isDark ? Colors.red.shade900 : Colors.red.shade100,
                                          child: Icon(Icons.person, color: isDark ? Colors.red.shade100 : Colors.red.shade600),
                                        ),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("User ${r['user_id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.orange, size: 14),
                                                const SizedBox(width: 4),
                                                Text(r['rating'].toString(), style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(r['content'] ?? ''),
                                      )).toList(),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              contactSection(context),
                            ],
                          ),
                        ),
                      ],
                    ),
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
