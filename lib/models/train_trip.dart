import 'train_station.dart';

enum TrainType {
  ice,      // ICE (Intercity-Express)
  ic,       // IC (Intercity)  
  ec,       // EC (EuroCity)
  re,       // RE (Regional Express)
  rb,       // RB (Regionalbahn)
}

enum TicketClass {
  second,   // 2nd Class
  first,    // 1st Class
}

extension TrainTypeExtension on TrainType {
  String get displayName {
    switch (this) {
      case TrainType.ice:
        return 'ICE';
      case TrainType.ic:
        return 'IC';
      case TrainType.ec:
        return 'EC';
      case TrainType.re:
        return 'RE';
      case TrainType.rb:
        return 'RB';
    }
  }
}

extension TicketClassExtension on TicketClass {
  String get displayName {
    switch (this) {
      case TicketClass.first:
        return '1st Class';
      case TicketClass.second:
        return '2nd Class';
    }
  }
  
  String get shortName {
    switch (this) {
      case TicketClass.first:
        return '1st';
      case TicketClass.second:
        return '2nd';
    }
  }
}

class TrainTrip {
  final String id;
  final String trainNumber;
  final TrainType trainType;
  final TrainStation fromStation;
  final TrainStation toStation;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final Duration duration;
  final Map<TicketClass, double> prices;
  final List<String> amenities;
  final bool hasWifi;
  final bool hasRestaurant;
  final int availableSeats;

  const TrainTrip({
    required this.id,
    required this.trainNumber,
    required this.trainType,
    required this.fromStation,
    required this.toStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.prices,
    this.amenities = const [],
    this.hasWifi = false,
    this.hasRestaurant = false,
    this.availableSeats = 100,
  });

  double getPriceForClass(TicketClass ticketClass) {
    return prices[ticketClass] ?? 0.0;
  }

  double get lowestPrice {
    if (prices.isEmpty) return 0.0;
    return prices.values.reduce((a, b) => a < b ? a : b);
  }

  String get formattedDepartureTime {
    return '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedArrivalTime {
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String get fullTrainName {
    return '${trainType.displayName} $trainNumber';
  }
}

// Static data for train trips
class TrainTripsData {
  static List<TrainTrip> getTripsForRoute({
    required TrainStation from,
    required TrainStation to,
    required DateTime date,
  }) {
    // This would normally come from an API
    // For now, return static data based on popular routes
    
    if (from.id == 'munich_hbf' && to.id == 'fuessen') {
      return _getMunichToFuessenTrips(date);
    } else if (from.id == 'berlin_hbf' && to.id == 'munich_hbf') {
      return _getBerlinToMunichTrips(date);
    } else if (from.id == 'hamburg_hbf' && to.id == 'munich_hbf') {
      return _getHamburgToMunichTrips(date);
    } else if (from.id == 'frankfurt_hbf' && to.id == 'munich_hbf') {
      return _getFrankfurtToMunichTrips(date);
    }
    
    // Return generic trips for other routes
    return _getGenericTrips(from, to, date);
  }
  
  static List<TrainTrip> _getMunichToFuessenTrips(DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    
    return [
      TrainTrip(
        id: 'mun_fue_1',
        trainNumber: '73',
        trainType: TrainType.rb,
        fromStation: TrainStations.findById('munich_hbf')!,
        toStation: TrainStations.findById('fuessen')!,
        departureTime: baseDate.add(const Duration(hours: 8, minutes: 45)),
        arrivalTime: baseDate.add(const Duration(hours: 10, minutes: 55)),
        duration: const Duration(hours: 2, minutes: 10),
        prices: {
          TicketClass.second: 16.90,
        },
        hasWifi: false,
        availableSeats: 45,
      ),
      TrainTrip(
        id: 'mun_fue_2', 
        trainNumber: '78',
        trainType: TrainType.rb,
        fromStation: TrainStations.findById('munich_hbf')!,
        toStation: TrainStations.findById('fuessen')!,
        departureTime: baseDate.add(const Duration(hours: 10, minutes: 45)),
        arrivalTime: baseDate.add(const Duration(hours: 12, minutes: 55)),
        duration: const Duration(hours: 2, minutes: 10),
        prices: {
          TicketClass.second: 16.90,
        },
        hasWifi: false,
        availableSeats: 32,
      ),
      TrainTrip(
        id: 'mun_fue_3',
        trainNumber: '73',
        trainType: TrainType.rb,
        fromStation: TrainStations.findById('munich_hbf')!,
        toStation: TrainStations.findById('fuessen')!,
        departureTime: baseDate.add(const Duration(hours: 14, minutes: 45)),
        arrivalTime: baseDate.add(const Duration(hours: 16, minutes: 55)),
        duration: const Duration(hours: 2, minutes: 10),
        prices: {
          TicketClass.second: 16.90,
        },
        hasWifi: false,
        availableSeats: 38,
      ),
    ];
  }
  
