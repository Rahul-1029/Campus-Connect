import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  String selectedCategory = "All";
  final List<String> categories = [
    "All",
    "Books",
    "Electronics",
    "Lab Coat",
    "Tools",
    "Other",
  ];

  // --- 1. NEW: COLOR PALETTE HELPER ---
  // Gives each category a distinct, soft pastel color
  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Books':
        return const Color(0xFFFFF7ED); // Soft Orange
      case 'Electronics':
        return const Color(0xFFEFF6FF); // Soft Blue
      case 'Lab Coat':
        return const Color(0xFFFDF2F8); // Soft Pink
      case 'Tools':
        return const Color(0xFFF0FDF4); // Soft Green
      default:
        return const Color(0xFFF8FAFC); // Soft Grey
    }
  }

  // Gives the ICON a darker shade of the background
  Color _getIconColor(String? category) {
    switch (category) {
      case 'Books':
        return Colors.orange;
      case 'Electronics':
        return Colors.blue;
      case 'Lab Coat':
        return Colors.pink;
      case 'Tools':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Books':
        return Icons.menu_book_rounded;
      case 'Electronics':
        return Icons.laptop_mac_rounded;
      case 'Lab Coat':
        return Icons.science_rounded;
      case 'Tools':
        return Icons.construction_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  // ignore: unused_element
  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  void _contactSeller(String phone, String title) {
    String phoneNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!phoneNumber.startsWith('91')) phoneNumber = '91$phoneNumber';
    String url =
        "https://wa.me/$phoneNumber?text=Hi, I am interested in your item: $title";
    html.window.open(url, '_blank');
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String correctPin,
    String docId,
  ) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your 4-digit PIN to delete this item."),
            const SizedBox(height: 15),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "PIN",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (pinController.text == correctPin) {
                await FirebaseFirestore.instance
                    .collection('listings')
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deleted Successfully!")),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Incorrect PIN!")));
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Clean off-white background
      // --- 2. NEW: MODERN APP BAR ---
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Block
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Campus Connect",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue[900],
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "MVGR Student Marketplace",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // "Sell" Button is now a clean icon in the header
                      IconButton.filled(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PostPage()),
                        ),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: "Sell Item",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- 3. NEW: FLOATING SEARCH BAR ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search books, tools...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => searchQuery = val.toLowerCase()),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- 4. NEW: PILL CATEGORY SELECTOR ---
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => selectedCategory = category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // --- 5. NEW: IMMERSIVE GRID ---
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('listings')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'].toString().toLowerCase();
                    final category = data['category'] ?? "Other";
                    final matchesSearch = title.contains(searchQuery);
                    final matchesCategory =
                        selectedCategory == "All" ||
                        category == selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No items found",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              0.70, // Taller cards for modern look
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onLongPress: () => _showDeleteConfirmation(
                          context,
                          data['deletePin'],
                          docs[index].id,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TOP HALF: COLORFUL ICON BACKGROUND
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(data['category']),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getIconForCategory(data['category']),
                                      size: 48,
                                      color: _getIconColor(data['category']),
                                    ),
                                  ),
                                ),
                              ),

                              // BOTTOM HALF: DETAILS
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['category']?.toUpperCase() ??
                                                "ITEM",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[400],
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            data['title'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "₹${data['price']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                            ),
                                          ),
                                          // Whatsapp Mini Button
                                          GestureDetector(
                                            onTap: () => _contactSeller(
                                              data['contact'],
                                              data['title'],
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF25D366,
                                                ), // WhatsApp Green
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF25D366,
                                                    // ignore: deprecated_member_use
                                                    ).withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.chat_bubble,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
