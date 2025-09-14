import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/train_station.dart';
import '../models/train_trip.dart';
import '../models/train_passenger.dart';
import '../models/train_order.dart';
import '../services/stripe_service.dart';
import '../services/train_api_service.dart';

class TrainOrderState {
  final TrainSearchCriteria searchCriteria;
  final List<TrainTrip> searchResults;
  final TrainTrip? selectedTrip;
  final TrainTrip? selectedReturnTrip;
  final List<TrainPassenger> passengers;
  final String contactEmail;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? rawApiResponse;
  final bool showApiResponse;

  const TrainOrderState({
    this.searchCriteria = const TrainSearchCriteria(),
    this.searchResults = const [],
    this.selectedTrip,
    this.selectedReturnTrip,
    this.passengers = const [],
    this.contactEmail = '',
    this.isLoading = false,
    this.errorMessage,
    this.rawApiResponse,
    this.showApiResponse = false,
  });

  TrainOrderState copyWith({
    TrainSearchCriteria? searchCriteria,
    List<TrainTrip>? searchResults,
    TrainTrip? selectedTrip,
    TrainTrip? selectedReturnTrip,
    List<TrainPassenger>? passengers,
    String? contactEmail,
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? rawApiResponse,
    bool? showApiResponse,
  }) {
    return TrainOrderState(
      searchCriteria: searchCriteria ?? this.searchCriteria,
      searchResults: searchResults ?? this.searchResults,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      selectedReturnTrip: selectedReturnTrip ?? this.selectedReturnTrip,
      passengers: passengers ?? this.passengers,
      contactEmail: contactEmail ?? this.contactEmail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      rawApiResponse: rawApiResponse ?? this.rawApiResponse,
      showApiResponse: showApiResponse ?? this.showApiResponse,
    );
  }

  double get totalAmount {
    if (selectedTrip == null || passengers.isEmpty) return 0.0;
    
    double total = 0.0;
    
    // Calculate outbound trip cost
    for (final passenger in passengers) {
      total += selectedTrip!.getPriceForClass(passenger.ticketClass);
    }
    
    // Calculate return trip cost if applicable
    if (selectedReturnTrip != null) {
      for (final passenger in passengers) {
        total += selectedReturnTrip!.getPriceForClass(passenger.ticketClass);
      }
    }
    
    return total;
  }

  bool get canProceedToSearch {
    return searchCriteria.isValid;
  }

  bool get canProceedToPassengerDetails {
    return selectedTrip != null;
  }

  bool get canProceedToSummary {
    return selectedTrip != null &&
           passengers.isNotEmpty &&
           passengers.every((p) => p.isValid) &&
           contactEmail.isNotEmpty &&
           _isValidEmail(contactEmail);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class TrainOrderNotifier extends StateNotifier<TrainOrderState> {
  TrainOrderNotifier() : super(const TrainOrderState());

  // Search functionality
  void updateSearchCriteria(TrainSearchCriteria criteria) {
    state = state.copyWith(
      searchCriteria: criteria,
      searchResults: [],
      selectedTrip: null,
      selectedReturnTrip: null,
      passengers: [],
      errorMessage: null,
    );
  }

  void setFromStation(TrainStation? station) {
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(fromStation: station),
    );
  }

  void setToStation(TrainStation? station) {
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(toStation: station),
    );
  }

