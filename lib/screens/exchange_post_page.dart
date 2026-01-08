import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart'; // Ensure this path is correct for your project

class ExchangePostPage extends StatefulWidget {
  const ExchangePostPage({super.key});

  @override
  _ExchangePostPageState createState() => _ExchangePostPageState();
}

class _ExchangePostPageState extends State<ExchangePostPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleController = TextEditingController(); // Book Name
  final authorController = TextEditingController(); // Author/Edition
  final wantController = TextEditingController(); // What they want in return
  final contactController = TextEditingController();
  final pinController = TextEditingController();
  
  // AI Description
  final descriptionController = TextEditingController();
  bool _isGeneratingAI = false;
  bool _isSubmitting = false;

  // --- AI DESCRIPTION GENERATOR ---
  Future<void> _generateDescription() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter Book Title first!")),
      );
      return;
    }

    setState(() => _isGeneratingAI = true);

    try {
      final cleanKey = geminiApiKey.trim();
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$cleanKey',
      );

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Write a 2-sentence description for a student trading the book '${titleController.text}'. Mention it's available for exchange. Be casual.",
              },
            ],
          },
        ],
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          descriptionController.text = aiText;
          _isGeneratingAI = false;
        });
      } else {
        throw Exception("Failed to generate");
      }
    } catch (e) {
      setState(() => _isGeneratingAI = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI Error: ${e.toString()}")),
      );
    }
  }

  // --- SUBMIT FUNCTION ---
  Future<void> _submitExchange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('book_exchange').add({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'exchange_with': wantController.text.trim(), // specific to exchange
        'description': descriptionController.text.trim(),
        'contact': contactController.text.trim(),
        'deletePin': pinController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'Exchange', // Helper for UI
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book Listed for Exchange!")),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exchange a Book"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.import_contacts_rounded,
                  size: 60, color: Colors.teal),
              const SizedBox(height: 20),

              // BOOK TITLE
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Book Title",
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // AUTHOR
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: "Author / Edition",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // WANTS
              TextFormField(
                controller: wantController,
                decoration: const InputDecoration(
                  labelText: "Willing to exchange for...",
                  hintText: "e.g. 'Data Structures book' or 'Any Novel'",
                  prefixIcon: Icon(Icons.swap_horiz),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // DESCRIPTION + AI
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _isGeneratingAI ? null : _generateDescription,
                        icon: _isGeneratingAI
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        color: Colors.purple,
                      ),
                      const Text("AI Help", style: TextStyle(fontSize: 10)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),

              // CONTACT
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: "WhatsApp Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? 'Invalid number' : null,
              ),
              const SizedBox(height: 15),

              // PIN
              TextFormField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: "Create 4-Digit PIN",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (v) => v!.length != 4 ? 'Must be 4 digits' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSubmitting ? null : _submitExchange,
                child: Text(_isSubmitting ? "Posting..." : "List Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}