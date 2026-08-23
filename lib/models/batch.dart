import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'lab.dart';
import 'processing.dart';
import 'manufacturing.dart';

part 'batch.g.dart';

@JsonSerializable(explicitToJson: true)
class Batch {
  final int id;
  final String batchId;
  final Herb herb;
  final Collector collector;
  final String weightKg;
  final String latitude;
  final String longitude;
  final String accuracyMeters;
  final String notes;
  final String? image;
  final String status;
  final LabTest? labTest;
  final List<CollectionEvent> collectionEvents;
  final List<BatchEvent> batchEvents;
  final List<ProcessingEvent> processingEvents;
  final List<ManufacturingEvent> manufacturingEvents;
  final List<LabReport> labReports;
  final String createdAt;

  Batch({
    required this.id,
    required this.batchId,
    required this.herb,
    required this.collector,
    required this.weightKg,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.notes,
    this.image,
    required this.status,
    this.labTest,
    required this.collectionEvents,
    required this.batchEvents,
    required this.processingEvents,
    required this.manufacturingEvents,
    required this.labReports,
    required this.createdAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);
  Map<String, dynamic> toJson() => _$BatchToJson(this);

  String get formattedWeight => '${double.parse(weightKg).toStringAsFixed(3)} kg';
  String get formattedCoordinates => '${double.parse(latitude).toStringAsFixed(6)}° N, ${double.parse(longitude).toStringAsFixed(6)}° E';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  bool get isLabTesting => status == 'lab_testing';
  bool get isRecorded => status == 'recorded';
}

@JsonSerializable()
class Herb {
  final int id;
  final String herbId;
  final String commonName;
  final String botanicalName;
  final String family;
  final String plantPart;
  final String status;
  final String displayName;

  Herb({
    required this.id,
    required this.herbId,
    required this.commonName,
    required this.botanicalName,
    required this.family,
    required this.plantPart,
    required this.status,
    required this.displayName,
  });

  factory Herb.fromJson(Map<String, dynamic> json) => _$HerbFromJson(json);
  Map<String, dynamic> toJson() => _$HerbToJson(this);
}

@JsonSerializable()
class Collector {
  final int id;
  final String nodeId;
  final String name;
  final String region;

  Collector({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.region,
  });

  factory Collector.fromJson(Map<String, dynamic> json) => _$CollectorFromJson(json);
  Map<String, dynamic> toJson() => _$CollectorToJson(this);

  String get displayName => '$nodeId - $name ($region)';
}

@JsonSerializable()
class CollectionEvent {
  final int id;
  final String eventId;
  final int batch;
  final String batchId;
  final int collector;
  final String collectorName;
  final int herb;
  final String herbName;
  final String quantityKg;
  final String latitude;
  final String longitude;
  final String gpsAccuracyM;
  final String capturedAt;
  final String? clientEventId;
  final String syncStatus;
  final List<CollectionPhoto> photos;
  final String createdAt;

  CollectionEvent({
    required this.id,
    required this.eventId,
    required this.batch,
    required this.batchId,
    required this.collector,
    required this.collectorName,
    required this.herb,
    required this.herbName,
    required this.quantityKg,
    required this.latitude,
    required this.longitude,
    required this.gpsAccuracyM,
    required this.capturedAt,
    this.clientEventId,
    required this.syncStatus,
    required this.photos,
    required this.createdAt,
  });

  factory CollectionEvent.fromJson(Map<String, dynamic> json) => _$CollectionEventFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionEventToJson(this);
}

@JsonSerializable()
class CollectionPhoto {
  final int id;
  final String photoId;
  final String fileUrl;
  final String fileHash;
  final String capturedAt;
  final String uploadedAt;

  CollectionPhoto({
    required this.id,
    required this.photoId,
    required this.fileUrl,
    required this.fileHash,
    required this.capturedAt,
    required this.uploadedAt,
  });

  factory CollectionPhoto.fromJson(Map<String, dynamic> json) => _$CollectionPhotoFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionPhotoToJson(this);
}

@JsonSerializable()
class BatchEvent {
  final int id;
  final String eventId;
  final int batch;
  final String eventType;
  final int actor;
  final String actorName;
  final String timestamp;
  final String? latitude;
  final String? longitude;
  final String status;
  final Map<String, dynamic> metadataJson;
  final String transactionHash;

  BatchEvent({
    required this.id,
    required this.eventId,
    required this.batch,
    required this.eventType,
    required this.actor,
    required this.actorName,
    required this.timestamp,
    this.latitude,
    this.longitude,
    required this.status,
    required this.metadataJson,
    required this.transactionHash,
  });

  factory BatchEvent.fromJson(Map<String, dynamic> json) => _$BatchEventFromJson(json);
  Map<String, dynamic> toJson() => _$BatchEventToJson(this);
}