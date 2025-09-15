import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum WebhookType {
  ticket,    // 城堡跟博物館
  bundle,    // 套票
  railPass   // 通票
}

class WebhookService {
  static const Map<WebhookType, String> _webhookUrls = {
    WebhookType.ticket: 'https://dream-ticket.app.n8n.cloud/webhook/ae7619b9-fbb4-496f-8876-ec5443de6b4b',
    WebhookType.bundle: 'https://dream-ticket.app.n8n.cloud/webhook/ff58da01-814c-436e-96f9-32f0dc19d1fd',
    WebhookType.railPass: 'https://dream-ticket.app.n8n.cloud/webhook/790b561b-9a44-4b3d-89a2-8d879f058493',
  };

  Future<void> sendTicketOrder({
    required String customerEmail,
    required DateTime orderDate,
    required String session, // 'morning' or 'afternoon'
    required int totalTickets,
    required int adults,
    required int children,
    required double totalAmount,
    required String bankAccountLast5,
    required List<Map<String, dynamic>> attendees,
  }) async {
    final data = {
      'customerEmail': customerEmail,
      'orderDate': DateFormat('yyyy-MM-dd').format(orderDate),
      'session': session,
      'tickets': {
        'total': totalTickets,
        'adults': adults,
        'children': children,
      },
      'totalAmount': {
        'value': totalAmount,
        'currency': 'EUR',
      },
      'bankAccount': {
        'last5': bankAccountLast5,
      },
      'attendees': attendees,
    };

    await _sendWebhook(WebhookType.ticket, data);
  }

  Future<void> sendBundleOrder({
    required String customerEmail,
    required String ticketId,
    required String tourName,
    required DateTime orderDate,
    required List<Map<String, dynamic>> attendees,
  }) async {
    final data = {
      'customerEmail': customerEmail,
      'ticketId': ticketId,
      'tourName': tourName,
      'orderDate': DateFormat('yyyy-MM-dd').format(orderDate),
      'attendees': attendees,
    };

    await _sendWebhook(WebhookType.bundle, data);
  }

  Future<void> sendRailPassOrder({
    required String customerEmail,
    required String customerAddress,
    required String ticketName,
    required String days,
    required List<Map<String, dynamic>> attendees,
    required String bankAccountLast5,
  }) async {
    final data = {
      'customerEmail': customerEmail,
      'customerAddress': customerAddress,
      'ticketName': ticketName,
      'days': days,
      'attendees': attendees,
      'bankAccount': {
        'last5': bankAccountLast5,
      },
    };

    await _sendWebhook(WebhookType.railPass, data);
  }

  Future<void> _sendWebhook(WebhookType type, Map<String, dynamic> data) async {
    final url = _webhookUrls[type];
    if (url == null) {
      throw Exception('Webhook URL not found for type: $type');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Webhook call failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send webhook: $e');
    }
  }
}