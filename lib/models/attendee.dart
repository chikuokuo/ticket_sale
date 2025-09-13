import 'package:flutter/material.dart';

enum AttendeeType { adult, child }

class Attendee {
  final TextEditingController givenNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  AttendeeType type = AttendeeType.adult;
}
