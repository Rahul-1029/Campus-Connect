import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'post_page.dart';
import 'report_lost_page.dart';

// --- GLOBAL HELPER FUNCTIONS ---
Color _getCategoryColor(String? category) {
  switch (category) {
    case 'Books':
      return const Color(0xFFFFF7ED);
    case 'Electronics':
      return const Color(0xFFEFF6FF);
    case 'Lab Coat':
      return const Color(0xFFFDF2F8);
    case 'Tools':
      return const Color(0xFFF0FDF4);
    default:
      return const Color(0xFFF8FAFC);
  }
}

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

void _contactSeller(String phone, String message) {
  String phoneNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (!phoneNumber.startsWith('91')) phoneNumber = '91$phoneNumber';
  String url = "https://wa.me/$phoneNumber?text=$message";
  html.window.open(url, '_blank');
}

// ======================= HOME PAGE =======================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  String selectedCategory = "All";
  bool showLostAndFound = false;

  final List<String> categories = [
    "All",
    "Books",
    "Electronics",
    "Lab Coat",
    "Tools",
    "Other",
  ];

  // DELETE FUNCTION (Works for both Market and Lost Items)
  void _showDeleteConfirmation(
    BuildContext context,
    String correctPin,
    String docId,
    String collection,
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
                    .collection(collection)
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
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200
        ? 5
        : screenWidth > 900
        ? 4
        : screenWidth > 600
        ? 3
        : 2;
    double aspectRatio = screenWidth > 600 ? 0.85 : 0.70;

    // Adjust flex for PC vs Mobile
    int imageFlex = screenWidth > 600 ? 4 : 3;
    int textFlex = screenWidth > 600 ? 3 : 4;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // FLOATING BUTTON: Changes based on Toggle
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: showLostAndFound ? Colors.redAccent : Colors.black,
        onPressed: () {
          if (showLostAndFound) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportLostPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostPage()),
            );
          }
        },
        label: Text(showLostAndFound ? "Report Lost" : "Sell Item"),
        icon: Icon(showLostAndFound ? Icons.campaign : Icons.add),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT SIDE: TITLE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Campus Connect",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue[900],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "MVGR Student Marketplace",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  "LIVE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () {
                          // "About Us" popup
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Visionary Variables"),
                              content: const Text(
                                "Built with ❤️ for MVGR.\n\nTeam Lead: Rahul Attili\nStatus: Offline Mode Active",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(
                            2,
                          ), // White border effect
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            radius: 24,
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // NEW TOGGLE SWITCH (Market vs Lost & Found)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => showLostAndFound = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !showLostAndFound
                                    ? Colors.blue[900]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Marketplace",
                                  style: TextStyle(
                                    color: !showLostAndFound
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => showLostAndFound = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: showLostAndFound
                                    ? Colors.redAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Lost & Found",
                                  style: TextStyle(
                                    color: showLostAndFound
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // SEARCH
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search items...",
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

                  // FILTERS (Only show if NOT in Lost mode)
                  if (!showLostAndFound)
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
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
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

            // GRID CONTENT
            Expanded(
              child: StreamBuilder(
                // SWITCH STREAMS BASED ON TOGGLE
                stream: showLostAndFound
                    ? FirebaseFirestore.instance
                          .collection('lost_found')
                          .orderBy('timestamp', descending: true)
                          .snapshots()
                    : FirebaseFirestore.instance
                          .collection('listings')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),

                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'].toString().toLowerCase();
                    // If in Lost mode, ignore category filter
                    if (showLostAndFound) return title.contains(searchQuery);

                    final category = data['category'] ?? "Other";
                    return title.contains(searchQuery) &&
                        (selectedCategory == "All" ||
                            category == selectedCategory);
                  }).toList();

                  if (docs.isEmpty)
                    return const Center(child: Text("No items found"));

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;

                      // === OPTION A: LOST & FOUND CARD (Updated Design) ===
                      if (showLostAndFound) {
                        return GestureDetector(
                          onLongPress: () => _showDeleteConfirmation(
                            context,
                            data['deletePin'],
                            docs[index].id,
                            'lost_found',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsPage(
                                  data: data,
                                  isLostItem: true,
                                ), // Sending a flag!
                              ),
                            );
                          },
                          child: Container(
                            clipBehavior: Clip
                                .hardEdge, // cuts off the watermark if it overflows
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFEF2F2,
                              ), // Very light red (Sticky note feel)
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.shade100,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // 1. WATERMARK ICON
                                Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: Icon(
                                      Icons.campaign_rounded,
                                      size: 100,
                                      color: Colors.red.withOpacity(0.15),
                                    ),
                                  ),
                                ),

                                // 2. TEXT CONTENT
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                          // LOCATION BADGE
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.pin_drop,
                                                  size: 12,
                                                  color: Colors.redAccent,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    data['location'] ??
                                                        "Unknown",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          // TITLE
                                          Text(
                                            data['title'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: Color(0xFF7F1D1D),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          // DESCRIPTION
                                          Text(
                                            data['description'] ??
                                                "No details provided.",
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red[900],
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 15),

                                      // BUTTON
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.redAccent,
                                            elevation: 0,
                                            side: const BorderSide(
                                              color: Colors.redAccent,
                                            ),
                                            minimumSize: const Size(0, 36),
                                          ),
                                          onPressed: () => _contactSeller(
                                            data['contact'],
                                            "I found your item: ${data['title']}",
                                          ),
                                          icon: const Icon(
                                            Icons.check,
                                            size: 16,
                                          ),
                                          label: const Text("I Found It"),
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

                      // === OPTION B: MARKET CARD (Your existing Beautiful UI) ===
                      return GestureDetector(
                        onLongPress: () => _showDeleteConfirmation(
                          context,
                          data['deletePin'],
                          docs[index].id,
                          'listings',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(data: data),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TOP HALF: ICON
                              Expanded(
                                flex: imageFlex,
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
                              // BOTTOM HALF: INFO
                              Expanded(
                                flex: textFlex,
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
                                            data['category'] ?? "ITEM",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[400],
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
                                          GestureDetector(
                                            onTap: () => _contactSeller(
                                              data['contact'],
                                              "Hi, I am interested in your item: ${data['title']}",
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF25D366),
                                                shape: BoxShape.circle,
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

// ======================= PRODUCT DETAILS PAGE =======================
class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLostItem;

  const ProductDetailsPage({
    super.key,
    required this.data,
    this.isLostItem = false,
  });

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (diff.inDays >= 1) {
      return "${diff.inDays} days ago";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} hours ago";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} mins ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. DYNAMIC THEME (Red for Lost, Category Color for Market)
    final category = isLostItem
        ? "Lost & Found"
        : (data['category'] ?? "Other");
    final themeColor = isLostItem
        ? Colors.redAccent
        : _getCategoryColor(category);
    final iconColor = isLostItem ? Colors.white : _getIconColor(category);
    final mainIcon = isLostItem
        ? Icons.campaign_rounded
        : _getIconForCategory(category);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isLostItem ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isLostItem ? "Lost Item Report" : category,
          style: TextStyle(
            color: isLostItem ? Colors.white : iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO HEADER
            Container(
              height: 200,
              color: themeColor,
              child: Center(child: Icon(mainIcon, size: 100, color: iconColor)),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TIME & BADGE ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Posted ${_timeAgo(data['timestamp'])}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLostItem ? Colors.red[50] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLostItem ? Icons.warning : Icons.verified,
                              size: 16,
                              color: isLostItem ? Colors.red : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLostItem ? "Lost Alert" : "Verified Student",
                              style: TextStyle(
                                color: isLostItem
                                    ? Colors.red
                                    : Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // TITLE
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // PRICE OR LOCATION (Depending on mode)
                  if (!isLostItem)
                    Text(
                      "₹${data['price']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          "Last seen: ${data['location']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),

                  // FULL DESCRIPTION
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['description'] ?? "No description provided.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM ACTION BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isLostItem
                ? Colors.redAccent
                : const Color(0xFF25D366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () => _contactSeller(
            data['contact'],
            isLostItem
                ? "I found your item: ${data['title']}"
                : "Hi, I am interested in your item: ${data['title']}",
          ),
          icon: Icon(
            isLostItem ? Icons.check_circle : Icons.chat_bubble_outline,
          ),
          label: Text(
            isLostItem ? "I Found This Item" : "Chat on WhatsApp",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