  void swapStations() {
    final from = state.searchCriteria.fromStation;
    final to = state.searchCriteria.toStation;
    
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(
        fromStation: to,
        toStation: from,
      ),
    );
  }

  void setDepartureDate(DateTime? date) {
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(departureDate: date),
    );
  }

  void setReturnDate(DateTime? date) {
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(returnDate: date),
    );
  }

  void setPassengerCount({int? adults, int? children}) {
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(
        adultCount: adults ?? state.searchCriteria.adultCount,
        childCount: children ?? state.searchCriteria.childCount,
      ),
    );
  }

  void setRoundTrip(bool isRoundTrip) {
    state = state.copyWith(
      searchCriteria: state.searchCriteria.copyWith(
        isRoundTrip: isRoundTrip,
        returnDate: isRoundTrip ? state.searchCriteria.returnDate : null,
      ),
    );
  }

  Future<void> searchTrains() async {
    if (!state.searchCriteria.isValid) {
      state = state.copyWith(errorMessage: 'Please fill in all required fields');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Use real G2Rail API
      final searchResult = await TrainApiService.instance.searchTrains(
        fromStation: state.searchCriteria.fromStation!,
        toStation: state.searchCriteria.toStation!,
        departureDate: state.searchCriteria.departureDate!,
        adultCount: state.searchCriteria.adultCount,
        childCount: state.searchCriteria.childCount,
      );

      state = state.copyWith(
        searchResults: searchResult.trips,
        rawApiResponse: searchResult.rawApiResponse,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to search trains: ${e.toString()}',
      );
    }
  }

  // Trip selection
  void selectTrip(TrainTrip trip) {
    state = state.copyWith(
      selectedTrip: trip,
      passengers: [], // Reset passengers when trip changes
    );
    _generatePassengers();
  }

  void selectReturnTrip(TrainTrip? trip) {
    state = state.copyWith(selectedReturnTrip: trip);
  }

  // Passenger management
  void _generatePassengers() {
    final passengers = <TrainPassenger>[];
    
    // Add adult passengers
    for (int i = 0; i < state.searchCriteria.adultCount; i++) {
      passengers.add(TrainPassenger(
        id: 'adult_$i',
        type: PassengerType.adult,
        ticketClass: TicketClass.second, // Default to 2nd class
      ));
    }
    
    // Add child passengers  
    for (int i = 0; i < state.searchCriteria.childCount; i++) {
      passengers.add(TrainPassenger(
        id: 'child_$i',
        type: PassengerType.child,
        ticketClass: TicketClass.second, // Default to 2nd class
      ));
    }
    
    state = state.copyWith(passengers: passengers);
  }

  void updatePassengerTicketClass(String passengerId, TicketClass ticketClass) {
    final updatedPassengers = state.passengers.map((passenger) {
      if (passenger.id == passengerId) {
        return TrainPassenger(
          id: passenger.id,
          type: passenger.type,
          ticketClass: ticketClass,
        )..givenNameController.text = passenger.givenName
        ..familyNameController.text = passenger.familyName
        ..passportNumberController.text = passenger.passportNumber
        ..birthDate = passenger.birthDate;
      }
      return passenger;
    }).toList();

    state = state.copyWith(passengers: updatedPassengers);
  }

  void updatePassengerBirthDate(String passengerId, DateTime? birthDate) {
    final passengers = [...state.passengers];
    final index = passengers.indexWhere((p) => p.id == passengerId);
    if (index != -1) {
      passengers[index].birthDate = birthDate;
      state = state.copyWith(passengers: passengers);
    }
  }

  void setContactEmail(String email) {
    state = state.copyWith(contactEmail: email);
  }

  // Payment processing
  Future<void> processPayment(BuildContext context) async {
    if (!state.canProceedToSummary) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final order = TrainOrder(
        id: 'train_${DateTime.now().millisecondsSinceEpoch}',
        selectedTrip: state.selectedTrip!,
        returnTrip: state.selectedReturnTrip,
        passengers: state.passengers,
      )..contactEmailController.text = state.contactEmail;

      // Process payment via Stripe
      final stripeService = StripeService();
      final result = await stripeService.processPayment(
        context: context,
        amount: state.totalAmount, // Amount in euros
        currency: 'eur',
        customerEmail: state.contactEmail,
        metadata: order.toJson().cast<String, String>(),
      );

      if (result.status == PaymentStatus.success) {
        // TODO: Send to webhook/save order
        _resetForm();
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Payment failed. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Payment processing failed: ${e.toString()}',
      );
    }
  }

  void _resetForm() {
    // Dispose existing passengers
    for (final passenger in state.passengers) {
      passenger.dispose();
    }

    state = const TrainOrderState();
  }

  void toggleApiResponseVisibility() {
    state = state.copyWith(showApiResponse: !state.showApiResponse);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    // Dispose all controllers when provider is disposed
    for (final passenger in state.passengers) {
      passenger.dispose();
    }
    super.dispose();
  }
}

final trainOrderProvider = StateNotifierProvider<TrainOrderNotifier, TrainOrderState>((ref) {
  return TrainOrderNotifier();
});
