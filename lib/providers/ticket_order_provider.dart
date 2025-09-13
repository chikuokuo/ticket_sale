import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';
import '../services/stripe_service.dart';

// 1. Defines the state of the ticket order form
@immutable
class TicketOrderState {
  final List<Attendee> attendees;
  final DateTime? selectedDate;
  final TimeSlot? selectedTimeSlot;
  final GlobalKey<FormState> formKey;
  final TextEditingController customerEmailController;
  final PaymentStatus paymentStatus;
  final String? paymentError;

  const TicketOrderState({
    required this.attendees,
    this.selectedDate,
    this.selectedTimeSlot,
    required this.formKey,
    required this.customerEmailController,
    this.paymentStatus = PaymentStatus.idle,
    this.paymentError,
  });

  // Allows creating a copy of the state with modified fields
  TicketOrderState copyWith({
    List<Attendee>? attendees,
    DateTime? selectedDate,
    TimeSlot? selectedTimeSlot,
    PaymentStatus? paymentStatus,
    String? paymentError,
    bool clearDate = false,
    bool clearTimeSlot = false,
    bool clearPaymentError = false,
  }) {
    return TicketOrderState(
      attendees: attendees ?? this.attendees,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedTimeSlot: clearTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      formKey: formKey, // controllers and key are not copied
      customerEmailController: customerEmailController,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentError: clearPaymentError ? null : (paymentError ?? this.paymentError),
    );
  }
}

// 2. Manages the state and business logic
class TicketOrderNotifier extends StateNotifier<TicketOrderState> {
  final double _adultTicketPrice = 21.0;
  final double _childTicketPrice = 0.0;

  TicketOrderNotifier()
      : super(TicketOrderState(
          attendees: [Attendee()],
          formKey: GlobalKey<FormState>(),
          customerEmailController: TextEditingController(),
        ));

  void addAttendee([AttendeeType? type]) {
    final newAttendee = Attendee();
    if (type != null) {
      newAttendee.type = type;
    }
    state = state.copyWith(attendees: [...state.attendees, newAttendee]);
  }

  void removeAttendee(int index) {
    // It's important to dispose controllers when they are removed
    state.attendees[index].dispose();
    
    final newAttendees = List<Attendee>.from(state.attendees)..removeAt(index);
    state = state.copyWith(attendees: newAttendees);
  }
  
  void updateAttendeeType(int index, AttendeeType newType) {
    final newAttendees = List<Attendee>.from(state.attendees);
    newAttendees[index].type = newType;
    state = state.copyWith(attendees: newAttendees);
  }

  void selectDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTimeSlot(TimeSlot? timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  // Calculate total amount
  double getTotalAmount() {
    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    return (adultCount * _adultTicketPrice) + (childCount * _childTicketPrice);
  }

  // Process payment with Stripe
  Future<void> processPayment(BuildContext context) async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }

    // Set payment status to processing
    state = state.copyWith(
      paymentStatus: PaymentStatus.processing,
      clearPaymentError: true,
    );

    try {
      final stripeService = StripeService();
      final totalAmount = getTotalAmount();

      final result = await stripeService.processPayment(
        context: context,
        amount: totalAmount,
        currency: 'eur',
        customerEmail: state.customerEmailController.text,
        metadata: {
          'date': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
          'time_slot': state.selectedTimeSlot!.name.toUpperCase(),
          'attendee_count': state.attendees.length.toString(),
        },
      );

      if (result.status == PaymentStatus.success) {
        // Payment successful - submit to n8n webhook
        state = state.copyWith(paymentStatus: PaymentStatus.success);
        try {
          await _submitToWebhook();
          _resetForm();
        } catch (e) {
          // If webhook submission fails, update payment status to failed
          state = state.copyWith(
            paymentStatus: PaymentStatus.failed,
            paymentError: 'Payment successful but failed to submit order: $e',
          );
        }
      } else {
        // Payment failed
        state = state.copyWith(
          paymentStatus: PaymentStatus.failed,
          paymentError: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        paymentStatus: PaymentStatus.failed,
        paymentError: 'An unexpected error occurred: $e',
      );
    }
  }

