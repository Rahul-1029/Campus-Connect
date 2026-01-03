import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'post_page.dart';

// --- HOME PAGE (The Feed) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Helper function to cycle through Google colors
  Color _getGdgColor(int index) {
    List<Color> colors = [
      Color(0xFF4285F4),
      Color(0xFFEA4335),
      Color(0xFFFBBC05),
      Color(0xFF34A853),
    ];
    return colors[index % colors.length];
  }

  Future<void> _deleteItem(BuildContext context, String docId) async {
    try {
      // 1. Delete from Firebase
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(docId)
          .delete();

      // 2. Success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Item removed from campus feed!")));

      // 3. THIS IS THE KEY: If the contact dialog was open, this closes it.
      // If you are calling this from the Delete Dialog, you might need to pop twice.
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  void _showContactDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // The Title (now in an Expanded widget so it doesn't overlap the button)
              Expanded(
                child: Text(
                  doc['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // The Delete Trash Icon
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                onPressed: () {
                  final enterPinController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Enter PIN to Delete"),
                      content: TextField(
                        controller: enterPinController,
                        decoration: InputDecoration(
                          hintText: "Enter your 4-digit PIN",
                          prefixIcon: Icon(Icons.dialpad_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (enterPinController.text == doc['deletePin']) {
                              // 1. Start the deletion process
                              await _deleteItem(context, doc.id);

                              // 2. Close the PIN entry dialog
                              Navigator.pop(context);

                              // 3. Close the Contact/Detail dialog that was underneath it
                              // This returns the user directly to the Home Feed
                              // This pops everything until it hits the very first route (the Home Page)
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Post deleted and closed."),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Incorrect PIN!")),
                              );
                            }
                          },
                          child: Text("Verify & Delete"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Seller: ${doc['seller']}", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(
                "Contact Number:",
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                doc['contact'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF34A853),
                foregroundColor: Colors.white,
              ),
              child: Text("WhatsApp Now"),
              onPressed: () {
                // 1. Clean and format the phone number
                String phoneNumber = doc['contact'].replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                if (!phoneNumber.startsWith('91')) {
                  phoneNumber = '91$phoneNumber';
                }

                // 2. Create the WhatsApp URL string
                String url =
                    "https://wa.me/$phoneNumber?text=Hi, I am interested in your item: ${doc['title']}";

                // 3. USE THE WEB SHORTCUT (This skips the plugin error!)
                html.window.open(url, '_blank');

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inside your HomePage build method
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // Clean Google Grey background
      appBar: AppBar(
        title: Text(
          "Campus Connect",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: 'Campus Connect',
                children: [Text("By Visionary Variables")],
              ),
              child: Text(
                "ABOUT",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No items listed yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Be the first to help a junior!",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // GDG Accent Sidebar (Alternates colors)
                        Container(width: 6, color: _getGdgColor(index)),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Posted by ${doc['seller']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹${doc['price']}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF34A853),
                                      ),
                                    ), // Google Green
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(
                                          0xFF4285F4,
                                        ), // Google Blue
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _showContactDialog(context, doc),
                                      icon: Icon(
                                        Icons.chat_bubble_outline,
                                        size: 18,
                                      ),
                                      label: Text("Contact"),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostPage()),
        ),
        label: Text("List Item"),
        icon: Icon(Icons.add),
        backgroundColor: Color(0xFFEA4335), // Google Red
      ),
    );
  }
}
