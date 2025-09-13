import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final double _adultTicketPrice = 23.5;
  final double _childTicketPrice = 2.5;

  TicketOrderNotifier()
      : super(TicketOrderState(
          attendees: [Attendee()],
          formKey: GlobalKey<FormState>(),
          customerEmailController: TextEditingController(),
        ));

  void addAttendee() {
    state = state.copyWith(attendees: [...state.attendees, Attendee()]);
  }

  void removeAttendee(int index) {
    // It's important to dispose controllers when they are removed
    state.attendees[index].givenNameController.dispose();
    state.attendees[index].familyNameController.dispose();
    
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
        // Payment successful
        state = state.copyWith(paymentStatus: PaymentStatus.success);
        await _sendConfirmationEmail();
        _resetForm();
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

  // Send confirmation email after successful payment
  Future<void> _sendConfirmationEmail() async {
    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = getTotalAmount();
    final String attendeesDetails = state.attendees.map((a) {
      final type = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      return '- ${a.givenNameController.text} ${a.familyNameController.text} ($type)';
    }).join('\n');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'chikuokuo@msn.com',
      query: _encodeQueryParameters({
        'subject': 'Ticket Order Confirmation - Neuschwanstein Castle',
        'body': '''
Hello,

Your payment has been successfully processed! Here are your ticket details:

Customer Email: ${state.customerEmailController.text}
Date: ${DateFormat('yyyy-MM-dd').format(state.selectedDate!)} (${state.selectedTimeSlot!.name.toUpperCase()})
Number of Tickets: ${state.attendees.length} (Adults: $adultCount, Children: $childCount)
Total Amount: €${totalAmount.toStringAsFixed(2)}

Attendees:
$attendeesDetails

Thank you for your purchase!
''',
      }),
    );

    await launchUrl(emailLaunchUri);
  }

  // Business logic for submitting is now cleanly separated from the UI
  Future<void> submitOrder() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    // Further validation for date and time slot can be done here.

    final int adultCount = state.attendees.where((a) => a.type == AttendeeType.adult).length;
    final int childCount = state.attendees.where((a) => a.type == AttendeeType.child).length;
    final double totalAmount = (adultCount * _adultTicketPrice) + (childCount * _childTicketPrice);
    final String attendeesDetails = state.attendees.map((a) {
      final type = a.type == AttendeeType.adult ? 'Adult' : 'Child';
      return '- ${a.givenNameController.text} ${a.familyNameController.text} ($type)';
    }).join('\n');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'chikuokuo@msn.com',
      query: _encodeQueryParameters({
        'subject': 'Ticket Order for Neuschwanstein Castle',
        'body': '''
Hello,

Here are my order details:
Customer Email: ${state.customerEmailController.text}
Date: ${DateFormat('yyyy-MM-dd').format(state.selectedDate!)} (${state.selectedTimeSlot!.name.toUpperCase()})
Number of Tickets: ${state.attendees.length} (Adults: $adultCount, Children: $childCount)
Total Amount: €$totalAmount
Attendees:
$attendeesDetails

Thank you.
''',
      }),
    );

    await launchUrl(emailLaunchUri);
    _resetForm();
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _resetForm() {
    state.formKey.currentState!.reset();
    state.customerEmailController.clear();

    // Dispose old controllers before creating a new list
    for (var attendee in state.attendees) {
      attendee.givenNameController.dispose();
      attendee.familyNameController.dispose();
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
      attendee.givenNameController.dispose();
      attendee.familyNameController.dispose();
    }
    state.customerEmailController.dispose();
    super.dispose();
  }
}

// 3. Creates a global provider to access the notifier
final ticketOrderProvider = StateNotifierProvider.autoDispose<TicketOrderNotifier, TicketOrderState>(
  (ref) => TicketOrderNotifier(),
);
