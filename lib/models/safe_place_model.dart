class SafePlace {
  final String id;
  final String name;
  final String category; // 'police', 'hospital', 'metro', 'store', 'petrol'
  final double latitude;
  final double longitude;
  final String address;
  final String phone;
  final bool is24x7;

  SafePlace({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
    required this.is24x7,
  });

  factory SafePlace.fromMap(Map<String, dynamic> map) {
    return SafePlace(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'store',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      is24x7: map['is24x7'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'is24x7': is24x7,
    };
  }
}
