class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final bool isAdmin;
  final DateTime joinDate;
  final int bookingCount;
  bool isBanned;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.isAdmin = false,
    required this.joinDate,
    this.bookingCount = 0,
    this.isBanned = false,
  });

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin,
      joinDate: joinDate,
      bookingCount: bookingCount,
      isBanned: isBanned,
    );
  }
}
