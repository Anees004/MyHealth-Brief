import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/health_brief_entity.dart';

/// Health Brief model for data layer
class HealthBriefModel extends HealthBriefEntity {
  const HealthBriefModel({
    required super.id,
    required super.userId,
    required super.title,
    super.labSource,
    required super.reportDate,
    super.documentUrl,
    required super.geminiSummary,
    required super.findings,
    required super.appointmentQuestions,
    required super.createdAt,
  });

  /// Create from Firestore document
  factory HealthBriefModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthBriefModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      labSource: data['labSource'],
      reportDate: data['reportDate'] != null
          ? (data['reportDate'] as Timestamp).toDate()
          : DateTime.now(),
      documentUrl: data['documentUrl'],
      geminiSummary: data['geminiSummary'] ?? '',
      findings: (data['findings'] as List<dynamic>?)
              ?.map((f) => FindingModel.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      appointmentQuestions:
          (data['appointmentQuestions'] as List<dynamic>?)?.cast<String>() ??
              [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create from Gemini response JSON
  factory HealthBriefModel.fromGeminiResponse({
    required String id,
    required String userId,
    required Map<String, dynamic> json,
    String? documentUrl,
  }) {
    return HealthBriefModel(
      id: id,
      userId: userId,
      title: json['title'] ?? 'Health Report',
      labSource: json['labSource'],
      reportDate: json['reportDate'] != null
          ? DateTime.tryParse(json['reportDate']) ?? DateTime.now()
          : DateTime.now(),
      documentUrl: documentUrl,
      geminiSummary: json['summary'] ?? '',
      findings: (json['findings'] as List<dynamic>?)
              ?.map((f) => FindingModel.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      appointmentQuestions:
          (json['appointmentQuestions'] as List<dynamic>?)?.cast<String>() ??
              [],
      createdAt: DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'labSource': labSource,
      'reportDate': Timestamp.fromDate(reportDate),
      'documentUrl': documentUrl,
      'geminiSummary': geminiSummary,
      'findings': findings
          .map((f) => (f as FindingModel).toMap())
          .toList(),
      'appointmentQuestions': appointmentQuestions,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to entity
  HealthBriefEntity toEntity() {
    return HealthBriefEntity(
      id: id,
      userId: userId,
      title: title,
      labSource: labSource,
      reportDate: reportDate,
      documentUrl: documentUrl,
      geminiSummary: geminiSummary,
      findings: findings,
      appointmentQuestions: appointmentQuestions,
      createdAt: createdAt,
    );
  }
}

/// Finding model for data layer
class FindingModel extends FindingEntity {
  const FindingModel({
    required super.name,
    required super.value,
    required super.unit,
    required super.status,
    required super.minRange,
    required super.maxRange,
    super.clinicalSignificance,
    super.doctorQuestions,
  });

  /// Create from map
  factory FindingModel.fromMap(Map<String, dynamic> map) {
    return FindingModel(
      name: map['name'] ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      status: FindingStatus.fromString(map['status'] ?? 'normal'),
      minRange: (map['minRange'] as num?)?.toDouble() ?? 0.0,
      maxRange: (map['maxRange'] as num?)?.toDouble() ?? 100.0,
      clinicalSignificance: map['clinicalSignificance'],
      doctorQuestions:
          (map['doctorQuestions'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'status': status.name,
      'minRange': minRange,
      'maxRange': maxRange,
      'clinicalSignificance': clinicalSignificance,
      'doctorQuestions': doctorQuestions,
    };
  }
}
