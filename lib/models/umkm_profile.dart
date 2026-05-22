class UmkmProfile {
  final String umkmId;
  final String ownerUserId;
  final String umkmName;
  final String whatsappNumber;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UmkmProfile({
    required this.umkmId,
    required this.ownerUserId,
    required this.umkmName,
    required this.whatsappNumber,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });
}
