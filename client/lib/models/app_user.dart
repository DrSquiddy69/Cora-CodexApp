class AppUser {
  AppUser({
    required this.email,
    required this.friendCode,
    required this.matrixUserId,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
  });

  final String email;
  final String friendCode;
  final String matrixUserId;
  final String displayName;
  final String bio;
  final String? avatarUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        email: json['email'] as String? ?? '',
        friendCode: json['friend_code'] as String,
        matrixUserId: json['matrix_user_id'] as String,
        displayName: json['display_name'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'friend_code': friendCode,
        'matrix_user_id': matrixUserId,
        'display_name': displayName,
        'bio': bio,
        'avatar_url': avatarUrl,
      };
}
