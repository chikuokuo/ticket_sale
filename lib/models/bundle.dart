class Bundle {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String detailedDescription;
  final double price;
  final String duration;
  final String imageUrl;
  final List<String> highlights;
  final List<String> activities;
  final String category;
  final double rating;
  final int reviewCount;

  Bundle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.detailedDescription,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.highlights,
    required this.activities,
    required this.category,
    required this.rating,
    required this.reviewCount,
  });
}

class BundleParticipant {
  final String givenName;
  final String familyName;

  BundleParticipant({
    required this.givenName,
    required this.familyName,
  });

  BundleParticipant copyWith({
    String? givenName,
    String? familyName,
  }) {
    return BundleParticipant(
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
    );
  }

  bool get isComplete => givenName.isNotEmpty && familyName.isNotEmpty;
}

class BundleOrder {
  final Bundle bundle;
  final DateTime? selectedDate;
  final int participantCount;
  final List<BundleParticipant> participants;
  final String contactEmail;
  final double totalAmount;

  BundleOrder({
    required this.bundle,
    this.selectedDate,
    this.participantCount = 1,
    this.participants = const [],
    this.contactEmail = '',
    this.totalAmount = 0.0,
  });

  BundleOrder copyWith({
    Bundle? bundle,
    DateTime? selectedDate,
    int? participantCount,
    List<BundleParticipant>? participants,
    String? contactEmail,
    double? totalAmount,
  }) {
    return BundleOrder(
      bundle: bundle ?? this.bundle,
      selectedDate: selectedDate ?? this.selectedDate,
      participantCount: participantCount ?? this.participantCount,
      participants: participants ?? this.participants,
      contactEmail: contactEmail ?? this.contactEmail,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  bool get isComplete {
    return selectedDate != null &&
           participantCount > 0 &&
           participants.length == participantCount &&
           participants.every((p) => p.isComplete) &&
           contactEmail.isNotEmpty;
  }
}
