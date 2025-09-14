class RailPass {
  final String id;
  final String name;
  final String description;
  final List<String> countries;
  final String flagIcon;
  final List<RailPassPricing> pricing;
  final List<String> features;
  final bool isPopular;

  const RailPass({
    required this.id,
    required this.name,
    required this.description,
    required this.countries,
    required this.flagIcon,
    required this.pricing,
    required this.features,
    this.isPopular = false,
  });
}

class RailPassPricing {
  final int days;
  final double individualPrice;
  final double youthPrice;
  final double groupPrice; // per person for 2-5 people
  final String currency;

  const RailPassPricing({
    required this.days,
    required this.individualPrice,
    required this.youthPrice,
    required this.groupPrice,
    this.currency = '€',
  });
}

enum TicketCategory {
  individual,
}

extension TicketCategoryExtension on TicketCategory {
  String get displayName {
    switch (this) {
      case TicketCategory.individual:
        return 'Individual';
    }
  }
}

class RailPassData {
  static const List<RailPass> passes = [
    RailPass(
      id: 'italy',
      name: 'Italy Rail Pass',
      description: 'Discover Italy from north to south',
      countries: ['Italy'],
      flagIcon: '🇮🇹',
      isPopular: true,
      pricing: [
        RailPassPricing(days: 3, individualPrice: 160, youthPrice: 128, groupPrice: 144),
        RailPassPricing(days: 4, individualPrice: 191, youthPrice: 153, groupPrice: 172),
        RailPassPricing(days: 5, individualPrice: 219, youthPrice: 175, groupPrice: 197),
        RailPassPricing(days: 8, individualPrice: 294, youthPrice: 235, groupPrice: 265),
      ],
      features: [
        'Unlimited train travel in Italy',
        'High-speed trains included',
        'Flexible travel days',
        'Valid for 2 months',
        'Regional train access',
      ],
    ),
  ];

  static RailPass? getPassById(String id) {
    try {
      return passes.firstWhere((pass) => pass.id == id);
    } catch (e) {
      return null;
    }
  }
}