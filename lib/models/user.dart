class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String accessToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']?['id'] ?? json['id'] ?? 0, // Handles both nested and flat structures
      name: json['user']?['name'] ?? json['name'] ?? 'Unknown',
      email: json['user']?['email'] ?? json['email'] ?? '',
      phoneNumber: json['user']?['phone_number'] ?? json['phone_number'] ?? '',
      accessToken: json['access_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone_number': phoneNumber,
    'access_token': accessToken,
  };
}