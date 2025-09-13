import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/attendee.dart';
import '../models/time_slot.dart';

// 1. Defines the state of the ticket order form
@immutable
class TicketOrderState {
  final List<Attendee> attendees;
  final DateTime? selectedDate;
  final TimeSlot? selectedTimeSlot;
  final GlobalKey<FormState> formKey;
  final TextEditingController customerEmailController;
  final TextEditingController lastFiveDigitsController;

  const TicketOrderState({
    required this.attendees,
    this.selectedDate,
    this.selectedTimeSlot,
    required this.formKey,
    required this.customerEmailController,
    required this.lastFiveDigitsController,
  });

  // Allows creating a copy of the state with modified fields
  TicketOrderState copyWith({
    List<Attendee>? attendees,
    DateTime? selectedDate,
    TimeSlot? selectedTimeSlot,
  }) {
    return TicketOrderState(
      attendees: attendees ?? this.attendees,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      formKey: formKey, // controllers and key are not copied
      customerEmailController: customerEmailController,
      lastFiveDigitsController: lastFiveDigitsController,
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
          lastFiveDigitsController: TextEditingController(),
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
Last 5 digits of bank account: ${state.lastFiveDigitsController.text}

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
    state.lastFiveDigitsController.clear();
    
    // Dispose old controllers before creating a new list
    for (var attendee in state.attendees) {
      attendee.givenNameController.dispose();
      attendee.familyNameController.dispose();
    }
    
    state = state.copyWith(
      attendees: [Attendee()],
      selectedDate: null,
      selectedTimeSlot: null,
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
    state.lastFiveDigitsController.dispose();
    super.dispose();
  }
}

// 3. Creates a global provider to access the notifier
final ticketOrderProvider = StateNotifierProvider.autoDispose<TicketOrderNotifier, TicketOrderState>(
  (ref) => TicketOrderNotifier(),
);
