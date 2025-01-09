class User {
  final int userId;
  final String userName;
  final String email;
  final String userUniqueCode;

  User({
    required this.userId,
    required this.userName,
    required this.email,
    required this.userUniqueCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      userUniqueCode: json['userUniqueCode'] ?? '',
    );
  }

  factory User.empty() {
    return User(
      userId: 0,
      userName: '',
      email: '',
      userUniqueCode: '',
    );
  }

  bool get isValid => userId != 0 && userName.isNotEmpty && email.isNotEmpty && userUniqueCode.isNotEmpty;
}
