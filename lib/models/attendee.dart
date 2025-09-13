import 'package:flutter/material.dart';

enum AttendeeType { adult, child }

class Attendee {
  final TextEditingController givenNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController passportNumberController = TextEditingController();
  AttendeeType type = AttendeeType.adult;

  // Method to dispose all controllers
  void dispose() {
    givenNameController.dispose();
    familyNameController.dispose();
    passportNumberController.dispose();
  }
}
