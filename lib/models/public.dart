import 'package:json_annotation/json_annotation.dart';
import 'lab.dart';

part 'public.g.dart';

@JsonSerializable()
class PublicBatch {
  final String batchId;
  final PublicHerb herb;
  final PublicCollector collector;
  final String weightKg;
  final String latitude;
  final String longitude;
  final String accuracyMeters;
  final String status;
  final String createdAt;
  final List<PublicLabReport> labReports;
  final List<PublicProcessingEvent> processingEvents;
  final List<PublicManufacturingEvent> manufacturingEvents;
  final List<PublicBatchEvent> batchEvents;

  PublicBatch({
    required this.batchId,
    required this.herb,
    required this.collector,
    required this.weightKg,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.status,
    required this.createdAt,
    required this.labReports,
    required this.processingEvents,
    required this.manufacturingEvents,
    required this.batchEvents,
  });

  factory PublicBatch.fromJson(Map<String, dynamic> json) => _$PublicBatchFromJson(json);
  Map<String, dynamic> toJson() => _$PublicBatchToJson(this);
}

@JsonSerializable()
class PublicHerb {
  final String herbId;
  final String commonName;
  final String botanicalName;
  final String family;
  final String plantPart;

  PublicHerb({
    required this.herbId,
    required this.commonName,
    required this.botanicalName,
    required this.family,
    required this.plantPart,
  });

  factory PublicHerb.fromJson(Map<String, dynamic> json) => _$PublicHerbFromJson(json);
  Map<String, dynamic> toJson() => _$PublicHerbToJson(this);
}

@JsonSerializable()
class PublicCollector {
  final String nodeId;
  final String name;
  final String region;

  PublicCollector({
    required this.nodeId,
    required this.name,
    required this.region,
  });

  factory PublicCollector.fromJson(Map<String, dynamic> json) => _$PublicCollectorFromJson(json);
  Map<String, dynamic> toJson() => _$PublicCollectorToJson(this);
}

@JsonSerializable()
class PublicLabReport {
  final String reportId;
  final String sampleName;
  final String botanicalName;
  final String sampleType;
  final String collectionDate;
  final String receivedDate;
  final String testDate;
  final String overallResult;
  final String notes;
  final String labName;
  final List<LabTestResult> testResults;

  PublicLabReport({
    required this.reportId,
    required this.sampleName,
    required this.botanicalName,
    required this.sampleType,
    required this.collectionDate,
    required this.receivedDate,
    required this.testDate,
    required this.overallResult,
    required this.notes,
    required this.labName,
    required this.testResults,
  });

  factory PublicLabReport.fromJson(Map<String, dynamic> json) => _$PublicLabReportFromJson(json);
  Map<String, dynamic> toJson() => _$PublicLabReportToJson(this);

  bool get isPassed => overallResult == 'pass';
}

@JsonSerializable()
class PublicProcessingEvent {
  final String processingId;
  final String facilityName;
  final String processType;
  final String receivedQuantityKg;
  final String? processedQuantityKg;
  final String? lossQuantityKg;
  final String startedAt;
  final String? completedAt;
  final String status;

  PublicProcessingEvent({
    required this.processingId,
    required this.facilityName,
    required this.processType,
    required this.receivedQuantityKg,
    this.processedQuantityKg,
    this.lossQuantityKg,
    required this.startedAt,
    this.completedAt,
    required this.status,
  });

  factory PublicProcessingEvent.fromJson(Map<String, dynamic> json) => _$PublicProcessingEventFromJson(json);
  Map<String, dynamic> toJson() => _$PublicProcessingEventToJson(this);
}

@JsonSerializable()
class PublicManufacturingEvent {
  final String manufacturingId;
  final String manufacturerName;
  final String productType;
  final String inputQuantityKg;
  final String? outputQuantityKg;
  final String? lossQuantityKg;
  final String manufacturingDate;
  final String? completedAt;
  final String status;
  final String batchNumber;
  final String? expiryDate;

  PublicManufacturingEvent({
    required this.manufacturingId,
    required this.manufacturerName,
    required this.productType,
    required this.inputQuantityKg,
    this.outputQuantityKg,
    this.lossQuantityKg,
    required this.manufacturingDate,
    this.completedAt,
    required this.status,
    required this.batchNumber,
    this.expiryDate,
  });

  factory PublicManufacturingEvent.fromJson(Map<String, dynamic> json) => _$PublicManufacturingEventFromJson(json);
  Map<String, dynamic> toJson() => _$PublicManufacturingEventToJson(this);
}

@JsonSerializable()
class PublicBatchEvent {
  final String eventId;
  final String eventType;
  final String timestamp;
  final String status;
  final Map<String, dynamic> metadataJson;

  PublicBatchEvent({
    required this.eventId,
    required this.eventType,
    required this.timestamp,
    required this.status,
    required this.metadataJson,
  });

  factory PublicBatchEvent.fromJson(Map<String, dynamic> json) => _$PublicBatchEventFromJson(json);
  Map<String, dynamic> toJson() => _$PublicBatchEventToJson(this);
}

@JsonSerializable()
class PublicBatchJourney {
  final String batchId;
  final String currentStatus;
  final List<Map<String, dynamic>> journey;

  PublicBatchJourney({
    required this.batchId,
    required this.currentStatus,
    required this.journey,
  });

  factory PublicBatchJourney.fromJson(Map<String, dynamic> json) => _$PublicBatchJourneyFromJson(json);
  Map<String, dynamic> toJson() => _$PublicBatchJourneyToJson(this);
}

@JsonSerializable()
class PublicBatchVerify {
  final String batchId;
  final String herb;
  final String botanicalName;
  final String? origin;
  final String? collectorNode;
  final String collectionDate;
  final String status;
  final bool verified;
  final bool labTestPassed;
  final bool manufacturingCompleted;
  final String hash;

  PublicBatchVerify({
    required this.batchId,
    required this.herb,
    required this.botanicalName,
    this.origin,
    this.collectorNode,
    required this.collectionDate,
    required this.status,
    required this.verified,
    required this.labTestPassed,
    required this.manufacturingCompleted,
    required this.hash,
  });

  factory PublicBatchVerify.fromJson(Map<String, dynamic> json) => _$PublicBatchVerifyFromJson(json);
  Map<String, dynamic> toJson() => _$PublicBatchVerifyToJson(this);
}

@JsonSerializable()
class PublicBatchQr {
  final String batchId;
  final String qrCodeBase64;
  final Map<String, dynamic> qrData;

  PublicBatchQr({
    required this.batchId,
    required this.qrCodeBase64,
    required this.qrData,
  });

  factory PublicBatchQr.fromJson(Map<String, dynamic> json) => _$PublicBatchQrFromJson(json);
  Map<String, dynamic> toJson() => _$PublicBatchQrToJson(this);
}