import 'package:json_annotation/json_annotation.dart';

part 'lab.g.dart';

@JsonSerializable()
class LabReport {
  final int id;
  final String reportId;
  final int batch;
  final String batchId;
  final int lab;
  final String labName;
  final String sampleName;
  final String botanicalName;
  final String sampleType;
  final String collectionDate;
  final String receivedDate;
  final String testDate;
  final String overallResult;
  final String? reportFile;
  final String? certificateFile;
  final String notes;
  final List<LabTestResult> testResults;
  final String createdAt;

  LabReport({
    required this.id,
    required this.reportId,
    required this.batch,
    required this.batchId,
    required this.lab,
    required this.labName,
    required this.sampleName,
    required this.botanicalName,
    required this.sampleType,
    required this.collectionDate,
    required this.receivedDate,
    required this.testDate,
    required this.overallResult,
    this.reportFile,
    this.certificateFile,
    required this.notes,
    required this.testResults,
    required this.createdAt,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) => _$LabReportFromJson(json);
  Map<String, dynamic> toJson() => _$LabReportToJson(this);

  bool get isPassed => overallResult == 'pass';
  bool get isFailed => overallResult == 'fail';
  bool get isPending => overallResult == 'pending';
}

@JsonSerializable()
class LabTestResult {
  final int id;
  final String testId;
  final int report;
  final String reportId;
  final String testName;
  final String testMethod;
  final String? resultValue;
  final String unit;
  final String referenceRange;
  final String status;
  final String testedAt;
  final String notes;
  final String createdAt;

  LabTestResult({
    required this.id,
    required this.testId,
    required this.report,
    required this.reportId,
    required this.testName,
    required this.testMethod,
    this.resultValue,
    required this.unit,
    required this.referenceRange,
    required this.status,
    required this.testedAt,
    required this.notes,
    required this.createdAt,
  });

  factory LabTestResult.fromJson(Map<String, dynamic> json) => _$LabTestResultFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestResultToJson(this);

  bool get isPassed => status == 'pass';
  bool get isFailed => status == 'fail';
  bool get isPending => status == 'pending';

  String get formattedValue {
    if (resultValue == null) return 'N/A';
    return '$resultValue $unit'.trim();
  }
}

@JsonSerializable()
class LabTest {
  final int id;
  final int batch;
  final String batchId;
  final int? testedBy;
  final String? testedByName;
  final String testDate;
  final String result;
  final String? moistureContent;
  final String? purityPercentage;
  final String? heavyMetalsPpm;
  final String? pesticideResiduePpm;
  final String? microbialCountCfu;
  final String notes;
  final String? certificateFile;
  final String createdAt;

  LabTest({
    required this.id,
    required this.batch,
    required this.batchId,
    this.testedBy,
    this.testedByName,
    required this.testDate,
    required this.result,
    this.moistureContent,
    this.purityPercentage,
    this.heavyMetalsPpm,
    this.pesticideResiduePpm,
    this.microbialCountCfu,
    required this.notes,
    this.certificateFile,
    required this.createdAt,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) => _$LabTestFromJson(json);
  Map<String, dynamic> toJson() => _$LabTestToJson(this);

  bool get isPassed => result == 'pass';
  bool get isFailed => result == 'fail';
  bool get isPending => result == 'pending';
}