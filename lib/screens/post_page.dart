import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- POST PAGE (The Form) ---
class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final contactController = TextEditingController();
  final nameController = TextEditingController();
  final pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for identifying the form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("List an Item")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              // 1. Wrap content in a Form widget
              key: _formKey,
              child: Column(
                children: [
                  // --- Name Field with Validator ---
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Your Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // --- Title Field with Validator ---
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Book/Tool Name",
                      prefixIcon: Icon(Icons.book),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the item name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // --- Price Field with Validator ---
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: "Price (₹)",
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // --- Contact Field with Validator ---
                  TextFormField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: "WhatsApp Number",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your number';
                      }
                      if (value.length < 10) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // --- PIN Field with Validator ---
                  TextFormField(
                    controller: pinController,
                    decoration: InputDecoration(
                      labelText: "Create a 4-Digit Delete PIN",
                      prefixIcon: Icon(Icons.dialpad, color: Color(0xFF4285F4)),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please create a PIN';
                      }
                      if (value.length != 4) {
                        return 'PIN must be exactly 4 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Post to Campus"),
                    onPressed: () async {
                      // 2. Trigger validation check before adding to Firebase
                      if (_formKey.currentState!.validate()) {
                        await FirebaseFirestore.instance
                            .collection('listings')
                            .add({
                              'title': titleController.text,
                              'price': priceController.text,
                              'contact': contactController.text,
                              'seller': nameController.text,
                              'deletePin': pinController.text,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
