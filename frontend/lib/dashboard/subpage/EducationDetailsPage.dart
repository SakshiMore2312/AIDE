import 'package:flutter/material.dart';
import 'package:aide/services/api_service.dart';

class EducationDetailsPage extends StatefulWidget {
  final int id;
  final String name;
  final String category;
  final String image;
  final String location;
  final String fees;
  final String rating;

  const EducationDetailsPage({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.location,
    required this.fees,
    required this.rating,
  });

  @override
  State<EducationDetailsPage> createState() => _EducationDetailsPageState();
}

class _EducationDetailsPageState extends State<EducationDetailsPage> {
  Map<String, dynamic>? collegeDetails;
  bool isLoadingDetails = true;
  Key _reviewsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    try {
      final data = await ApiService().getCollege(widget.id);
      if (mounted) {
        setState(() {
          collegeDetails = data;
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
                      await ApiService().postCollegeReview(
                        widget.id,
                        selectedRating,
                        contentController.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {
                          _reviewsKey = UniqueKey(); // Refresh reviews
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
    
    final phone = collegeDetails?['phone_number'] ?? "Not Available";
    final website = collegeDetails?['website'] ?? "Not Available";
    final email = collegeDetails?['email'] ?? "Not Available";

    return infoCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Contact Admissions",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.phone_outlined, size: 18, color: Colors.deepPurple), const SizedBox(width: 8), Text(phone)]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.email_outlined, size: 18, color: Colors.deepPurple), const SizedBox(width: 8), Text(email)]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.language_outlined, size: 18, color: Colors.deepPurple), const SizedBox(width: 8), Text(website)]),
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

        /// APPLY BUTTON
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Apply For Admission", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),

        body: Column(
          children: [
            /// HEADER IMAGE
            Stack(
              children: [
                Image.network(
                  widget.image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.school, size: 80, color: Colors.grey),
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
                        Text(widget.name,
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
                                Text(widget.rating.split(' ')[0]),
                              ],
                            ),
                            Text(
                              "Price: ${widget.fees}",
                              style: TextStyle(
                                color: Colors.deepPurple.shade400,
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
                            Expanded(child: Text(widget.location, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// TABS
                  TabBar(
                    labelColor: isDark ? Colors.white : Colors.deepPurple,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.deepPurple,
                    tabs: const [
                      Tab(text: "Overview"),
                      Tab(text: "Admission"),
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
                                  collegeDetails?['description'] ?? "No description available.",
                                ),
                              ),

                              sectionTitle("Courses", context),
                              infoCard(
                                context: context,
                                child: Column(
                                  children: const [
                                    ListTile(
                                        leading: Icon(Icons.science_outlined),
                                        title: Text("Science")),
                                    ListTile(
                                        leading: Icon(Icons.business_outlined),
                                        title: Text("Commerce")),
                                    ListTile(
                                        leading: Icon(Icons.palette_outlined),
                                        title: Text("Arts")),
                                  ],
                                ),
                              ),

                              sectionTitle("Facilities", context),
                              infoCard(
                                context: context,
                                child: Column(
                                  children: const [
                                    ListTile(
                                        leading: Icon(Icons.menu_book_outlined),
                                        title: Text("Library")),
                                    ListTile(
                                        leading: Icon(Icons.computer_outlined),
                                        title: Text("Computer Lab")),
                                    ListTile(
                                        leading: Icon(Icons.sports_soccer),
                                        title: Text("Sports Ground")),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                              contactSection(context),
                            ],
                          ),
                        ),

                        /// ADMISSION
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionTitle("Fees", context),
                              infoCard(context: context, child: Text(widget.fees)),

                              sectionTitle("Process", context),
                              infoCard(
                                context: context,
                                child: const Text(
                                  "1. Apply\n2. Documents\n3. Test\n4. Admission",
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
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.rate_review_outlined, color: Colors.deepPurple, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "Write Your Review",
                                          style: TextStyle(
                                            color: Colors.deepPurple,
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
                                future: ApiService().getCollegeReviews(widget.id),
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
                                          backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade100,
                                          child: Icon(Icons.person, color: isDark ? Colors.deepPurple.shade100 : Colors.deepPurple),
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
