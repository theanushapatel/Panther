class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String sport;
  final String profilePictureUrl;
  final Map<String, dynamic> performanceMetrics;
  final List<String> healthRecords;
  final List<String> careerGoals;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.sport,
    this.profilePictureUrl = '',
    this.performanceMetrics = const {},
    this.healthRecords = const [],
    this.careerGoals = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      sport: json['sport'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String? ?? '',
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>? ?? {},
      healthRecords: List<String>.from(json['healthRecords'] ?? []),
      careerGoals: List<String>.from(json['careerGoals'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'sport': sport,
      'profilePictureUrl': profilePictureUrl,
      'performanceMetrics': performanceMetrics,
      'healthRecords': healthRecords,
      'careerGoals': careerGoals,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? sport,
    String? profilePictureUrl,
    Map<String, dynamic>? performanceMetrics,
    List<String>? healthRecords,
    List<String>? careerGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      sport: sport ?? this.sport,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      healthRecords: healthRecords ?? this.healthRecords,
      careerGoals: careerGoals ?? this.careerGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, age: $age, gender: $gender, sport: $sport)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}