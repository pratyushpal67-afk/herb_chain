import 'package:json_annotation/json_annotation.dart';

part 'manufacturing.g.dart';

@JsonSerializable()
class Manufacturer {
  final int id;
  final String manufacturerId;
  final String name;
  final String licenseNumber;
  final String address;
  final String region;
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;
  final String status;
  final String createdAt;
  final String updatedAt;

  Manufacturer({
    required this.id,
    required this.manufacturerId,
    required this.name,
    required this.licenseNumber,
    required this.address,
    required this.region,
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) => _$ManufacturerFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);

  String get displayName => '$name ($manufacturerId)';
  bool get isActive => status == 'active';
}

@JsonSerializable()
class ManufacturingEvent {
  final int id;
  final String manufacturingId;
  final int batch;
  final String batchId;
  final int manufacturer;
  final String manufacturerName;
  final int operator;
  final String operatorName;
  final String productType;
  final String inputQuantityKg;
  final String? outputQuantityKg;
  final String? lossQuantityKg;
  final String manufacturingDate;
  final String? completedAt;
  final String status;
  final String batchNumber;
  final String? expiryDate;
  final String notes;
  final Map<String, dynamic> metadataJson;
  final String createdAt;

  ManufacturingEvent({
    required this.id,
    required this.manufacturingId,
    required this.batch,
    required this.batchId,
    required this.manufacturer,
    required this.manufacturerName,
    required this.operator,
    required this.operatorName,
    required this.productType,
    required this.inputQuantityKg,
    this.outputQuantityKg,
    this.lossQuantityKg,
    required this.manufacturingDate,
    this.completedAt,
    required this.status,
    required this.batchNumber,
    this.expiryDate,
    required this.notes,
    required this.metadataJson,
    required this.createdAt,
  });

  factory ManufacturingEvent.fromJson(Map<String, dynamic> json) => _$ManufacturingEventFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturingEventToJson(this);

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  String get formattedInput => '${double.parse(inputQuantityKg).toStringAsFixed(3)} kg';
  String get formattedOutput => outputQuantityKg != null ? '${double.parse(outputQuantityKg!).toStringAsFixed(3)} kg' : 'N/A';
  String get formattedLoss => lossQuantityKg != null ? '${double.parse(lossQuantityKg!).toStringAsFixed(3)} kg' : 'N/A';

  double get yieldPercentage {
    if (outputQuantityKg == null) return 0;
    final input = double.parse(inputQuantityKg);
    final output = double.parse(outputQuantityKg!);
    if (input == 0) return 0;
    return (output / input * 100);
  }
}

@JsonSerializable()
class ManufacturingCreateRequest {
  final String batchId;
  final String manufacturerId;
  final String productType;
  final String inputQuantityKg;
  final String? outputQuantityKg;
  final String manufacturingDate;
  final String? batchNumber;
  final String? expiryDate;
  final String? notes;

  ManufacturingCreateRequest({
    required this.batchId,
    required this.manufacturerId,
    required this.productType,
    required this.inputQuantityKg,
    this.outputQuantityKg,
    required this.manufacturingDate,
    this.batchNumber,
    this.expiryDate,
    this.notes,
  });

  factory ManufacturingCreateRequest.fromJson(Map<String, dynamic> json) => _$ManufacturingCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturingCreateRequestToJson(this);
}