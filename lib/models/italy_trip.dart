class ItalyTrip {
  final String id;
  final String emoji;
  final String nameEn;
  final String nameZh;
  final String cityZh;
  final String cityEn;
  final String tag;
  final String description;

  const ItalyTrip({
    required this.id,
    required this.emoji,
    required this.nameEn,
    required this.nameZh,
    required this.cityZh,
    required this.cityEn,
    required this.tag,
    required this.description,
  });

  // Static list of Italian attractions
  static const List<ItalyTrip> attractions = [
    ItalyTrip(
      id: "pompeii",
      emoji: "🌋",
      nameEn: "Pompeii",
      nameZh: "龐貝古城",
      cityZh: "龐貝",
      cityEn: "Pompeii",
      tag: "Italian Attractions",
      description: "Ancient Roman city preserved by volcanic ash",
    ),
    ItalyTrip(
      id: "colosseum",
      emoji: "🏛️",
      nameEn: "Colosseum",
      nameZh: "羅馬競技場",
      cityZh: "羅馬",
      cityEn: "Rome",
      tag: "Italian Attractions",
      description: "Iconic amphitheatre of ancient Rome",
    ),
    ItalyTrip(
      id: "venice",
      emoji: "🛶",
      nameEn: "Venice Gondola",
      nameZh: "威尼斯貢多拉",
      cityZh: "威尼斯",
      cityEn: "Venice",
      tag: "Italian Attractions",
      description: "Glide through canals and stone bridges",
    ),
    ItalyTrip(
      id: "cinque",
      emoji: "🌈",
      nameEn: "Cinque Terre",
      nameZh: "五鄉地",
      cityZh: "利古里亞",
      cityEn: "Liguria",
      tag: "Italian Attractions",
      description: "Colorful cliffside villages and sea views",
    ),
    ItalyTrip(
      id: "duomo",
      emoji: "⛪",
      nameEn: "Duomo di Milano",
      nameZh: "米蘭主教座堂",
      cityZh: "米蘭",
      cityEn: "Milan",
      tag: "Italian Attractions",
      description: "Gothic cathedral with spires and rooftop",
    ),
    ItalyTrip(
      id: "florence",
      emoji: "🎨",
      nameEn: "Uffizi Gallery",
      nameZh: "烏菲茲美術館",
      cityZh: "佛羅倫斯",
      cityEn: "Florence",
      tag: "Italian Attractions",
      description: "Renaissance masterpieces in Tuscany",
    ),
    ItalyTrip(
      id: "amalfi",
      emoji: "🏖️",
      nameEn: "Amalfi Coast",
      nameZh: "阿瑪菲海岸",
      cityZh: "阿瑪菲",
      cityEn: "Amalfi",
      tag: "Italian Attractions",
      description: "Dramatic coastline, lemons and sunsets",
    ),
    ItalyTrip(
      id: "pisa",
      emoji: "🗼",
      nameEn: "Leaning Tower",
      nameZh: "比薩斜塔",
      cityZh: "比薩",
      cityEn: "Pisa",
      tag: "Italian Attractions",
      description: "The most charming engineering mistake",
    ),
    ItalyTrip(
      id: "capri",
      emoji: "🟦",
      nameEn: "Blue Grotto",
      nameZh: "藍洞",
      cityZh: "卡布里",
      cityEn: "Capri",
      tag: "Italian Attractions",
      description: "Electric-blue sea cave by boat",
    ),
    ItalyTrip(
      id: "dolomites",
      emoji: "⛰️",
      nameEn: "Dolomites Hike",
      nameZh: "多洛米蒂健行",
      cityZh: "南蒂羅爾",
      cityEn: "South Tyrol",
      tag: "Italian Attractions",
      description: "Jagged peaks and alpine meadows",
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItalyTrip &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ItalyTrip{id: $id, nameEn: $nameEn, nameZh: $nameZh}';
  }
}
