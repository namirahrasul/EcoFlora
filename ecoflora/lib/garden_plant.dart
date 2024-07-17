class GardenPlant {
  final String id;
  final String name;
  final String imagePath;
  final DateTime dateBought;

  GardenPlant({
    required this.name,
    required this.imagePath,
    required this.dateBought,
  }) : id = DateTime.now().toString();

  factory GardenPlant.fromJson(Map<String, dynamic> json) {
    return GardenPlant(
     name: json['name'] ??
          'Unknown Plant', // Provide a default value if name is null
      imagePath: json['imagePath'] ??
          '', // Provide a default value if imagePath is null
      dateBought: json['dateBought'] != null
          ? DateTime.parse(json['dateBought'])
          : DateTime.now(), // Provide a default date if dateBought is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'dateBought': dateBought.toIso8601String(),
    };
  }
}
