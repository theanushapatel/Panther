enum MentorshipStatus {
  pending,
  active,
  completed,
  cancelled
}

enum CourseStatus {
  notStarted,
  inProgress,
  completed,
  archived
}

class Career {
  final String id;
  final String userId;
  final List<CareerGoal> goals;
  final List<MentorshipProgram> mentorships;
  final List<Course> courses;
  final List<Achievement> achievements;
  final Map<String, dynamic>? careerStats;
  final DateTime createdAt;
  final DateTime updatedAt;

  Career({
    required this.id,
    required this.userId,
    this.goals = const [],
    this.mentorships = const [],
    this.courses = const [],
    this.achievements = const [],
    this.careerStats,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goals: (json['goals'] as List?)
          ?.map((e) => CareerGoal.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      mentorships: (json['mentorships'] as List?)
          ?.map((e) => MentorshipProgram.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      courses: (json['courses'] as List?)
          ?.map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      achievements: (json['achievements'] as List?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      careerStats: json['careerStats'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'goals': goals.map((e) => e.toJson()).toList(),
      'mentorships': mentorships.map((e) => e.toJson()).toList(),
      'courses': courses.map((e) => e.toJson()).toList(),
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'careerStats': careerStats,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  List<MentorshipProgram> get activeMentorships =>
      mentorships.where((m) => m.status == MentorshipStatus.active).toList();

  List<Course> get activeCourses =>
      courses.where((c) => c.status == CourseStatus.inProgress).toList();

  List<CareerGoal> get activeGoals =>
      goals.where((g) => !g.isCompleted).toList();

  double calculateProgressPercentage() {
    if (goals.isEmpty) return 0;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    return (completedGoals / goals.length) * 100;
  }
}

class CareerGoal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final List<String> milestones;
  final DateTime createdAt;

  CareerGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
    this.milestones = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CareerGoal.fromJson(Map<String, dynamic> json) {
    return CareerGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      milestones: List<String>.from(json['milestones'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'milestones': milestones,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MentorshipProgram {
  final String id;
  final String mentorId;
  final String mentorName;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final MentorshipStatus status;
  final List<MentorshipSession> sessions;

  MentorshipProgram({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.status = MentorshipStatus.pending,
    this.sessions = const [],
  });

  factory MentorshipProgram.fromJson(Map<String, dynamic> json) {
    return MentorshipProgram(
      id: json['id'] as String,
      mentorId: json['mentorId'] as String,
      mentorName: json['mentorName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: MentorshipStatus.values.firstWhere(
        (e) => e.toString() == 'MentorshipStatus.${json['status']}',
      ),
      sessions: (json['sessions'] as List?)
          ?.map((e) => MentorshipSession.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class MentorshipSession {
  final String id;
  final DateTime date;
  final String topic;
  final String notes;
  final bool isCompleted;

  MentorshipSession({
    required this.id,
    required this.date,
    required this.topic,
    required this.notes,
    this.isCompleted = false,
  });

  factory MentorshipSession.fromJson(Map<String, dynamic> json) {
    return MentorshipSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      topic: json['topic'] as String,
      notes: json['notes'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'topic': topic,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String provider;
  final CourseStatus status;
  final double progressPercentage;
  final DateTime? completionDate;
  final List<Module> modules;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.provider,
    this.status = CourseStatus.notStarted,
    this.progressPercentage = 0,
    this.completionDate,
    this.modules = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      provider: json['provider'] as String,
      status: CourseStatus.values.firstWhere(
        (e) => e.toString() == 'CourseStatus.${json['status']}',
      ),
      progressPercentage: json['progressPercentage'] as double? ?? 0,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      modules: (json['modules'] as List?)
          ?.map((e) => Module.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'provider': provider,
      'status': status.toString().split('.').last,
      'progressPercentage': progressPercentage,
      'completionDate': completionDate?.toIso8601String(),
      'modules': modules.map((e) => e.toJson()).toList(),
    };
  }
}

class Module {
  final String id;
  final String title;
  final bool isCompleted;
  final List<String> resources;

  Module({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.resources = const [],
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      resources: List<String>.from(json['resources'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'resources': resources,
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime dateAchieved;
  final String? badge;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.dateAchieved,
    this.badge,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateAchieved: DateTime.parse(json['dateAchieved'] as String),
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateAchieved': dateAchieved.toIso8601String(),
      'badge': badge,
    };
  }
}