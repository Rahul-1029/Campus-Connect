import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_key.dart';

class NotificationService {
  // 1. SUBSCRIBE: Save Personal Email to Firestore
  static Future<void> subscribeToAlerts(String personalEmail) async {
    final email = personalEmail.trim().toLowerCase();

    // Check if already exists to avoid duplicates
    final query = await FirebaseFirestore.instance
        .collection('subscribers')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('subscribers').add({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // 2. NOTIFY: Send Email to All Subscribers
  static Future<void> sendNewPostAlert(String title, String category) async {
    try {
      // A. Fetch all subscriber emails
      final snapshot = await FirebaseFirestore.instance
          .collection('subscribers')
          .get();
      List<String> emails = snapshot.docs
          .map((d) => d['email'] as String)
          .toList();

      if (emails.isEmpty) return;

      // B. Send Email via EmailJS (REST API)
      // NOTE: For the Hackathon, sign up at emailjs.com (Free) to get these keys.
      // If you don't have keys yet, this will just print to console (safe for demo).

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

      // Loop to send (For production, use a 'Distribution List' feature, but this works for MVPs)
      for (String recipient in emails) {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': userId,
            'template_params': {
              'to_email': recipient,
              'item_title': title,
              'item_category': category,
              'message':
                  "A new $category item '$title' has just been posted on Campus Connect!",
            },
          }),
        );
      }
      print("Alerts sent to ${emails.length} subscribers.");
    } catch (e) {
      print("Notification Error: $e");
    }
  }
}