  // Submit order to n8n webhook after successful payment
  Future<void> _submitToWebhook() async {
    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = getTotalAmount();

    // Transform attendees data
    final List<Map<String, String>> attendeesData = state.attendees.map((a) {
      final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
      return {
        'name': fullName,
        'ticketType': ticketType,
      };
    }).toList();

    // Prepare JSON data for n8n webhook
    final Map<String, dynamic> webhookData = {
      'customerEmail': state.customerEmailController.text,
      'orderDate': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
      'session': state.selectedTimeSlot == TimeSlot.am ? 'morning' : 'afternoon',
      'tickets': {
        'total': state.attendees.length,
        'adults': adultCount,
        'children': childCount,
      },
      'totalAmount': {
        'value': totalAmount,
        'currency': 'EUR',
      },
      'bankAccount': {
        'last5': '12345', // Extract last 5 digits from "1234-5678-9999"
      },
      'attendees': attendeesData,
    };

    try {
      // Send POST request to n8n webhook
      final response = await http.post(
        Uri.parse('https://dream-ticket.app.n8n.cloud/webhook/ae7619b9-fbb4-496f-8876-ec5443de6b4b'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(webhookData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Error - webhook call failed
        throw Exception('Webhook call failed with status: ${response.statusCode}');
      }
      // Success - webhook received the data, no need to do anything extra here
    } catch (e) {
      // Rethrow the error to be handled by the caller
      throw Exception('Failed to submit order to webhook: $e');
    }
  }


  // Business logic for submitting is now cleanly separated from the UI
  Future<void> submitOrder() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    // Further validation for date and time slot can be done here.

    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = getTotalAmount();

    // Transform attendees data
    final List<Map<String, String>> attendeesData = state.attendees.map((a) {
      final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
      return {
        'name': fullName,
        'ticketType': ticketType,
      };
    }).toList();

    // Prepare JSON data for n8n webhook
    final Map<String, dynamic> webhookData = {
      'customerEmail': state.customerEmailController.text,
      'orderDate': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
      'session': state.selectedTimeSlot == TimeSlot.am ? 'morning' : 'afternoon',
      'tickets': {
        'total': state.attendees.length,
        'adults': adultCount,
        'children': childCount,
      },
      'totalAmount': {
        'value': totalAmount,
        'currency': 'EUR',
      },
      'bankAccount': {
        'last5': '12345', // Extract last 5 digits from "1234-5678-9999"
      },
      'attendees': attendeesData,
    };

    try {
      // Send POST request to n8n webhook
      final response = await http.post(
        Uri.parse('https://dream-ticket.app.n8n.cloud/webhook/ae7619b9-fbb4-496f-8876-ec5443de6b4b'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(webhookData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - webhook received the data
        _resetForm();
      } else {
        // Error - webhook call failed
        throw Exception('Webhook call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Rethrow the error to be handled by the UI
      throw Exception('Failed to submit order: $e');
    }
  }


  void _resetForm() {
    state.formKey.currentState!.reset();
    state.customerEmailController.clear();

    // Dispose old controllers before creating a new list
    for (var attendee in state.attendees) {
      attendee.dispose();
    }

    state = state.copyWith(
      attendees: [Attendee()],
      paymentStatus: PaymentStatus.idle,
      clearDate: true,
      clearTimeSlot: true,
      clearPaymentError: true,
    );
  }

  @override
  void dispose() {
    // Dispose all controllers when the notifier is disposed
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state.customerEmailController.dispose();
    super.dispose();
  }
}

// 3. Creates a global provider to access the notifier
final ticketOrderProvider = StateNotifierProvider.autoDispose<TicketOrderNotifier, TicketOrderState>(
  (ref) => TicketOrderNotifier(),
);