  static List<TrainTrip> _getBerlinToMunichTrips(DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    
    return [
      TrainTrip(
        id: 'ber_mun_1',
        trainNumber: '625',
        trainType: TrainType.ice,
        fromStation: TrainStations.findById('berlin_hbf')!,
        toStation: TrainStations.findById('munich_hbf')!,
        departureTime: baseDate.add(const Duration(hours: 7, minutes: 30)),
        arrivalTime: baseDate.add(const Duration(hours: 11, minutes: 42)),
        duration: const Duration(hours: 4, minutes: 12),
        prices: {
          TicketClass.second: 79.00,
          TicketClass.first: 139.00,
        },
        hasWifi: true,
        hasRestaurant: true,
        availableSeats: 156,
      ),
      TrainTrip(
        id: 'ber_mun_2',
        trainNumber: '629',
        trainType: TrainType.ice,
        fromStation: TrainStations.findById('berlin_hbf')!,
        toStation: TrainStations.findById('munich_hbf')!,
        departureTime: baseDate.add(const Duration(hours: 9, minutes: 30)),
        arrivalTime: baseDate.add(const Duration(hours: 13, minutes: 42)),
        duration: const Duration(hours: 4, minutes: 12),
        prices: {
          TicketClass.second: 89.00,
          TicketClass.first: 149.00,
        },
        hasWifi: true,
        hasRestaurant: true,
        availableSeats: 142,
      ),
    ];
  }
  
  static List<TrainTrip> _getHamburgToMunichTrips(DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    
    return [
      TrainTrip(
        id: 'ham_mun_1',
        trainNumber: '505',
        trainType: TrainType.ice,
        fromStation: TrainStations.findById('hamburg_hbf')!,
        toStation: TrainStations.findById('munich_hbf')!,
        departureTime: baseDate.add(const Duration(hours: 8, minutes: 15)),
        arrivalTime: baseDate.add(const Duration(hours: 14, minutes: 28)),
        duration: const Duration(hours: 6, minutes: 13),
        prices: {
          TicketClass.second: 119.00,
          TicketClass.first: 199.00,
        },
        hasWifi: true,
        hasRestaurant: true,
        availableSeats: 178,
      ),
    ];
  }
  
  static List<TrainTrip> _getFrankfurtToMunichTrips(DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    
    return [
      TrainTrip(
        id: 'fra_mun_1',
        trainNumber: '1021',
        trainType: TrainType.ice,
        fromStation: TrainStations.findById('frankfurt_hbf')!,
        toStation: TrainStations.findById('munich_hbf')!,
        departureTime: baseDate.add(const Duration(hours: 9, minutes: 0)),
        arrivalTime: baseDate.add(const Duration(hours: 12, minutes: 30)),
        duration: const Duration(hours: 3, minutes: 30),
        prices: {
          TicketClass.second: 69.00,
          TicketClass.first: 119.00,
        },
        hasWifi: true,
        hasRestaurant: true,
        availableSeats: 165,
      ),
    ];
  }
  
  static List<TrainTrip> _getGenericTrips(TrainStation from, TrainStation to, DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    
    return [
      TrainTrip(
        id: 'generic_1',
        trainNumber: '1001',
        trainType: TrainType.ic,
        fromStation: from,
        toStation: to,
        departureTime: baseDate.add(const Duration(hours: 9, minutes: 30)),
        arrivalTime: baseDate.add(const Duration(hours: 12, minutes: 45)),
        duration: const Duration(hours: 3, minutes: 15),
        prices: {
          TicketClass.second: 59.00,
          TicketClass.first: 99.00,
        },
        hasWifi: true,
        availableSeats: 120,
      ),
      TrainTrip(
        id: 'generic_2',
        trainNumber: '1003',
        trainType: TrainType.ic,
        fromStation: from,
        toStation: to,
        departureTime: baseDate.add(const Duration(hours: 11, minutes: 30)),
        arrivalTime: baseDate.add(const Duration(hours: 14, minutes: 45)),
        duration: const Duration(hours: 3, minutes: 15),
        prices: {
          TicketClass.second: 59.00,
          TicketClass.first: 99.00,
        },
        hasWifi: true,
        availableSeats: 95,
      ),
    ];
  }
}
