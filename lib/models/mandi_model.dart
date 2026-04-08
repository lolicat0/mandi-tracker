class MandiModel {
  final String id;
  final String name;
  final String district;
  final double latitude;
  final double longitude;

  MandiModel({
    required this.id,
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
  });

  factory MandiModel.fromMap(Map<String, dynamic> data, String id) {
    return MandiModel(
      id: id,
      name: data['name'] ?? '',
      district: data['district'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
