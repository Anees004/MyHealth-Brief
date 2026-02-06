import 'package:equatable/equatable.dart';

/// Health Brief entity containing analysis results
class HealthBriefEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? labSource;
  final DateTime reportDate;
  final String? documentUrl;
  final String geminiSummary;
  final List<FindingEntity> findings;
  final List<String> appointmentQuestions;
  final DateTime createdAt;

  const HealthBriefEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.labSource,
    required this.reportDate,
    this.documentUrl,
    required this.geminiSummary,
    required this.findings,
    required this.appointmentQuestions,
    required this.createdAt,
  });

  /// Get abnormal findings count
  int get abnormalFindingsCount {
    return findings.where((f) => f.status != FindingStatus.normal).length;
  }

  /// Get findings by status
  List<FindingEntity> findingsByStatus(FindingStatus status) {
    return findings.where((f) => f.status == status).toList();
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        labSource,
        reportDate,
        documentUrl,
        geminiSummary,
        findings,
        appointmentQuestions,
        createdAt,
      ];
}

/// Individual finding from a health report
class FindingEntity extends Equatable {
  final String name;
  final double value;
  final String unit;
  final FindingStatus status;
  final double minRange;
  final double maxRange;
  final String? clinicalSignificance;
  final List<String>? doctorQuestions;

  const FindingEntity({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.minRange,
    required this.maxRange,
    this.clinicalSignificance,
    this.doctorQuestions,
  });

  /// Calculate percentage of where value falls in range
  double get percentageInRange {
    final range = maxRange - minRange;
    if (range <= 0) return 0.5;

    final position = (value - minRange) / range;
    return position.clamp(0.0, 1.0);
  }

  /// Get actual position for progress bar (can go outside 0-1)
  double get actualPosition {
    final range = maxRange - minRange;
    if (range <= 0) return 0.5;

    return (value - minRange) / range;
  }

  @override
  List<Object?> get props => [
        name,
        value,
        unit,
        status,
        minRange,
        maxRange,
        clinicalSignificance,
        doctorQuestions,
      ];
}

/// Finding status enum
enum FindingStatus {
  low,
  normal,
  borderline,
  high;

  /// Parse from string
  static FindingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return FindingStatus.low;
      case 'normal':
        return FindingStatus.normal;
      case 'borderline':
        return FindingStatus.borderline;
      case 'high':
        return FindingStatus.high;
      default:
        return FindingStatus.normal;
    }
  }

  /// Convert to display string
  String get displayName {
    switch (this) {
      case FindingStatus.low:
        return 'Low';
      case FindingStatus.normal:
        return 'Normal';
      case FindingStatus.borderline:
        return 'Borderline';
      case FindingStatus.high:
        return 'High';
    }
  }
}
