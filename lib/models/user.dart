class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String accessToken;
  final String? profileImage;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accessToken,
    this.profileImage,
    this.isEmailVerified = false,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      accessToken: json['access_token'] ?? json['token'] ?? '',
      profileImage: json['profile_image'],
      isEmailVerified: json['email_verified_at'] != null || json['is_email_verified'] == true,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.tryParse(json['email_verified_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone_number': phoneNumber,
    'access_token': accessToken,
    if (profileImage != null) 'profile_image': profileImage,
    'is_email_verified': isEmailVerified,
    if (emailVerifiedAt != null) 
      'email_verified_at': emailVerifiedAt!.toIso8601String(),
  };

  bool get isVerified => isEmailVerified;

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? accessToken,
    String? profileImage,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accessToken: accessToken ?? this.accessToken,
      profileImage: profileImage ?? this.profileImage,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}