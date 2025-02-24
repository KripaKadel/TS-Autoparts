class User {
  final String name;
  final String email;
  final String phoneNumber;
  final String accessToken;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Safely access the keys to prevent null errors
    return User(
      name: json['user']?['name'] ?? 'Unknown', // Provide default if null or missing
      email: json['user']?['email'] ?? 'No email provided', // Default if null
      phoneNumber: json['user']?['phone_number'] ?? 'No phone number provided', // Default if null
      accessToken: json['access_token'] ?? 'No token available', // Default if missing or null
    );
  }
}
