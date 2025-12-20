class AddressModel {
  final String id;
  final String userId;

  /// Nama alamat (Rumah, Kantor, Kost, dll)
  final String label;

  /// Alamat lengkap
  final String address;

  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      label: map['label'] ?? '',               
      address: map['address'] ?? '',
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
