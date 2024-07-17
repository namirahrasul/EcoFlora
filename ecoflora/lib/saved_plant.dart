class SavedPlant {
  final String id;
  final String commonName;
  final String scientificName;
  final String imageUrl;
  final List<String> areas;

  SavedPlant({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.imageUrl,
    required this.areas,
  });

  factory SavedPlant.fromJson(Map<String, dynamic> json) {
    return SavedPlant(
      id: json['id'].toString(), // Convert ID to string
      commonName: json['common_name'] ?? json['scientific_name'],
      scientificName: json['scientific_name'] ?? '-',
      imageUrl: json['image_url'] ?? '',
      areas: List<String>.from(json['areas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'image_url': imageUrl,
      'areas': areas,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SavedPlant &&
        other.id == id &&
        other.commonName == commonName &&
        other.scientificName == scientificName &&
        other.imageUrl == imageUrl &&
        _listEquals(other.areas, areas);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        commonName.hashCode ^
        scientificName.hashCode ^
        imageUrl.hashCode ^
        areas.hashCode;
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
