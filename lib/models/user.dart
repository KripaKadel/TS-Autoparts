class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String accessToken;
  final String? profileImage;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;
  final String role; // Added role field

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accessToken,
    this.profileImage,
    this.isEmailVerified = false,
    this.emailVerifiedAt,
    this.role = 'customer', // Default to 'customer', can be 'mechanic' or others
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
      role: json['role'] ?? 'customer', // Extract role from JSON, default to 'customer'
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
    'role': role, // Include role in the JSON representation
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
    String? role, // Added role in copyWith for easier modification
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
      role: role ?? this.role, // Ensure role is copied
    );
  }
}
