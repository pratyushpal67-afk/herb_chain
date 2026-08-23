import 'package:json_annotation/json_annotation.dart';

part 'processing.g.dart';

@JsonSerializable()
class ProcessingEvent {
  final int id;
  final String processingId;
  final int batch;
  final String batchId;
  final String facility;
  final int operator;
  final String operatorName;
  final String processType;
  final String receivedQuantityKg;
  final String? processedQuantityKg;
  final String? lossQuantityKg;
  final String startedAt;
  final String? completedAt;
  final String status;
  final String notes;
  final Map<String, dynamic> metadataJson;
  final String createdAt;

  ProcessingEvent({
    required this.id,
    required this.processingId,
    required this.batch,
    required this.batchId,
    required this.facility,
    required this.operator,
    required this.operatorName,
    required this.processType,
    required this.receivedQuantityKg,
    this.processedQuantityKg,
    this.lossQuantityKg,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.notes,
    required this.metadataJson,
    required this.createdAt,
  });

  factory ProcessingEvent.fromJson(Map<String, dynamic> json) => _$ProcessingEventFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessingEventToJson(this);

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  String get formattedReceived => '${double.parse(receivedQuantityKg).toStringAsFixed(3)} kg';
  String get formattedProcessed => processedQuantityKg != null ? '${double.parse(processedQuantityKg!).toStringAsFixed(3)} kg' : 'N/A';
  String get formattedLoss => lossQuantityKg != null ? '${double.parse(lossQuantityKg!).toStringAsFixed(3)} kg' : 'N/A';

  double get lossPercentage {
    if (processedQuantityKg == null) return 0;
    final received = double.parse(receivedQuantityKg);
    final processed = double.parse(processedQuantityKg!);
    if (received == 0) return 0;
    return ((received - processed) / received * 100);
  }
}

@JsonSerializable()
class ProcessingCreateRequest {
  final String batchId;
  final String facility;
  final String processType;
  final String receivedQuantityKg;
  final String? processedQuantityKg;
  final String startedAt;
  final String? notes;

  ProcessingCreateRequest({
    required this.batchId,
    required this.facility,
    required this.processType,
    required this.receivedQuantityKg,
    this.processedQuantityKg,
    required this.startedAt,
    this.notes,
  });

  factory ProcessingCreateRequest.fromJson(Map<String, dynamic> json) => _$ProcessingCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessingCreateRequestToJson(this);
}