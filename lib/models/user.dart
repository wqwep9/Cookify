class User {
  final int? id;
  final String name;
  final int age;
  final String email;
  final String password;

  User({
    this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      email: map['email'],
      password: map['password'],
    );
  }
} 