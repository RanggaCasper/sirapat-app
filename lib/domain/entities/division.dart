class Division {
  final int? id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Division({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Factory from JSON (for entity)
  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // CopyWith for immutability
  Division copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Division(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Division(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Division &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode;
  }
}
