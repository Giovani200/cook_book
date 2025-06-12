class User {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString(),
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
