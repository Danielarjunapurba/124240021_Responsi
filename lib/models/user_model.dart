class UserModel {
  const UserModel({
    this.id,
    required this.name,
    required this.email,
    this.password = '',
  });

  final int? id;
  final String name;
  final String email;
  final String password;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toSessionJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
