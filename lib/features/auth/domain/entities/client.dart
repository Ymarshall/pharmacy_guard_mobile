class Client {
  final int id;
  final String phone;
  final double latitude;
  final double longitude;
  final String providerType;
  final bool isActive;

  const Client({
    required this.id,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.providerType,
    required this.isActive,
  });
}

