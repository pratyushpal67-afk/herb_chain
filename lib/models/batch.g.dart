// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Batch _$BatchFromJson(Map<String, dynamic> json) => Batch(
  id: (json['id'] as num).toInt(),
  batchId: json['batchId'] as String,
  herb: Herb.fromJson(json['herb'] as Map<String, dynamic>),
  collector: Collector.fromJson(json['collector'] as Map<String, dynamic>),
  weightKg: json['weightKg'] as String,
  latitude: json['latitude'] as String,
  longitude: json['longitude'] as String,
  accuracyMeters: json['accuracyMeters'] as String,
  notes: json['notes'] as String,
  image: json['image'] as String?,
  status: json['status'] as String,
  labTest: json['labTest'] == null
      ? null
      : LabTest.fromJson(json['labTest'] as Map<String, dynamic>),
  collectionEvents: (json['collectionEvents'] as List<dynamic>)
      .map((e) => CollectionEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  batchEvents: (json['batchEvents'] as List<dynamic>)
      .map((e) => BatchEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  processingEvents: (json['processingEvents'] as List<dynamic>)
      .map((e) => ProcessingEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  manufacturingEvents: (json['manufacturingEvents'] as List<dynamic>)
      .map((e) => ManufacturingEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  labReports: (json['labReports'] as List<dynamic>)
      .map((e) => LabReport.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$BatchToJson(Batch instance) => <String, dynamic>{
  'id': instance.id,
  'batchId': instance.batchId,
  'herb': instance.herb.toJson(),
  'collector': instance.collector.toJson(),
  'weightKg': instance.weightKg,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracyMeters': instance.accuracyMeters,
  'notes': instance.notes,
  'image': instance.image,
  'status': instance.status,
  'labTest': instance.labTest?.toJson(),
  'collectionEvents': instance.collectionEvents.map((e) => e.toJson()).toList(),
  'batchEvents': instance.batchEvents.map((e) => e.toJson()).toList(),
  'processingEvents': instance.processingEvents.map((e) => e.toJson()).toList(),
  'manufacturingEvents': instance.manufacturingEvents
      .map((e) => e.toJson())
      .toList(),
  'labReports': instance.labReports.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt,
};

Herb _$HerbFromJson(Map<String, dynamic> json) => Herb(
  id: (json['id'] as num).toInt(),
  herbId: json['herbId'] as String,
  commonName: json['commonName'] as String,
  botanicalName: json['botanicalName'] as String,
  family: json['family'] as String,
  plantPart: json['plantPart'] as String,
  status: json['status'] as String,
  displayName: json['displayName'] as String,
);

Map<String, dynamic> _$HerbToJson(Herb instance) => <String, dynamic>{
  'id': instance.id,
  'herbId': instance.herbId,
  'commonName': instance.commonName,
  'botanicalName': instance.botanicalName,
  'family': instance.family,
  'plantPart': instance.plantPart,
  'status': instance.status,
  'displayName': instance.displayName,
};

Collector _$CollectorFromJson(Map<String, dynamic> json) => Collector(
  id: (json['id'] as num).toInt(),
  nodeId: json['nodeId'] as String,
  name: json['name'] as String,
  region: json['region'] as String,
);

Map<String, dynamic> _$CollectorToJson(Collector instance) => <String, dynamic>{
  'id': instance.id,
  'nodeId': instance.nodeId,
  'name': instance.name,
  'region': instance.region,
};

CollectionEvent _$CollectionEventFromJson(Map<String, dynamic> json) =>
    CollectionEvent(
      id: (json['id'] as num).toInt(),
      eventId: json['eventId'] as String,
      batch: (json['batch'] as num).toInt(),
      batchId: json['batchId'] as String,
      collector: (json['collector'] as num).toInt(),
      collectorName: json['collectorName'] as String,
      herb: (json['herb'] as num).toInt(),
      herbName: json['herbName'] as String,
      quantityKg: json['quantityKg'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      gpsAccuracyM: json['gpsAccuracyM'] as String,
      capturedAt: json['capturedAt'] as String,
      clientEventId: json['clientEventId'] as String?,
      syncStatus: json['syncStatus'] as String,
      photos: (json['photos'] as List<dynamic>)
          .map((e) => CollectionPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CollectionEventToJson(CollectionEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'batch': instance.batch,
      'batchId': instance.batchId,
      'collector': instance.collector,
      'collectorName': instance.collectorName,
      'herb': instance.herb,
      'herbName': instance.herbName,
      'quantityKg': instance.quantityKg,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'gpsAccuracyM': instance.gpsAccuracyM,
      'capturedAt': instance.capturedAt,
      'clientEventId': instance.clientEventId,
      'syncStatus': instance.syncStatus,
      'photos': instance.photos.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
    };

CollectionPhoto _$CollectionPhotoFromJson(Map<String, dynamic> json) =>
    CollectionPhoto(
      id: (json['id'] as num).toInt(),
      photoId: json['photoId'] as String,
      fileUrl: json['fileUrl'] as String,
      fileHash: json['fileHash'] as String,
      capturedAt: json['capturedAt'] as String,
      uploadedAt: json['uploadedAt'] as String,
    );

Map<String, dynamic> _$CollectionPhotoToJson(CollectionPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photoId': instance.photoId,
      'fileUrl': instance.fileUrl,
      'fileHash': instance.fileHash,
      'capturedAt': instance.capturedAt,
      'uploadedAt': instance.uploadedAt,
    };

BatchEvent _$BatchEventFromJson(Map<String, dynamic> json) => BatchEvent(
  id: (json['id'] as num).toInt(),
  eventId: json['eventId'] as String,
  batch: (json['batch'] as num).toInt(),
  eventType: json['eventType'] as String,
  actor: (json['actor'] as num).toInt(),
  actorName: json['actorName'] as String,
  timestamp: json['timestamp'] as String,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  status: json['status'] as String,
  metadataJson: json['metadataJson'] as Map<String, dynamic>,
  transactionHash: json['transactionHash'] as String,
);

Map<String, dynamic> _$BatchEventToJson(BatchEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'batch': instance.batch,
      'eventType': instance.eventType,
      'actor': instance.actor,
      'actorName': instance.actorName,
      'timestamp': instance.timestamp,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'metadataJson': instance.metadataJson,
      'transactionHash': instance.transactionHash,
    };
