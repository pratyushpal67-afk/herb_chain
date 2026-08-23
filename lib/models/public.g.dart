// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicBatch _$PublicBatchFromJson(Map<String, dynamic> json) => PublicBatch(
  batchId: json['batchId'] as String,
  herb: PublicHerb.fromJson(json['herb'] as Map<String, dynamic>),
  collector: PublicCollector.fromJson(
    json['collector'] as Map<String, dynamic>,
  ),
  weightKg: json['weightKg'] as String,
  latitude: json['latitude'] as String,
  longitude: json['longitude'] as String,
  accuracyMeters: json['accuracyMeters'] as String,
  status: json['status'] as String,
  createdAt: json['createdAt'] as String,
  labReports: (json['labReports'] as List<dynamic>)
      .map((e) => PublicLabReport.fromJson(e as Map<String, dynamic>))
      .toList(),
  processingEvents: (json['processingEvents'] as List<dynamic>)
      .map((e) => PublicProcessingEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  manufacturingEvents: (json['manufacturingEvents'] as List<dynamic>)
      .map((e) => PublicManufacturingEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  batchEvents: (json['batchEvents'] as List<dynamic>)
      .map((e) => PublicBatchEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PublicBatchToJson(
  PublicBatch instance,
) => <String, dynamic>{
  'batchId': instance.batchId,
  'herb': instance.herb.toJson(),
  'collector': instance.collector.toJson(),
  'weightKg': instance.weightKg,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracyMeters': instance.accuracyMeters,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'labReports': instance.labReports.map((e) => e.toJson()).toList(),
  'processingEvents': instance.processingEvents.map((e) => e.toJson()).toList(),
  'manufacturingEvents': instance.manufacturingEvents
      .map((e) => e.toJson())
      .toList(),
  'batchEvents': instance.batchEvents.map((e) => e.toJson()).toList(),
};

PublicHerb _$PublicHerbFromJson(Map<String, dynamic> json) => PublicHerb(
  herbId: json['herbId'] as String,
  commonName: json['commonName'] as String,
  botanicalName: json['botanicalName'] as String,
  family: json['family'] as String,
  plantPart: json['plantPart'] as String,
);

Map<String, dynamic> _$PublicHerbToJson(PublicHerb instance) =>
    <String, dynamic>{
      'herbId': instance.herbId,
      'commonName': instance.commonName,
      'botanicalName': instance.botanicalName,
      'family': instance.family,
      'plantPart': instance.plantPart,
    };

PublicCollector _$PublicCollectorFromJson(Map<String, dynamic> json) =>
    PublicCollector(
      nodeId: json['nodeId'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
    );

Map<String, dynamic> _$PublicCollectorToJson(PublicCollector instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'name': instance.name,
      'region': instance.region,
    };

PublicLabReport _$PublicLabReportFromJson(Map<String, dynamic> json) =>
    PublicLabReport(
      reportId: json['reportId'] as String,
      sampleName: json['sampleName'] as String,
      botanicalName: json['botanicalName'] as String,
      sampleType: json['sampleType'] as String,
      collectionDate: json['collectionDate'] as String,
      receivedDate: json['receivedDate'] as String,
      testDate: json['testDate'] as String,
      overallResult: json['overallResult'] as String,
      notes: json['notes'] as String,
      labName: json['labName'] as String,
      testResults: (json['testResults'] as List<dynamic>)
          .map((e) => LabTestResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PublicLabReportToJson(PublicLabReport instance) =>
    <String, dynamic>{
      'reportId': instance.reportId,
      'sampleName': instance.sampleName,
      'botanicalName': instance.botanicalName,
      'sampleType': instance.sampleType,
      'collectionDate': instance.collectionDate,
      'receivedDate': instance.receivedDate,
      'testDate': instance.testDate,
      'overallResult': instance.overallResult,
      'notes': instance.notes,
      'labName': instance.labName,
      'testResults': instance.testResults.map((e) => e.toJson()).toList(),
    };

PublicProcessingEvent _$PublicProcessingEventFromJson(
  Map<String, dynamic> json,
) => PublicProcessingEvent(
  processingId: json['processingId'] as String,
  facilityName: json['facilityName'] as String,
  processType: json['processType'] as String,
  receivedQuantityKg: json['receivedQuantityKg'] as String,
  processedQuantityKg: json['processedQuantityKg'] as String?,
  lossQuantityKg: json['lossQuantityKg'] as String?,
  startedAt: json['startedAt'] as String,
  completedAt: json['completedAt'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$PublicProcessingEventToJson(
  PublicProcessingEvent instance,
) => <String, dynamic>{
  'processingId': instance.processingId,
  'facilityName': instance.facilityName,
  'processType': instance.processType,
  'receivedQuantityKg': instance.receivedQuantityKg,
  'processedQuantityKg': instance.processedQuantityKg,
  'lossQuantityKg': instance.lossQuantityKg,
  'startedAt': instance.startedAt,
  'completedAt': instance.completedAt,
  'status': instance.status,
};

PublicManufacturingEvent _$PublicManufacturingEventFromJson(
  Map<String, dynamic> json,
) => PublicManufacturingEvent(
  manufacturingId: json['manufacturingId'] as String,
  manufacturerName: json['manufacturerName'] as String,
  productType: json['productType'] as String,
  inputQuantityKg: json['inputQuantityKg'] as String,
  outputQuantityKg: json['outputQuantityKg'] as String?,
  lossQuantityKg: json['lossQuantityKg'] as String?,
  manufacturingDate: json['manufacturingDate'] as String,
  completedAt: json['completedAt'] as String?,
  status: json['status'] as String,
  batchNumber: json['batchNumber'] as String,
  expiryDate: json['expiryDate'] as String?,
);

Map<String, dynamic> _$PublicManufacturingEventToJson(
  PublicManufacturingEvent instance,
) => <String, dynamic>{
  'manufacturingId': instance.manufacturingId,
  'manufacturerName': instance.manufacturerName,
  'productType': instance.productType,
  'inputQuantityKg': instance.inputQuantityKg,
  'outputQuantityKg': instance.outputQuantityKg,
  'lossQuantityKg': instance.lossQuantityKg,
  'manufacturingDate': instance.manufacturingDate,
  'completedAt': instance.completedAt,
  'status': instance.status,
  'batchNumber': instance.batchNumber,
  'expiryDate': instance.expiryDate,
};

PublicBatchEvent _$PublicBatchEventFromJson(Map<String, dynamic> json) =>
    PublicBatchEvent(
      eventId: json['eventId'] as String,
      eventType: json['eventType'] as String,
      timestamp: json['timestamp'] as String,
      status: json['status'] as String,
      metadataJson: json['metadataJson'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PublicBatchEventToJson(PublicBatchEvent instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventType': instance.eventType,
      'timestamp': instance.timestamp,
      'status': instance.status,
      'metadataJson': instance.metadataJson,
    };

PublicBatchJourney _$PublicBatchJourneyFromJson(Map<String, dynamic> json) =>
    PublicBatchJourney(
      batchId: json['batchId'] as String,
      currentStatus: json['currentStatus'] as String,
      journey: (json['journey'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$PublicBatchJourneyToJson(PublicBatchJourney instance) =>
    <String, dynamic>{
      'batchId': instance.batchId,
      'currentStatus': instance.currentStatus,
      'journey': instance.journey,
    };

PublicBatchVerify _$PublicBatchVerifyFromJson(Map<String, dynamic> json) =>
    PublicBatchVerify(
      batchId: json['batchId'] as String,
      herb: json['herb'] as String,
      botanicalName: json['botanicalName'] as String,
      origin: json['origin'] as String?,
      collectorNode: json['collectorNode'] as String?,
      collectionDate: json['collectionDate'] as String,
      status: json['status'] as String,
      verified: json['verified'] as bool,
      labTestPassed: json['labTestPassed'] as bool,
      manufacturingCompleted: json['manufacturingCompleted'] as bool,
      hash: json['hash'] as String,
    );

Map<String, dynamic> _$PublicBatchVerifyToJson(PublicBatchVerify instance) =>
    <String, dynamic>{
      'batchId': instance.batchId,
      'herb': instance.herb,
      'botanicalName': instance.botanicalName,
      'origin': instance.origin,
      'collectorNode': instance.collectorNode,
      'collectionDate': instance.collectionDate,
      'status': instance.status,
      'verified': instance.verified,
      'labTestPassed': instance.labTestPassed,
      'manufacturingCompleted': instance.manufacturingCompleted,
      'hash': instance.hash,
    };

PublicBatchQr _$PublicBatchQrFromJson(Map<String, dynamic> json) =>
    PublicBatchQr(
      batchId: json['batchId'] as String,
      qrCodeBase64: json['qrCodeBase64'] as String,
      qrData: json['qrData'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PublicBatchQrToJson(PublicBatchQr instance) =>
    <String, dynamic>{
      'batchId': instance.batchId,
      'qrCodeBase64': instance.qrCodeBase64,
      'qrData': instance.qrData,
    };
