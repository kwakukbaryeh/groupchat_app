import 'package:http/http.dart' as http;

class NotificationService {
  static const String _cloudFunctionURL =
      'https://sendnotificationtouser-fbm2eqbq6q-uc.a.run.app'; // Replace with your Cloud Function URL

  static Future<void> sendNotificationToUser(String userId) async {
    final response = await http.post(
      Uri.parse(_cloudFunctionURL),
      body: {'userId': userId},
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Error sending notification: ${response.body}');
    }
  }
}
