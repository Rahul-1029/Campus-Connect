import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_key.dart';

class NotificationService {
  // 1. SUBSCRIBE
  // Returns TRUE if subscribed successfully
  // Returns FALSE if already subscribed
  static Future<bool> subscribeToAlerts(String personalEmail) async {
    final email = personalEmail.trim().toLowerCase();

    final query = await FirebaseFirestore.instance
        .collection('subscribers')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('subscribers').add({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true; // Successfully subscribed
    } else {
      return false; // Already exists
    }
  }

  // 2. UNSUBSCRIBE
  // Returns TRUE if unsubscribed successfully
  // Returns FALSE if email was not found (not subscribed)
  static Future<bool> unsubscribeFromAlerts(String personalEmail) async {
    final email = personalEmail.trim().toLowerCase();

    final query = await FirebaseFirestore.instance
        .collection('subscribers')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isNotEmpty) {
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      return true; // Successfully deleted
    } else {
      return false; // Email not found
    }
  }

  // 3. NOTIFY (No changes here)
  static Future<void> sendNewPostAlert(String title, String category) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subscribers')
          .get();
      List<String> emails = snapshot.docs
          .map((d) => d['email'] as String)
          .toList();

      if (emails.isEmpty) return;

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

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
    } catch (e) {
      print("Notification Error: $e");
    }
  }
}
