class AppCategory {
  final int? id;
  final String name;
  final bool isDefault;

  AppCategory({this.id, required this.name, this.isDefault = false});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'isDefault': isDefault ? 1 : 0};

  factory AppCategory.fromMap(Map<String, dynamic> map) => AppCategory(
        id: map['id'] as int?,
        name: map['name'] as String,
        isDefault: (map['isDefault'] as int) == 1,
      );
}