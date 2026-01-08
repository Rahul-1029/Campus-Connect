import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'post_page.dart';
import 'report_lost_page.dart';
import 'exchange_post_page.dart';
import '../notification_service.dart'; // Import the new service

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
  int _viewMode = 0; // 0 = Market, 1 = Lost, 2 = Exchange

  final List<String> categories = [
    "All",
    "Books",
    "Electronics",
    "Lab Coat",
    "Tools",
    "Other",
  ];

  // --- NEW: SUBSCRIBE DIALOG ---
  void _showSubscribeDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Get Email Alerts 🔔"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your PERSONAL email (Gmail, etc.) to get notified when students post new items.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Personal Email",
                hintText: "example@gmail.com",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
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
              if (emailController.text.isNotEmpty) {
                await NotificationService.subscribeToAlerts(
                  emailController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Subscribed for alerts!")),
                  );
                }
              }
            },
            child: const Text("Subscribe"),
          ),
        ],
      ),
    );
  }

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

    int imageFlex = screenWidth > 600 ? 4 : 3;
    int textFlex = screenWidth > 600 ? 3 : 4;

    Color fabColor;
    String fabLabel;
    IconData fabIcon;
    Stream<QuerySnapshot> currentStream;
    String collectionName;

    if (_viewMode == 1) {
      fabColor = Colors.redAccent;
      fabLabel = "Report Lost";
      fabIcon = Icons.campaign;
      collectionName = 'lost_found';
      currentStream = FirebaseFirestore.instance
          .collection('lost_found')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else if (_viewMode == 2) {
      fabColor = Colors.teal;
      fabLabel = "Exchange Book";
      fabIcon = Icons.swap_horiz_rounded;
      collectionName = 'book_exchange';
      currentStream = FirebaseFirestore.instance
          .collection('book_exchange')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      fabColor = Colors.black;
      fabLabel = "Sell Item";
      fabIcon = Icons.add;
      collectionName = 'listings';
      currentStream = FirebaseFirestore.instance
          .collection('listings')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: fabColor,
        onPressed: () {
          if (_viewMode == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportLostPage()),
            );
          } else if (_viewMode == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExchangePostPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostPage()),
            );
          }
        },
        label: Text(fabLabel),
        icon: Icon(fabIcon),
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

                      // --- ACTIONS ROW ---
                      Row(
                        children: [
                          // 1. SUBSCRIBE BUTTON (NEW)
                          GestureDetector(
                            onTap: _showSubscribeDialog,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.yellow[100],
                                radius: 24,
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ),

                          // 2. INFO BUTTON
                          GestureDetector(
                            onTap: () {
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
                              padding: const EdgeInsets.all(2),
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TOGGLE SWITCH
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildToggleButton("Market", 0),
                        _buildToggleButton("Lost", 1),
                        _buildToggleButton("Exchange", 2),
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

                  // FILTERS
                  if (_viewMode == 0)
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
                stream: currentStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'].toString().toLowerCase();
                    if (_viewMode != 0) return title.contains(searchQuery);
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

                      // === 1. LOST & FOUND CARD ===
                      if (_viewMode == 1) {
                        return GestureDetector(
                          onLongPress: () => _showDeleteConfirmation(
                            context,
                            data['deletePin'],
                            docs[index].id,
                            collectionName,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsPage(data: data, mode: 1),
                              ),
                            );
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                                data['location'] ?? "Unknown",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
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
                                      Text(
                                        data['description'] ?? "No details.",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red[900],
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

                      // === 2. BOOK EXCHANGE CARD ===
                      if (_viewMode == 2) {
                        return GestureDetector(
                          onLongPress: () => _showDeleteConfirmation(
                            context,
                            data['deletePin'],
                            docs[index].id,
                            collectionName,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsPage(data: data, mode: 2),
                              ),
                            );
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.teal.shade100,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -20,
                                  top: 40,
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: Icon(
                                      Icons.auto_stories_rounded,
                                      size: 140,
                                      color: Colors.teal.withOpacity(0.15),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.teal[800],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          "EXCHANGE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      const Spacer(flex: 1),
                                      Text(
                                        data['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Serif',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                          color: Colors.teal[900],
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "by ${data['author'] ?? 'Unknown'}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                          color: Colors.teal[700],
                                        ),
                                      ),
                                      const Spacer(flex: 2),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.teal.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "TRADE FOR:",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              data['exchange_with'] ?? "?",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal[800],
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

                      // === 3. MARKET CARD ===
                      return GestureDetector(
                        onLongPress: () => _showDeleteConfirmation(
                          context,
                          data['deletePin'],
                          docs[index].id,
                          collectionName,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(data: data, mode: 0),
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
                                              "Hi, I am interested in: ${data['title']}",
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

  Widget _buildToggleButton(String text, int index) {
    bool isActive = _viewMode == index;
    Color activeColor;
    if (index == 0)
      activeColor = Colors.blue[900]!;
    else if (index == 1)
      activeColor = Colors.redAccent;
    else
      activeColor = Colors.teal;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= PRODUCT DETAILS PAGE =======================
class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final int mode;

  const ProductDetailsPage({super.key, required this.data, required this.mode});

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return "${date.day}/${date.month}/${date.year}";
    if (diff.inDays >= 1) return "${diff.inDays} days ago";
    if (diff.inHours >= 1) return "${diff.inHours} hours ago";
    if (diff.inMinutes >= 1) return "${diff.inMinutes} mins ago";
    return "Just now";
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    IconData mainIcon;
    String headerTitle;

    if (mode == 1) {
      themeColor = Colors.redAccent;
      mainIcon = Icons.campaign_rounded;
      headerTitle = "Lost Item Report";
    } else if (mode == 2) {
      themeColor = Colors.teal;
      mainIcon = Icons.import_contacts_rounded;
      headerTitle = "Book Exchange";
    } else {
      themeColor = _getCategoryColor(data['category'] ?? "Other");
      if (themeColor == const Color(0xFFF8FAFC)) themeColor = Colors.grey;
      mainIcon = _getIconForCategory(data['category']);
      headerTitle = data['category'] ?? "Item Details";
    }

    Color iconColor = mode == 0
        ? _getIconColor(data['category'])
        : Colors.white;
    Color appBarColor = mode == 0 ? Colors.white : themeColor;
    Color appBarIconColor = mode == 0 ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          headerTitle,
          style: TextStyle(color: appBarIconColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: mode == 0
                  ? _getCategoryColor(data['category'])
                  : themeColor,
              child: Center(child: Icon(mainIcon, size: 100, color: iconColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          color: mode == 1
                              ? Colors.red[50]
                              : (mode == 2 ? Colors.teal[50] : Colors.blue[50]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              mode == 1 ? Icons.warning : Icons.verified,
                              size: 16,
                              color: mode == 1
                                  ? Colors.red
                                  : (mode == 2 ? Colors.teal : Colors.blue),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mode == 1 ? "Lost Alert" : "Student Listed",
                              style: TextStyle(
                                color: mode == 1
                                    ? Colors.red
                                    : (mode == 2
                                          ? Colors.teal[800]
                                          : Colors.blue[800]),
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
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (mode == 0)
                    Text(
                      "₹${data['price']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else if (mode == 1)
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
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "By ${data['author']}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz, color: Colors.teal),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Wants: ${data['exchange_with']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
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
                ],
              ),
            ),
          ],
        ),
      ),
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
            backgroundColor: mode == 1
                ? Colors.redAccent
                : (mode == 2 ? Colors.teal : const Color(0xFF25D366)),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            String msg = "";
            if (mode == 0)
              msg = "Hi, I am interested in buying: ${data['title']}";
            else if (mode == 1)
              msg = "I found your item: ${data['title']}";
            else
              msg =
                  "Hi, I want to trade for your book: ${data['title']}. I have: ...";
            _contactSeller(data['contact'], msg);
          },
          icon: Icon(
            mode == 1
                ? Icons.check_circle
                : (mode == 2 ? Icons.swap_calls : Icons.chat_bubble_outline),
          ),
          label: Text(
            mode == 1
                ? "I Found This Item"
                : (mode == 2 ? "Propose Exchange" : "Chat on WhatsApp"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
