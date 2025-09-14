import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bundle.dart';
import '../services/stripe_service.dart';

// Sample bundle data
final bundlesProvider = Provider<List<Bundle>>((ref) {
  return [
    Bundle(
      id: 'neuschwanstein_tour',
      title: 'Neuschwanstein Castle Tour',
      subtitle: 'Full Day Experience',
      description: 'Visit the fairy tale castle with guided tour and lunch included',
      detailedDescription: 'Experience the magic of Neuschwanstein Castle with our comprehensive full-day tour. This package includes round-trip transportation, skip-the-line entrance tickets, professional guide services, and a traditional Bavarian lunch.\n\nYour adventure begins with a scenic drive through the Bavarian Alps, followed by a guided tour of the castle\'s magnificent rooms and halls. Learn about the fascinating history of King Ludwig II and his architectural masterpiece.\n\nAfter the castle tour, enjoy a delicious lunch at a local restaurant before visiting the nearby village of Hohenschwangau.',
      price: 89.00,
      duration: '8 hours',
      imageUrl: 'assets/images/neuschwanstein_tour.jpg',
      highlights: [
        'Skip-the-line castle entrance',
        'Professional guide services', 
        'Traditional Bavarian lunch included',
        'Round-trip transportation',
        'Small group experience (max 16 people)',
        'Visit to Hohenschwangau village'
      ],
      activities: [
        '09:00 - Meet at Munich Central Station',
        '10:30 - Arrive at Neuschwanstein area',
        '11:00 - Guided castle tour',
        '12:30 - Traditional lunch break',
        '14:00 - Explore Hohenschwangau village',
        '15:30 - Photo opportunity at Mary\'s Bridge',
        '16:30 - Return journey begins',
        '18:00 - Arrival back in Munich'
      ],
      category: 'Cultural Heritage',
      rating: 4.8,
      reviewCount: 1247,
    ),
    Bundle(
      id: 'alps_adventure',
      title: 'Alpine Adventure Package',
      subtitle: 'Mountain Experience',
      description: 'Hiking, cable car rides, and Alpine cuisine in the Bavarian Alps',
      detailedDescription: 'Discover the breathtaking beauty of the Bavarian Alps with our Alpine Adventure Package. This thrilling experience combines scenic cable car rides, guided hiking trails, and authentic Alpine dining.\n\nTake in panoramic views from mountain peaks, explore pristine hiking trails suitable for all fitness levels, and enjoy traditional mountain cuisine at authentic Alpine huts.\n\nPerfect for nature lovers and adventure seekers looking to experience the natural wonders of Bavaria.',
      price: 120.00,
      duration: '10 hours',
      imageUrl: 'assets/images/alps_adventure.jpg',
      highlights: [
        'Cable car rides to mountain peaks',
        'Guided hiking with certified guide',
        'Traditional Alpine lunch at mountain hut',
        'Professional photography service',
        'Small group (max 12 people)',
        'All safety equipment included'
      ],
      activities: [
        '08:00 - Hotel pickup in Munich',
        '09:30 - Arrive at Zugspitze base station',
        '10:00 - Cable car ride to peak',
        '11:00 - Guided alpine hiking',
        '13:00 - Lunch at traditional mountain hut',
        '15:00 - Explore alpine meadows',
        '16:00 - Descent via cable car',
        '18:00 - Return to Munich'
      ],
      category: 'Adventure',
      rating: 4.9,
      reviewCount: 892,
    ),
    Bundle(
      id: 'bavarian_culture',
      title: 'Bavarian Culture Experience',
      subtitle: 'Local Traditions',
      description: 'Brewery visit, traditional folk show, and authentic dinner',
      detailedDescription: 'Immerse yourself in authentic Bavarian culture with this comprehensive experience package. Visit a historic brewery, enjoy a traditional folk performance, and savor a hearty Bavarian feast.\n\nLearn about centuries-old brewing traditions, watch skilled craftsmen demonstrate traditional Bavarian arts, and experience lively folk music and dancing.\n\nThis cultural journey offers an authentic glimpse into Bavaria\'s rich heritage and traditions.',
      price: 65.00,
      duration: '6 hours',
      imageUrl: 'assets/images/bavarian_culture.jpg',
      highlights: [
        'Historic brewery tour and tasting',
        'Traditional folk show performance',
        'Authentic Bavarian dinner',
        'Local artisan demonstrations',
        'Traditional costume photo opportunity',
        'Cultural guide with local insights'
      ],
      activities: [
        '14:00 - Meet at traditional brewery',
        '14:30 - Guided brewery tour and tasting',
        '16:00 - Traditional craft demonstrations',
        '17:00 - Folk show performance',
        '18:30 - Authentic Bavarian dinner',
        '20:00 - Experience concludes'
      ],
      category: 'Cultural',
      rating: 4.7,
      reviewCount: 623,
    ),
  ];
});

