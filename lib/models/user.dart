class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String accessToken;
  final String? verificationHash; // Added for email verification
  final bool? isEmailVerified;   // Added to track verification status
  final DateTime? emailVerifiedAt; // Added for verification timestamp

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accessToken,
    this.verificationHash,
    this.isEmailVerified,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']?['id'] ?? json['id'] ?? 0,
      name: json['user']?['name'] ?? json['name'] ?? 'Unknown',
      email: json['user']?['email'] ?? json['email'] ?? '',
      phoneNumber: json['user']?['phone_number'] ?? json['phone_number'] ?? '',
      accessToken: json['access_token'] ?? '',
      verificationHash: json['verification_hash'] ?? json['email_verification_hash'],
      isEmailVerified: json['is_email_verified'] ?? json['email_verified'] ?? false,
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
    if (verificationHash != null) 'verification_hash': verificationHash,
    if (isEmailVerified != null) 'is_email_verified': isEmailVerified,
    if (emailVerifiedAt != null) 
      'email_verified_at': emailVerifiedAt!.toIso8601String(),
  };

  // Helper method to check if email is verified
  bool get isVerified => isEmailVerified ?? false;

  // Copy with method for updating fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? accessToken,
    String? verificationHash,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accessToken: accessToken ?? this.accessToken,
      verificationHash: verificationHash ?? this.verificationHash,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}