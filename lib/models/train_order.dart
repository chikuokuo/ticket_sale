import 'package:flutter/material.dart';
import 'train_trip.dart';
import 'train_passenger.dart';
import 'train_station.dart';

class TrainSearchCriteria {
  final TrainStation? fromStation;
  final TrainStation? toStation;
  final DateTime? departureDate;
  final String? departureTime; // Time in HH:mm format
  final DateTime? returnDate; // For return trips (optional)
  final String? returnTime; // Time in HH:mm format for return trips
  final int adultCount;
  final int childCount;
  final bool isRoundTrip;

  const TrainSearchCriteria({
    this.fromStation,
    this.toStation,
    this.departureDate,
    this.departureTime,
    this.returnDate,
    this.returnTime,
    this.adultCount = 1,
    this.childCount = 0,
    this.isRoundTrip = false,
  });

  bool get isValid {
    return fromStation != null &&
           toStation != null &&
           fromStation != toStation &&
           departureDate != null &&
           (adultCount + childCount) > 0 &&
           (!isRoundTrip || returnDate != null);
  }

  int get totalPassengers => adultCount + childCount;

  TrainSearchCriteria copyWith({
    TrainStation? fromStation,
    TrainStation? toStation,
    DateTime? departureDate,
    String? departureTime,
    DateTime? returnDate,
    String? returnTime,
    int? adultCount,
    int? childCount,
    bool? isRoundTrip,
  }) {
    return TrainSearchCriteria(
      fromStation: fromStation ?? this.fromStation,
      toStation: toStation ?? this.toStation,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
    );
  }
}

class TrainOrder {
  final String id;
  final TrainTrip selectedTrip;
  final TrainTrip? returnTrip; // For round trips
  final List<TrainPassenger> passengers;
  final TextEditingController contactEmailController;
  final DateTime createdAt;
  
  TrainOrder({
    required this.id,
    required this.selectedTrip,
    this.returnTrip,
    required this.passengers,
  }) : contactEmailController = TextEditingController(),
       createdAt = DateTime.now();

  String get contactEmail => contactEmailController.text.trim();
  
  bool get isValid {
    return passengers.isNotEmpty &&
           passengers.every((p) => p.isValid) &&
           contactEmail.isNotEmpty &&
           _isValidEmail(contactEmail);
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  double get totalAmount {
    double total = 0.0;
    
    // Calculate outbound trip cost
    for (final passenger in passengers) {
      total += selectedTrip.getPriceForClass(passenger.ticketClass);
    }
    
    // Calculate return trip cost if applicable
    if (returnTrip != null) {
      for (final passenger in passengers) {
        total += returnTrip!.getPriceForClass(passenger.ticketClass);
      }
    }
    
    return total;
  }

  Map<TicketClass, int> get ticketClassCounts {
    final counts = <TicketClass, int>{};
    for (final passenger in passengers) {
      counts[passenger.ticketClass] = (counts[passenger.ticketClass] ?? 0) + 1;
    }
    return counts;
  }

  List<TrainPassenger> get adultPassengers {
    return passengers.where((p) => p.type == PassengerType.adult).toList();
  }

  List<TrainPassenger> get childPassengers {
    return passengers.where((p) => p.type == PassengerType.child).toList();
  }

  void dispose() {
    contactEmailController.dispose();
    for (final passenger in passengers) {
      passenger.dispose();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'selectedTrip': {
        'id': selectedTrip.id,
        'trainNumber': selectedTrip.trainNumber,
        'trainType': selectedTrip.trainType.name,
        'fromStation': selectedTrip.fromStation.name,
        'toStation': selectedTrip.toStation.name,
        'departureTime': selectedTrip.departureTime.toIso8601String(),
        'arrivalTime': selectedTrip.arrivalTime.toIso8601String(),
      },
      'returnTrip': returnTrip != null ? {
        'id': returnTrip!.id,
        'trainNumber': returnTrip!.trainNumber,
        'trainType': returnTrip!.trainType.name,
        'fromStation': returnTrip!.fromStation.name,
        'toStation': returnTrip!.toStation.name,
        'departureTime': returnTrip!.departureTime.toIso8601String(),
        'arrivalTime': returnTrip!.arrivalTime.toIso8601String(),
      } : null,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'contactEmail': contactEmail,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
