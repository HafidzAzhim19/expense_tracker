class AppUser {
  final int? id;
  final String username;
  final String password;

  AppUser({this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() => {'id': id, 'username': username, 'password': password};

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int?,
        username: map['username'] as String,
        password: map['password'] as String,
      );
}