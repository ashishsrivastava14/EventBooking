class VenueModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final int capacity;
  final String imageUrl;
  final int rows;
  final int seatsPerRow;

  const VenueModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.capacity,
    required this.imageUrl,
    this.rows = 8,
    this.seatsPerRow = 10,
  });
}
