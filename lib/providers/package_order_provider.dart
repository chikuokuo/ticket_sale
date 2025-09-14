import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/attendee.dart';

enum SubmissionStatus { idle, processing, success, failed }

@immutable
class PackageOrderState {
  final List<Attendee> attendees;
  final DateTime? selectedDate;
  final GlobalKey<FormState> formKey;
  final TextEditingController customerEmailController;
  final SubmissionStatus submissionStatus;
  final String? submissionError;

  const PackageOrderState({
    required this.attendees,
    this.selectedDate,
    required this.formKey,
    required this.customerEmailController,
    this.submissionStatus = SubmissionStatus.idle,
    this.submissionError,
  });

  PackageOrderState copyWith({
    List<Attendee>? attendees,
    DateTime? selectedDate,
    SubmissionStatus? submissionStatus,
    String? submissionError,
    bool clearDate = false,
    bool clearSubmissionError = false,
  }) {
    return PackageOrderState(
      attendees: attendees ?? this.attendees,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      formKey: formKey,
      customerEmailController: customerEmailController,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionError: clearSubmissionError ? null : (submissionError ?? this.submissionError),
    );
  }
}

class PackageOrderNotifier extends StateNotifier<PackageOrderState> {
  PackageOrderNotifier()
      : super(PackageOrderState(
          attendees: [Attendee()],
          formKey: GlobalKey<FormState>(),
          customerEmailController: TextEditingController(),
        ));

  void addAttendee() {
    state = state.copyWith(attendees: [...state.attendees, Attendee()]);
  }

  void removeAttendee(int index) {
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

  Future<void> submitPackageOrder() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    
    // UI engineer should ensure a date is selected before calling this.
    if (state.selectedDate == null) {
        state = state.copyWith(
            submissionStatus: SubmissionStatus.failed,
            submissionError: 'Please select a date.'
        );
        return;
    }

    state = state.copyWith(
      submissionStatus: SubmissionStatus.processing,
      clearSubmissionError: true,
    );

    try {
      final List<Map<String, String>> attendeesData = state.attendees.map((a) {
        final ticketType = a.type == AttendeeType.adult ? 'Adult' : 'Child';
        final fullName = '${a.givenNameController.text} ${a.familyNameController.text}'.trim();
        return {'name': fullName, 'ticketType': ticketType};
      }).toList();

      final Map<String, dynamic> packageData = {
        'ticketId': 'TR__22697P8',
        'tourName': 'TXXXXXXXX',
        'customerEmail': state.customerEmailController.text,
        'orderDate': DateFormat('yyyy-MM-dd').format(state.selectedDate!),
        'attendees': attendeesData,
      };

      final response = await http.post(
        // IMPORTANT: Please replace with the correct n8n webhook URL for package orders.
        Uri.parse('https://dream-ticket.app.n8n.cloud/webhook/ae7619b9-fbb4-496f-8876-ec5443de6b4b'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(packageData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(submissionStatus: SubmissionStatus.success);
        _resetForm();
      } else {
        throw Exception('Webhook call failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      state = state.copyWith(
        submissionStatus: SubmissionStatus.failed,
        submissionError: e.toString(),
      );
    }
  }

  void _resetForm() {
    state.formKey.currentState?.reset();
    state.customerEmailController.clear();
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state = state.copyWith(
      attendees: [Attendee()],
      submissionStatus: SubmissionStatus.idle,
      clearDate: true,
      clearSubmissionError: true,
    );
  }

  @override
  void dispose() {
    for (var attendee in state.attendees) {
      attendee.dispose();
    }
    state.customerEmailController.dispose();
    super.dispose();
  }
}

final packageOrderProvider = StateNotifierProvider.autoDispose<PackageOrderNotifier, PackageOrderState>(
  (ref) => PackageOrderNotifier(),
);
