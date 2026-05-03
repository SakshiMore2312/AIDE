import 'package:educonnect/models/pg.dart';
import 'package:flutter/material.dart';
import 'package:educonnect/services/api_service.dart';

class PGDetailsPage extends StatefulWidget {
  final PG pg;
  final String type; // "Stay" or "PG"
  const PGDetailsPage({super.key, required this.pg, required this.type});

  @override
  State<PGDetailsPage> createState() => _PGDetailsPageState();
}

class _PGDetailsPageState extends State<PGDetailsPage> {
  Map<String, dynamic>? pgDetails;
  bool isLoadingDetails = true;
  Key _reviewsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    try {
      final data = widget.type == "PG" 
          ? await ApiService().getPG(widget.pg.id)
          : await ApiService().getHostelDetails(widget.pg.id);
      if (mounted) {
        setState(() {
          pgDetails = data;
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
                      if (widget.type == "PG") {
                        await ApiService().postPGReview(
                          widget.pg.id,
                          selectedRating,
                          contentController.text.trim(),
                        );
                      } else {
                        await ApiService().postHostelReview(
                          widget.pg.id,
                          selectedRating,
                          contentController.text.trim(),
                        );
                      }
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
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
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
    
    final phone = pgDetails?['phone_number'] ?? "Not Available";
    final email = pgDetails?['email'] ?? "Not Available";

    return infoCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Owner Contact",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.phone_outlined, size: 18, color: Colors.purple), const SizedBox(width: 8), Text(phone)]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.email_outlined, size: 18, color: Colors.purple), const SizedBox(width: 8), Text(email)]),
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

        /// Schedule Visit Button
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: const Text("Schedule Visit"),
            style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );

              if (selectedDate == null) return;

              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime == null) return;

              if(context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: const Text("Visit Scheduled"),
                      content: Text(
                        "Your visit is scheduled on\n"
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        " at ${selectedTime.format(context)}",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        )
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            "${widget.type} Details",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Image
                    Image.network(
                      widget.pg.image ?? "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2",
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.home, size: 80, color: Colors.grey),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pg.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(widget.pg.rating.toString()),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.pg.address,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// Pricing
                          Text(
                            "Pricing",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.purple.shade900 : Colors.purple.shade50,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.currency_rupee),
                                    const SizedBox(height: 6),
                                    Text("₹${widget.pg.rent} / Month"),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.blue.shade900 : Colors.blue.shade50,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.home),
                                    const SizedBox(height: 6),
                                    Text("Deposit ₹${pgDetails?['deposit'] ?? 10000}"),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          /// Tabs
                          TabBar(
                            labelColor: isDark ? Colors.white : Colors.purple,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.purple,
                            tabs: const [
                              Tab(text: "Overview"),
                              Tab(text: "Amenities"),
                              Tab(text: "Reviews"),
                            ],
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            height: 420,
                            child: TabBarView(
                              children: [

                                /// OVERVIEW TAB
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      sectionTitle("Description", context),
                                      infoCard(
                                        context: context,
                                        child: Text(
                                          pgDetails?['description'] ?? "No description available.",
                                        ),
                                      ),

                                      sectionTitle("House Rules", context),
                                      infoCard(
                                        context: context,
                                        child: Column(
                                          children: const [
                                            ListTile(
                                              leading: Icon(Icons.access_time),
                                              title: Text(
                                                  "Gate closes at 11 PM"),
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(Icons.smoke_free),
                                              title: Text(
                                                  "No smoking inside rooms"),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.people),
                                              title: Text(
                                                  "No outside guests allowed"),
                                            ),
                                          ],
                                        ),
                                      ),

                                      sectionTitle("Nearby Places", context),
                                      infoCard(
                                        context: context,
                                        child: Column(
                                          children: const [
                                            ListTile(
                                              leading:
                                                  Icon(Icons.business),
                                              title: Text(
                                                  "Tech Park - 1 km"),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  Icons.restaurant),
                                              title: Text(
                                                  "Food Street - 500 m"),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons
                                                  .local_hospital),
                                              title: Text(
                                                  "Hospital - 800 m"),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      contactSection(context),
                                    ],
                                  ),
                                ),

                                /// AMENITIES TAB
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      infoCard(
                                        context: context,
                                        child: Column(
                                          children: [
                                            const ListTile(
                                              leading: Icon(Icons.wifi,
                                                  color: Colors.blue),
                                              title: Text("High Speed WiFi"),
                                            ),
                                            const Divider(),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.restaurant,
                                                  color: Colors.orange),
                                              title: Text(widget.pg.foodIncluded ? "Daily Meals Included" : "No Meals"),
                                            ),
                                            const Divider(),
                                            const ListTile(
                                              leading: Icon(
                                                  Icons
                                                      .local_laundry_service,
                                                  color: Colors.purple),
                                              title:
                                                  Text("Laundry Service"),
                                            ),
                                            const Divider(),
                                            const ListTile(
                                              leading: Icon(
                                                  Icons.local_parking,
                                                  color: Colors.green),
                                              title:
                                                  Text("Parking Facility"),
                                            ),
                                            const Divider(),
                                            const ListTile(
                                              leading: Icon(Icons.security,
                                                  color: Colors.red),
                                              title: Text("24x7 Security"),
                                            ),
                                            const Divider(),
                                            const ListTile(
                                              leading: Icon(
                                                  Icons.cleaning_services,
                                                  color: Colors.teal),
                                              title:
                                                  Text("Housekeeping"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      contactSection(context),
                                    ],
                                  ),
                                ),

                                /// REVIEWS TAB
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Center(
                                        child: GestureDetector(
                                          onTap: _showReviewDialog,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.rate_review_outlined, color: Colors.purple, size: 18),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Write Your Review",
                                                  style: TextStyle(
                                                    color: Colors.purple,
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
                                        future: widget.type == "PG" 
                                            ? ApiService().getPGReviews(widget.pg.id)
                                            : ApiService().getHostelReviews(widget.pg.id),
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
                                                  backgroundColor: isDark ? Colors.purple.shade900 : Colors.purple.shade100,
                                                  child: Icon(Icons.person, color: isDark ? Colors.purple.shade100 : Colors.purple),
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
            ),
          ],
        ),
      ),
    );
  }
}

