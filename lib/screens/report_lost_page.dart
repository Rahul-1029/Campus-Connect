import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportLostPage extends StatefulWidget {
  const ReportLostPage({super.key});

  @override
  _ReportLostPageState createState() => _ReportLostPageState();
}

class _ReportLostPageState extends State<ReportLostPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController(); // <--- NEW CONTROLLER
  final locationController = TextEditingController();
  final contactController = TextEditingController();
  final pinController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('lost_found').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(), // <--- SAVING IT
        'location': locationController.text.trim(),
        'contact': contactController.text.trim(),
        'deletePin': pinController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isFound': false,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Reported Successfully!")));
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Lost Item"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.campaign_rounded,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),

              // TITLE
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Item Name (e.g. Blue Wallet)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // DESCRIPTION (NEW)
              TextFormField(
                controller: descriptionController,
                maxLines: 3, // Taller box
                decoration: const InputDecoration(
                  labelText: "Description (Color, scratches, brand...)",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description),
                  ),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Please describe the item' : null,
              ),
              const SizedBox(height: 15),

              // LOCATION
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Last Seen Location",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin_drop),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),

              // CONTACT
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: "WhatsApp Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
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
                  helperText: "For deleting later",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (v) => v!.length != 4 ? 'Must be 4 digits' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: Text(_isSubmitting ? "Submitting..." : "Report Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
