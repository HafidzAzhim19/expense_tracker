class AppCategory {
  final int? id;
  final String name;
  final bool isDefault;
  final int? userId;

  AppCategory({this.id, required this.name, this.isDefault = false, this.userId});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'isDefault': isDefault ? 1 : 0, 'userId': userId};

  factory AppCategory.fromMap(Map<String, dynamic> map) => AppCategory(
        id: map['id'] as int?,
        name: map['name'] as String,
        isDefault: (map['isDefault'] as int) == 1,
        userId: map['userId'] as int?,
      );
}