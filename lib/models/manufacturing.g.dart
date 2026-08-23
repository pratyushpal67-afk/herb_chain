// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manufacturing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Manufacturer _$ManufacturerFromJson(Map<String, dynamic> json) => Manufacturer(
  id: (json['id'] as num).toInt(),
  manufacturerId: json['manufacturerId'] as String,
  name: json['name'] as String,
  licenseNumber: json['licenseNumber'] as String,
  address: json['address'] as String,
  region: json['region'] as String,
  contactPerson: json['contactPerson'] as String,
  contactPhone: json['contactPhone'] as String,
  contactEmail: json['contactEmail'] as String,
  status: json['status'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ManufacturerToJson(Manufacturer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'manufacturerId': instance.manufacturerId,
      'name': instance.name,
      'licenseNumber': instance.licenseNumber,
      'address': instance.address,
      'region': instance.region,
      'contactPerson': instance.contactPerson,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

ManufacturingEvent _$ManufacturingEventFromJson(Map<String, dynamic> json) =>
    ManufacturingEvent(
      id: (json['id'] as num).toInt(),
      manufacturingId: json['manufacturingId'] as String,
      batch: (json['batch'] as num).toInt(),
      batchId: json['batchId'] as String,
      manufacturer: (json['manufacturer'] as num).toInt(),
      manufacturerName: json['manufacturerName'] as String,
      operator: (json['operator'] as num).toInt(),
      operatorName: json['operatorName'] as String,
      productType: json['productType'] as String,
      inputQuantityKg: json['inputQuantityKg'] as String,
      outputQuantityKg: json['outputQuantityKg'] as String?,
      lossQuantityKg: json['lossQuantityKg'] as String?,
      manufacturingDate: json['manufacturingDate'] as String,
      completedAt: json['completedAt'] as String?,
      status: json['status'] as String,
      batchNumber: json['batchNumber'] as String,
      expiryDate: json['expiryDate'] as String?,
      notes: json['notes'] as String,
      metadataJson: json['metadataJson'] as Map<String, dynamic>,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ManufacturingEventToJson(ManufacturingEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'manufacturingId': instance.manufacturingId,
      'batch': instance.batch,
      'batchId': instance.batchId,
      'manufacturer': instance.manufacturer,
      'manufacturerName': instance.manufacturerName,
      'operator': instance.operator,
      'operatorName': instance.operatorName,
      'productType': instance.productType,
      'inputQuantityKg': instance.inputQuantityKg,
      'outputQuantityKg': instance.outputQuantityKg,
      'lossQuantityKg': instance.lossQuantityKg,
      'manufacturingDate': instance.manufacturingDate,
      'completedAt': instance.completedAt,
      'status': instance.status,
      'batchNumber': instance.batchNumber,
      'expiryDate': instance.expiryDate,
      'notes': instance.notes,
      'metadataJson': instance.metadataJson,
      'createdAt': instance.createdAt,
    };

ManufacturingCreateRequest _$ManufacturingCreateRequestFromJson(
  Map<String, dynamic> json,
) => ManufacturingCreateRequest(
  batchId: json['batchId'] as String,
  manufacturerId: json['manufacturerId'] as String,
  productType: json['productType'] as String,
  inputQuantityKg: json['inputQuantityKg'] as String,
  outputQuantityKg: json['outputQuantityKg'] as String?,
  manufacturingDate: json['manufacturingDate'] as String,
  batchNumber: json['batchNumber'] as String?,
  expiryDate: json['expiryDate'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ManufacturingCreateRequestToJson(
  ManufacturingCreateRequest instance,
) => <String, dynamic>{
  'batchId': instance.batchId,
  'manufacturerId': instance.manufacturerId,
  'productType': instance.productType,
  'inputQuantityKg': instance.inputQuantityKg,
  'outputQuantityKg': instance.outputQuantityKg,
  'manufacturingDate': instance.manufacturingDate,
  'batchNumber': instance.batchNumber,
  'expiryDate': instance.expiryDate,
  'notes': instance.notes,
};
