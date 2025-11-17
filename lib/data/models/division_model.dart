import 'package:sirapat_app/domain/entities/division.dart';

class DivisionModel extends Division {
  DivisionModel({
    super.id,
    required super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) {
    return DivisionModel(
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

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  DivisionModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DivisionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert DivisionModel to Division entity
  Division toEntity() {
    return Division(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create DivisionModel from Division entity
  factory DivisionModel.fromEntity(Division division) {
    return DivisionModel(
      id: division.id,
      name: division.name,
      description: division.description,
      createdAt: division.createdAt,
      updatedAt: division.updatedAt,
    );
  }
}
