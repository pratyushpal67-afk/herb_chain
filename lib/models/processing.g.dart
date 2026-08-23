// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessingEvent _$ProcessingEventFromJson(Map<String, dynamic> json) =>
    ProcessingEvent(
      id: (json['id'] as num).toInt(),
      processingId: json['processingId'] as String,
      batch: (json['batch'] as num).toInt(),
      batchId: json['batchId'] as String,
      facility: json['facility'] as String,
      operator: (json['operator'] as num).toInt(),
      operatorName: json['operatorName'] as String,
      processType: json['processType'] as String,
      receivedQuantityKg: json['receivedQuantityKg'] as String,
      processedQuantityKg: json['processedQuantityKg'] as String?,
      lossQuantityKg: json['lossQuantityKg'] as String?,
      startedAt: json['startedAt'] as String,
      completedAt: json['completedAt'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String,
      metadataJson: json['metadataJson'] as Map<String, dynamic>,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ProcessingEventToJson(ProcessingEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'processingId': instance.processingId,
      'batch': instance.batch,
      'batchId': instance.batchId,
      'facility': instance.facility,
      'operator': instance.operator,
      'operatorName': instance.operatorName,
      'processType': instance.processType,
      'receivedQuantityKg': instance.receivedQuantityKg,
      'processedQuantityKg': instance.processedQuantityKg,
      'lossQuantityKg': instance.lossQuantityKg,
      'startedAt': instance.startedAt,
      'completedAt': instance.completedAt,
      'status': instance.status,
      'notes': instance.notes,
      'metadataJson': instance.metadataJson,
      'createdAt': instance.createdAt,
    };

ProcessingCreateRequest _$ProcessingCreateRequestFromJson(
  Map<String, dynamic> json,
) => ProcessingCreateRequest(
  batchId: json['batchId'] as String,
  facility: json['facility'] as String,
  processType: json['processType'] as String,
  receivedQuantityKg: json['receivedQuantityKg'] as String,
  processedQuantityKg: json['processedQuantityKg'] as String?,
  startedAt: json['startedAt'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ProcessingCreateRequestToJson(
  ProcessingCreateRequest instance,
) => <String, dynamic>{
  'batchId': instance.batchId,
  'facility': instance.facility,
  'processType': instance.processType,
  'receivedQuantityKg': instance.receivedQuantityKg,
  'processedQuantityKg': instance.processedQuantityKg,
  'startedAt': instance.startedAt,
  'notes': instance.notes,
};
