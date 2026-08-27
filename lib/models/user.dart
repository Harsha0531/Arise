class AppUser {
  final String id;
  final String username;
  final String displayName;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      username: map['username'] as String,
      displayName: map['displayName'] as String,
      createdAt: DateTime.parse(
        map['createdAt'] as String,
      ),
    );
  }
}