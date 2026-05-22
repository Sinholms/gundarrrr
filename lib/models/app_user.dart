class AppUser {
  final String userId;
  final String fullName;
  final String username;
  final String email;
  final String authProvider;
  final bool hasCompletedUmkmRegistration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;

  const AppUser({
    required this.userId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.authProvider,
    required this.hasCompletedUmkmRegistration,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
  });

  AppUser copyWith({
    String? fullName,
    String? username,
    String? email,
    String? authProvider,
    bool? hasCompletedUmkmRegistration,
    DateTime? updatedAt,
    String? photoUrl,
  }) {
    return AppUser(
      userId: userId,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      authProvider: authProvider ?? this.authProvider,
      hasCompletedUmkmRegistration:
          hasCompletedUmkmRegistration ?? this.hasCompletedUmkmRegistration,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
