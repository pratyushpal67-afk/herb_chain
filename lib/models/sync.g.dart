// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionEventSync _$CollectionEventSyncFromJson(Map<String, dynamic> json) =>
    CollectionEventSync(
      id: (json['id'] as num).toInt(),
      eventId: json['eventId'] as String,
      batchId: json['batchId'] as String,
      herbName: json['herbName'] as String,
      collectorName: json['collectorName'] as String,
      quantityKg: json['quantityKg'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      gpsAccuracyM: json['gpsAccuracyM'] as String,
      capturedAt: json['capturedAt'] as String,
      clientEventId: json['clientEventId'] as String?,
      syncStatus: json['syncStatus'] as String,
      localDataJson: json['localDataJson'] as Map<String, dynamic>,
      lastSyncAttempt: json['lastSyncAttempt'] as String?,
      syncError: json['syncError'] as String?,
      syncedAt: json['syncedAt'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CollectionEventSyncToJson(
  CollectionEventSync instance,
) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'batchId': instance.batchId,
  'herbName': instance.herbName,
  'collectorName': instance.collectorName,
  'quantityKg': instance.quantityKg,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'gpsAccuracyM': instance.gpsAccuracyM,
  'capturedAt': instance.capturedAt,
  'clientEventId': instance.clientEventId,
  'syncStatus': instance.syncStatus,
  'localDataJson': instance.localDataJson,
  'lastSyncAttempt': instance.lastSyncAttempt,
  'syncError': instance.syncError,
  'syncedAt': instance.syncedAt,
  'createdAt': instance.createdAt,
};

SyncLog _$SyncLogFromJson(Map<String, dynamic> json) => SyncLog(
  id: (json['id'] as num).toInt(),
  syncId: json['syncId'] as String,
  collector: (json['collector'] as num).toInt(),
  collectorName: json['collectorName'] as String,
  syncType: json['syncType'] as String,
  status: json['status'] as String,
  eventsProcessed: (json['eventsProcessed'] as num).toInt(),
  eventsSynced: (json['eventsSynced'] as num).toInt(),
  eventsFailed: (json['eventsFailed'] as num).toInt(),
  eventsConflicts: (json['eventsConflicts'] as num).toInt(),
  startedAt: json['startedAt'] as String,
  completedAt: json['completedAt'] as String?,
  errorSummary: json['errorSummary'] as String,
  metadataJson: json['metadataJson'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SyncLogToJson(SyncLog instance) => <String, dynamic>{
  'id': instance.id,
  'syncId': instance.syncId,
  'collector': instance.collector,
  'collectorName': instance.collectorName,
  'syncType': instance.syncType,
  'status': instance.status,
  'eventsProcessed': instance.eventsProcessed,
  'eventsSynced': instance.eventsSynced,
  'eventsFailed': instance.eventsFailed,
  'eventsConflicts': instance.eventsConflicts,
  'startedAt': instance.startedAt,
  'completedAt': instance.completedAt,
  'errorSummary': instance.errorSummary,
  'metadataJson': instance.metadataJson,
};

PendingSyncResponse _$PendingSyncResponseFromJson(Map<String, dynamic> json) =>
    PendingSyncResponse(
      collectionEvents: (json['collectionEvents'] as List<dynamic>)
          .map((e) => CollectionEventSync.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingCount: (json['pendingCount'] as num).toInt(),
      lastSync: json['lastSync'] as String?,
    );

Map<String, dynamic> _$PendingSyncResponseToJson(
  PendingSyncResponse instance,
) => <String, dynamic>{
  'collectionEvents': instance.collectionEvents.map((e) => e.toJson()).toList(),
  'pendingCount': instance.pendingCount,
  'lastSync': instance.lastSync,
};

SyncResult _$SyncResultFromJson(Map<String, dynamic> json) => SyncResult(
  success: json['success'] as bool,
  syncId: json['syncId'] as String,
  eventsSynced: (json['eventsSynced'] as num).toInt(),
  eventsFailed: (json['eventsFailed'] as num).toInt(),
  eventsConflicts: (json['eventsConflicts'] as num).toInt(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
  completedAt: json['completedAt'] as String,
);

Map<String, dynamic> _$SyncResultToJson(SyncResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'syncId': instance.syncId,
      'eventsSynced': instance.eventsSynced,
      'eventsFailed': instance.eventsFailed,
      'eventsConflicts': instance.eventsConflicts,
      'errors': instance.errors,
      'completedAt': instance.completedAt,
    };

SyncCollectionRequest _$SyncCollectionRequestFromJson(
  Map<String, dynamic> json,
) => SyncCollectionRequest(
  events: (json['events'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$SyncCollectionRequestToJson(
  SyncCollectionRequest instance,
) => <String, dynamic>{'events': instance.events};
