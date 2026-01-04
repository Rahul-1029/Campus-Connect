import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert'; // For JSON
import 'package:http/http.dart' as http; // For Direct API Call
import '../api_key.dart'; // Keep your key file!

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

  // --- 1. RESTORED DESCRIPTION CONTROLLER ---
  final descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Categories (No Drafters)
  String selectedCategory = "Books";
  final List<String> categories = [
    "Books",
    "Electronics",
    "Lab Coat",
    "Tools",
    "Other",
  ];

  bool _isVerifying = false;
  bool _isGeneratingAI = false; // Spinner for AI
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- 2. THE DIRECT HTTP AI LOGIC (Reliable & Simple) ---
  Future<void> _generateDescription() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Title first!")),
      );
      return;
    }

    setState(() => _isGeneratingAI = true);

    try {
      // Clean key and prepare URL
      final cleanKey = geminiApiKey.trim();
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$cleanKey',
      );

      // The Prompt
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Write a short, catchy, 2-sentence sales description for a used '${titleController.text}' in the category '$selectedCategory' being sold by a student to another student. Be informal and persuasive.",
              },
            ],
          },
        ],
      });

      // The Call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          descriptionController.text = aiText;
          _isGeneratingAI = false;
        });
      } else {
        print("Google Error: ${response.body}");
        throw Exception("Failed to generate description");
      }
    } catch (e) {
      setState(() => _isGeneratingAI = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("AI Error: ${e.toString()}")));
    }
  }

  // --- EXISTING VERIFICATION LOGIC ---
  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);
    final email = emailController.text.trim();
    final pin = pinController.text.trim();
    final password = "mvgr$pin";

    try {
      User? user;
      try {
        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        user = cred.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
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
            Text("Link sent to:\n${user.email}", textAlign: TextAlign.center),
            const SizedBox(height: 15),
            const LinearProgressIndicator(),
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

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await user.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        timer.cancel();
        Navigator.pop(context);
        _uploadData();
      }
    });
  }

  Future<void> _uploadData() async {
    await FirebaseFirestore.instance.collection('listings').add({
      'title': titleController.text,
      'description': descriptionController.text, // --- SAVING DESCRIPTION ---
      'price': priceController.text,
      'contact': contactController.text,
      'seller': nameController.text,
      'email': emailController.text,
      'deletePin': pinController.text,
      'category': selectedCategory,
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
              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "College Email ID",
                  hintText: "rollnumber@mvgrce.edu.in",
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final email = value.toLowerCase().trim();
                  // Allow Gmail for testing + College Mail
                  if (!email.endsWith('@gmail.com') &&
                      !email.endsWith('@mvgrce.edu.in')) {
                    return 'Use @gmail.com or @mvgrce.edu.in';
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

              // CATEGORY
              DropdownButtonFormField<String>(
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

              // --- 3. TITLE & AI BUTTON ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Item Title",
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // AI BUTTON (Direct HTTP)
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade50,
                        foregroundColor: Colors.purple,
                        elevation: 0,
                        side: BorderSide(color: Colors.purple.shade100),
                      ),
                      onPressed: _isGeneratingAI ? null : _generateDescription,
                      icon: _isGeneratingAI
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: const Text("AI Write"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- 4. DESCRIPTION FIELD ---
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description (Auto-filled by AI)",
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Please add a description' : null,
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

              // SUBMIT BUTTON
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