// Bundle order state
class BundleOrderState {
  final BundleOrder? currentOrder;
  final bool isLoading;
  final String? error;

  BundleOrderState({
    this.currentOrder,
    this.isLoading = false,
    this.error,
  });

  BundleOrderState copyWith({
    BundleOrder? currentOrder,
    bool? isLoading,
    String? error,
  }) {
    return BundleOrderState(
      currentOrder: currentOrder ?? this.currentOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Bundle order provider
class BundleOrderNotifier extends StateNotifier<BundleOrderState> {
  BundleOrderNotifier() : super(BundleOrderState());

  void selectBundle(Bundle bundle) {
    state = state.copyWith(
      currentOrder: BundleOrder(bundle: bundle),
    );
  }

  void selectDate(DateTime date) {
    if (state.currentOrder == null) return;
    
    state = state.copyWith(
      currentOrder: state.currentOrder!.copyWith(selectedDate: date),
    );
  }

  void updateParticipantCount(int count) {
    if (state.currentOrder == null) return;
    
    final participants = <BundleParticipant>[];
    for (int i = 0; i < count; i++) {
      if (i < state.currentOrder!.participants.length) {
        participants.add(state.currentOrder!.participants[i]);
      } else {
        participants.add(BundleParticipant(givenName: '', familyName: ''));
      }
    }

    final totalAmount = count * state.currentOrder!.bundle.price;

    state = state.copyWith(
      currentOrder: state.currentOrder!.copyWith(
        participantCount: count,
        participants: participants,
        totalAmount: totalAmount,
      ),
    );
  }

  void updateParticipant(int index, String givenName, String familyName) {
    if (state.currentOrder == null || index >= state.currentOrder!.participants.length) return;

    final participants = List<BundleParticipant>.from(state.currentOrder!.participants);
    participants[index] = BundleParticipant(givenName: givenName, familyName: familyName);

    state = state.copyWith(
      currentOrder: state.currentOrder!.copyWith(participants: participants),
    );
  }

  void updateContactEmail(String email) {
    if (state.currentOrder == null) return;

    state = state.copyWith(
      currentOrder: state.currentOrder!.copyWith(contactEmail: email),
    );
  }

  Future<void> processPayment(BuildContext context) async {
    if (state.currentOrder == null || !state.currentOrder!.isComplete) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final stripeService = StripeService();
      
      // Prepare metadata for the order
      final metadata = {
        'order_type': 'bundle',
        'bundle_id': state.currentOrder!.bundle.id,
        'bundle_title': state.currentOrder!.bundle.title,
        'date': state.currentOrder!.selectedDate!.toIso8601String(),
        'participant_count': state.currentOrder!.participantCount.toString(),
        'contact_email': state.currentOrder!.contactEmail,
      };

      // Process payment
      final result = await stripeService.processPayment(
        context: context,
        amount: state.currentOrder!.totalAmount,
        currency: 'EUR',
        customerEmail: state.currentOrder!.contactEmail,
        metadata: metadata,
      );

      if (result.status == PaymentStatus.success) {
        // Payment successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Booking confirmed.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset order after successful payment
        state = BundleOrderState();
      } else {
        // Payment failed
        state = state.copyWith(
          isLoading: false,
          error: 'Payment failed. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Payment error: $e',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void clearOrder() {
    state = BundleOrderState();
  }
}

final bundleOrderProvider = StateNotifierProvider<BundleOrderNotifier, BundleOrderState>((ref) {
  return BundleOrderNotifier();
});
