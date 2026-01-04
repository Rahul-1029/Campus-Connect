import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // CATEGORY SETUP
  String selectedCategory = "Books";
  final List<String> categories = [
    "Books",
    "Electronics",
    "Lab Coat",
    "Tools",
    "Other",
  ];

  bool _isVerifying = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- THE REAL EMAIL VERIFICATION LOGIC ---
  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    final email = emailController.text.trim();
    final pin = pinController.text.trim();
    final password = "mvgr$pin"; // Create a secure password from their PIN

    try {
      User? user;
      try {
        // Try to create a new user
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        user = cred.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If user exists, log them in
          UserCredential cred = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          user = cred.user;
        } else {
          throw e;
        }
      }

      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          _showVerificationDialog(user);
        } else {
          // If they verified in a previous session, just post immediately
          _uploadData();
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _showVerificationDialog(User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verify College Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              "Verification link sent to:\n${user.email}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            const Text(
              "Please click the link in your inbox...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
              setState(() => _isVerifying = false);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    // Poll every 3 seconds to check if they clicked the link
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await user.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        timer.cancel();
        Navigator.pop(context); // Close dialog
        _uploadData(); // Proceed to upload
      }
    });
  }

  Future<void> _uploadData() async {
    await FirebaseFirestore.instance.collection('listings').add({
      'title': titleController.text,
      'price': priceController.text,
      'contact': contactController.text,
      'seller': nameController.text,
      'email': emailController.text,
      'deletePin': pinController.text,
      'category': selectedCategory, // SAVING CATEGORY
      'isVerified': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verified & Posted!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List an Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // EMAIL FIELD (With @mvgrce.edu.in Check)
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "College Email ID",
                  hintText: "rollnumber@mvgrce.edu.in",
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!value.toLowerCase().trim().endsWith('@mvgrce.edu.in')) {
                    return 'Must use @mvgrce.edu.in email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // CATEGORY DROPDOWN
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              const SizedBox(height: 10),

              // TITLE
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Item Title",
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // PRICE
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Price (₹)",
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // CONTACT
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: "WhatsApp Number",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? 'Invalid number' : null,
              ),
              const SizedBox(height: 20),

              // PIN
              TextFormField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: "Create 4-Digit PIN",
                  prefixIcon: Icon(Icons.dialpad),
                  helperText: "Used for deleting & verifying",
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (v) => v!.length != 4 ? 'Must be 4 digits' : null,
              ),
              const SizedBox(height: 20),

              // BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _isVerifying
                      ? Colors.grey
                      : Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isVerifying ? null : _handlePost,
                child: Text(_isVerifying ? "Checking..." : "Verify & Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
