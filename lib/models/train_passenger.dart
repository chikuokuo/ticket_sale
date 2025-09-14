import 'package:flutter/material.dart';
import 'train_trip.dart';

enum PassengerType {
  adult,
  child,
}

extension PassengerTypeExtension on PassengerType {
  String get displayName {
    switch (this) {
      case PassengerType.adult:
        return 'Adult';
      case PassengerType.child:
        return 'Child';
    }
  }
}

class TrainPassenger {
  final String id;
  final PassengerType type;
  final TicketClass ticketClass;
  final TextEditingController givenNameController;
  final TextEditingController familyNameController;
  final TextEditingController passportNumberController;
  DateTime? birthDate;
  
  TrainPassenger({
    required this.id,
    required this.type,
    required this.ticketClass,
  }) : givenNameController = TextEditingController(),
       familyNameController = TextEditingController(), 
       passportNumberController = TextEditingController();

  String get givenName => givenNameController.text.trim();
  String get familyName => familyNameController.text.trim();
  String get passportNumber => passportNumberController.text.trim();
  String get fullName => '$givenName $familyName'.trim();

  bool get isValid {
    return givenName.isNotEmpty && 
           familyName.isNotEmpty && 
           passportNumber.isNotEmpty &&
           birthDate != null;
  }
  
  String get formattedBirthDate {
    if (birthDate == null) return '';
    return '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}';
  }

  void dispose() {
    givenNameController.dispose();
    familyNameController.dispose();
    passportNumberController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'ticketClass': ticketClass.name,
      'givenName': givenName,
      'familyName': familyName,
      'passportNumber': passportNumber,
      'birthDate': birthDate?.toIso8601String(),
    };
  }
}
