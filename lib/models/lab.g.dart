// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabReport _$LabReportFromJson(Map<String, dynamic> json) => LabReport(
  id: (json['id'] as num).toInt(),
  reportId: json['reportId'] as String,
  batch: (json['batch'] as num).toInt(),
  batchId: json['batchId'] as String,
  lab: (json['lab'] as num).toInt(),
  labName: json['labName'] as String,
  sampleName: json['sampleName'] as String,
  botanicalName: json['botanicalName'] as String,
  sampleType: json['sampleType'] as String,
  collectionDate: json['collectionDate'] as String,
  receivedDate: json['receivedDate'] as String,
  testDate: json['testDate'] as String,
  overallResult: json['overallResult'] as String,
  reportFile: json['reportFile'] as String?,
  certificateFile: json['certificateFile'] as String?,
  notes: json['notes'] as String,
  testResults: (json['testResults'] as List<dynamic>)
      .map((e) => LabTestResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$LabReportToJson(LabReport instance) => <String, dynamic>{
  'id': instance.id,
  'reportId': instance.reportId,
  'batch': instance.batch,
  'batchId': instance.batchId,
  'lab': instance.lab,
  'labName': instance.labName,
  'sampleName': instance.sampleName,
  'botanicalName': instance.botanicalName,
  'sampleType': instance.sampleType,
  'collectionDate': instance.collectionDate,
  'receivedDate': instance.receivedDate,
  'testDate': instance.testDate,
  'overallResult': instance.overallResult,
  'reportFile': instance.reportFile,
  'certificateFile': instance.certificateFile,
  'notes': instance.notes,
  'testResults': instance.testResults.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt,
};

LabTestResult _$LabTestResultFromJson(Map<String, dynamic> json) =>
    LabTestResult(
      id: (json['id'] as num).toInt(),
      testId: json['testId'] as String,
      report: (json['report'] as num).toInt(),
      reportId: json['reportId'] as String,
      testName: json['testName'] as String,
      testMethod: json['testMethod'] as String,
      resultValue: json['resultValue'] as String?,
      unit: json['unit'] as String,
      referenceRange: json['referenceRange'] as String,
      status: json['status'] as String,
      testedAt: json['testedAt'] as String,
      notes: json['notes'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$LabTestResultToJson(LabTestResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'testId': instance.testId,
      'report': instance.report,
      'reportId': instance.reportId,
      'testName': instance.testName,
      'testMethod': instance.testMethod,
      'resultValue': instance.resultValue,
      'unit': instance.unit,
      'referenceRange': instance.referenceRange,
      'status': instance.status,
      'testedAt': instance.testedAt,
      'notes': instance.notes,
      'createdAt': instance.createdAt,
    };

LabTest _$LabTestFromJson(Map<String, dynamic> json) => LabTest(
  id: (json['id'] as num).toInt(),
  batch: (json['batch'] as num).toInt(),
  batchId: json['batchId'] as String,
  testedBy: (json['testedBy'] as num?)?.toInt(),
  testedByName: json['testedByName'] as String?,
  testDate: json['testDate'] as String,
  result: json['result'] as String,
  moistureContent: json['moistureContent'] as String?,
  purityPercentage: json['purityPercentage'] as String?,
  heavyMetalsPpm: json['heavyMetalsPpm'] as String?,
  pesticideResiduePpm: json['pesticideResiduePpm'] as String?,
  microbialCountCfu: json['microbialCountCfu'] as String?,
  notes: json['notes'] as String,
  certificateFile: json['certificateFile'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$LabTestToJson(LabTest instance) => <String, dynamic>{
  'id': instance.id,
  'batch': instance.batch,
  'batchId': instance.batchId,
  'testedBy': instance.testedBy,
  'testedByName': instance.testedByName,
  'testDate': instance.testDate,
  'result': instance.result,
  'moistureContent': instance.moistureContent,
  'purityPercentage': instance.purityPercentage,
  'heavyMetalsPpm': instance.heavyMetalsPpm,
  'pesticideResiduePpm': instance.pesticideResiduePpm,
  'microbialCountCfu': instance.microbialCountCfu,
  'notes': instance.notes,
  'certificateFile': instance.certificateFile,
  'createdAt': instance.createdAt,
};
