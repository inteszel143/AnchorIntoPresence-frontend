class UserModel {
  final String id;
  final String name;
  final String email;
  final String provider;
  final String? image;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'] ?? '',
      image: json['image'],
    );
  }
}
