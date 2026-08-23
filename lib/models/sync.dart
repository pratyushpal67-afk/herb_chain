import 'package:json_annotation/json_annotation.dart';
import 'batch.dart';

part 'sync.g.dart';

@JsonSerializable()
class CollectionEventSync {
  final int id;
  final String eventId;
  final String batchId;
  final String herbName;
  final String collectorName;
  final String quantityKg;
  final String latitude;
  final String longitude;
  final String gpsAccuracyM;
  final String capturedAt;
  final String? clientEventId;
  final String syncStatus;
  final Map<String, dynamic> localDataJson;
  final String? lastSyncAttempt;
  final String? syncError;
  final String? syncedAt;
  final String createdAt;

  CollectionEventSync({
    required this.id,
    required this.eventId,
    required this.batchId,
    required this.herbName,
    required this.collectorName,
    required this.quantityKg,
    required this.latitude,
    required this.longitude,
    required this.gpsAccuracyM,
    required this.capturedAt,
    this.clientEventId,
    required this.syncStatus,
    required this.localDataJson,
    this.lastSyncAttempt,
    this.syncError,
    this.syncedAt,
    required this.createdAt,
  });

  factory CollectionEventSync.fromJson(Map<String, dynamic> json) => _$CollectionEventSyncFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionEventSyncToJson(this);

  bool get isPending => syncStatus == 'pending';
  bool get isSynced => syncStatus == 'synced';
  bool get isConflict => syncStatus == 'conflict';
  bool get isFailed => syncStatus == 'failed';
}

@JsonSerializable()
class SyncLog {
  final int id;
  final String syncId;
  final int collector;
  final String collectorName;
  final String syncType;
  final String status;
  final int eventsProcessed;
  final int eventsSynced;
  final int eventsFailed;
  final int eventsConflicts;
  final String startedAt;
  final String? completedAt;
  final String errorSummary;
  final Map<String, dynamic> metadataJson;

  SyncLog({
    required this.id,
    required this.syncId,
    required this.collector,
    required this.collectorName,
    required this.syncType,
    required this.status,
    required this.eventsProcessed,
    required this.eventsSynced,
    required this.eventsFailed,
    required this.eventsConflicts,
    required this.startedAt,
    this.completedAt,
    required this.errorSummary,
    required this.metadataJson,
  });

  factory SyncLog.fromJson(Map<String, dynamic> json) => _$SyncLogFromJson(json);
  Map<String, dynamic> toJson() => _$SyncLogToJson(this);

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPartial => status == 'partial';
  bool get isStarted => status == 'started';
}

@JsonSerializable()
class PendingSyncResponse {
  final List<CollectionEventSync> collectionEvents;
  final int pendingCount;
  final String? lastSync;

  PendingSyncResponse({
    required this.collectionEvents,
    required this.pendingCount,
    this.lastSync,
  });

  factory PendingSyncResponse.fromJson(Map<String, dynamic> json) => _$PendingSyncResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PendingSyncResponseToJson(this);
}

@JsonSerializable()
class SyncResult {
  final bool success;
  final String syncId;
  final int eventsSynced;
  final int eventsFailed;
  final int eventsConflicts;
  final List<String> errors;
  final String completedAt;

  SyncResult({
    required this.success,
    required this.syncId,
    required this.eventsSynced,
    required this.eventsFailed,
    required this.eventsConflicts,
    required this.errors,
    required this.completedAt,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) => _$SyncResultFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResultToJson(this);
}

@JsonSerializable()
class SyncCollectionRequest {
  final List<Map<String, dynamic>> events;

  SyncCollectionRequest({
    required this.events,
  });

  factory SyncCollectionRequest.fromJson(Map<String, dynamic> json) => _$SyncCollectionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SyncCollectionRequestToJson(this);
}