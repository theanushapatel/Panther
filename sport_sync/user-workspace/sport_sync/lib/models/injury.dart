import 'package:flutter/foundation.dart';

enum InjurySeverity {
  mild,
  moderate,
  severe,
  critical
}

enum InjuryStatus {
  active,
  recovering,
  resolved,
  chronic
}

class Injury {
  final String id;
  final String userId;
  final String type;
  final String description;
  final DateTime dateOccurred;
  final InjurySeverity severity;
  final InjuryStatus status;
  final String? location;
  final String? diagnosis;
  final String? treatment;
  final List<String>? symptoms;
  final List<InjuryUpdate> updates;
  final Map<String, dynamic>? medicalReports;
  final DateTime? expectedRecoveryDate;
  final bool isRecurring;

  Injury({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.dateOccurred,
    required this.severity,
    required this.status,
    this.location,
    this.diagnosis,
    this.treatment,
    this.symptoms,
    this.updates = const [],
    this.medicalReports,
    this.expectedRecoveryDate,
    this.isRecurring = false,
  });

  factory Injury.fromJson(Map<String, dynamic> json) {
    return Injury(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      dateOccurred: DateTime.parse(json['dateOccurred'] as String),
      severity: InjurySeverity.values.firstWhere(
        (e) => e.toString() == 'InjurySeverity.${json['severity']}',
      ),
      status: InjuryStatus.values.firstWhere(
        (e) => e.toString() == 'InjuryStatus.${json['status']}',
      ),
      location: json['location'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      symptoms: json['symptoms'] != null 
        ? List<String>.from(json['symptoms'] as List)
        : null,
      updates: json['updates'] != null
        ? (json['updates'] as List)
            .map((update) => InjuryUpdate.fromJson(update as Map<String, dynamic>))
            .toList()
        : [],
      medicalReports: json['medicalReports'] as Map<String, dynamic>?,
      expectedRecoveryDate: json['expectedRecoveryDate'] != null
        ? DateTime.parse(json['expectedRecoveryDate'] as String)
        : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'description': description,
      'dateOccurred': dateOccurred.toIso8601String(),
      'severity': severity.toString().split('.').last,
      'status': status.toString().split('.').last,
      'location': location,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'symptoms': symptoms,
      'updates': updates.map((update) => update.toJson()).toList(),
      'medicalReports': medicalReports,
      'expectedRecoveryDate': expectedRecoveryDate?.toIso8601String(),
      'isRecurring': isRecurring,
    };
  }

  Injury copyWith({
    String? id,
    String? userId,
    String? type,
    String? description,
    DateTime? dateOccurred,
    InjurySeverity? severity,
    InjuryStatus? status,
    String? location,
    String? diagnosis,
    String? treatment,
    List<String>? symptoms,
    List<InjuryUpdate>? updates,
    Map<String, dynamic>? medicalReports,
    DateTime? expectedRecoveryDate,
    bool? isRecurring,
  }) {
    return Injury(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      dateOccurred: dateOccurred ?? this.dateOccurred,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      location: location ?? this.location,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      symptoms: symptoms ?? this.symptoms,
      updates: updates ?? this.updates,
      medicalReports: medicalReports ?? this.medicalReports,
      expectedRecoveryDate: expectedRecoveryDate ?? this.expectedRecoveryDate,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  // Calculate recovery progress percentage
  double calculateRecoveryProgress() {
    if (status == InjuryStatus.resolved) return 100;
    if (expectedRecoveryDate == null) return 0;

    final totalRecoveryDays = expectedRecoveryDate!.difference(dateOccurred).inDays;
    final daysInRecovery = DateTime.now().difference(dateOccurred).inDays;
    
    final progress = (daysInRecovery / totalRecoveryDays) * 100;
    return progress.clamp(0, 100);
  }

  // Check if injury requires immediate attention
  bool requiresImmediateAttention() {
    return severity == InjurySeverity.critical || 
           (status == InjuryStatus.active && severity == InjurySeverity.severe);
  }

  // Get the latest update
  InjuryUpdate? get latestUpdate => 
    updates.isNotEmpty ? updates.reduce((a, b) => 
      a.date.isAfter(b.date) ? a : b) : null;

  @override
  String toString() {
    return 'Injury(type: $type, status: $status, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Injury && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class InjuryUpdate {
  final String id;
  final DateTime date;
  final String note;
  final InjuryStatus newStatus;
  final String? updatedBy;
  final Map<String, dynamic>? attachments;

  InjuryUpdate({
    required this.id,
    required this.date,
    required this.note,
    required this.newStatus,
    this.updatedBy,
    this.attachments,
  });

  factory InjuryUpdate.fromJson(Map<String, dynamic> json) {
    return InjuryUpdate(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      newStatus: InjuryStatus.values.firstWhere(
        (e) => e.toString() == 'InjuryStatus.${json['newStatus']}',
      ),
      updatedBy: json['updatedBy'] as String?,
      attachments: json['attachments'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'note': note,
      'newStatus': newStatus.toString().split('.').last,
      'updatedBy': updatedBy,
      'attachments': attachments,
    };
  }
}