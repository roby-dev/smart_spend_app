class UserProfile {
  final String? name;
  final String? email;
  final String? photoUrl;

  const UserProfile({this.name, this.email, this.photoUrl});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String?,
    email: json['email'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );

  /// Initials for the avatar fallback when there is no photo.
  String get initials {
    final source = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : (email ?? '');
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return source[0].toUpperCase();
  }
}
