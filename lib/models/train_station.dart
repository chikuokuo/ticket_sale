class TrainStation {
  final String id;
  final String name;
  final String code;
  final String city;

  const TrainStation({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainStation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name ($code)';
}

// Static list of German train stations
class TrainStations {
  static const List<TrainStation> stations = [
    TrainStation(
      id: 'berlin_hbf',
      name: 'Berlin Hauptbahnhof',
      code: 'BER',
      city: 'Berlin',
    ),
    TrainStation(
      id: 'munich_hbf',
      name: 'München Hauptbahnhof',
      code: 'MUN',
      city: 'Munich',
    ),
    TrainStation(
      id: 'hamburg_hbf',
      name: 'Hamburg Hauptbahnhof',
      code: 'HAM',
      city: 'Hamburg',
    ),
    TrainStation(
      id: 'frankfurt_hbf',
      name: 'Frankfurt (Main) Hauptbahnhof',
      code: 'FRA',
      city: 'Frankfurt',
    ),
    TrainStation(
      id: 'stuttgart_hbf',
      name: 'Stuttgart Hauptbahnhof',
      code: 'STU',
      city: 'Stuttgart',
    ),
    TrainStation(
      id: 'cologne_hbf',
      name: 'Köln Hauptbahnhof',
      code: 'COL',
      city: 'Cologne',
    ),
    TrainStation(
      id: 'fuessen',
      name: 'Füssen',
      code: 'FUS',
      city: 'Füssen',
    ),
    TrainStation(
      id: 'milan_centrale',
      name: 'Milano Centrale',
      code: 'MIL',
      city: 'Milan',
    ),
    TrainStation(
      id: 'florence_smn',
      name: 'Firenze Santa Maria Novella',
      code: 'FLR',
      city: 'Florence',
    ),
  ];
  
  static TrainStation? findById(String id) {
    try {
      return stations.firstWhere((station) => station.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static TrainStation? findByCode(String code) {
    try {
      return stations.firstWhere((station) => station.code == code);
    } catch (e) {
      return null;
    }
  }
}
