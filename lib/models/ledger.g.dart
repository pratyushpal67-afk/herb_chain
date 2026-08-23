// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerTransaction _$LedgerTransactionFromJson(Map<String, dynamic> json) =>
    LedgerTransaction(
      id: (json['id'] as num).toInt(),
      transactionId: json['transactionId'] as String,
      batch: (json['batch'] as num).toInt(),
      batchId: json['batchId'] as String,
      ledgerType: json['ledgerType'] as String,
      transactionHash: json['transactionHash'] as String,
      blockNumber: (json['blockNumber'] as num?)?.toInt(),
      blockHash: json['blockHash'] as String,
      status: json['status'] as String,
      gasUsed: (json['gasUsed'] as num?)?.toInt(),
      gasPrice: (json['gasPrice'] as num?)?.toInt(),
      fromAddress: json['fromAddress'] as String,
      toAddress: json['toAddress'] as String,
      dataPayload: json['dataPayload'] as Map<String, dynamic>,
      submittedAt: json['submittedAt'] as String,
      confirmedAt: json['confirmedAt'] as String?,
      errorMessage: json['errorMessage'] as String,
      metadataJson: json['metadataJson'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LedgerTransactionToJson(LedgerTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'batch': instance.batch,
      'batchId': instance.batchId,
      'ledgerType': instance.ledgerType,
      'transactionHash': instance.transactionHash,
      'blockNumber': instance.blockNumber,
      'blockHash': instance.blockHash,
      'status': instance.status,
      'gasUsed': instance.gasUsed,
      'gasPrice': instance.gasPrice,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'dataPayload': instance.dataPayload,
      'submittedAt': instance.submittedAt,
      'confirmedAt': instance.confirmedAt,
      'errorMessage': instance.errorMessage,
      'metadataJson': instance.metadataJson,
    };

BatchHash _$BatchHashFromJson(Map<String, dynamic> json) => BatchHash(
  id: (json['id'] as num).toInt(),
  hashId: json['hashId'] as String,
  batch: (json['batch'] as num).toInt(),
  batchId: json['batchId'] as String,
  hashType: json['hashType'] as String,
  algorithm: json['algorithm'] as String,
  hashValue: json['hashValue'] as String,
  sourceDataJson: json['sourceDataJson'] as Map<String, dynamic>,
  sourceReference: json['sourceReference'] as String,
  merkleProof: json['merkleProof'] as Map<String, dynamic>,
  createdAt: json['createdAt'] as String,
  verifiedAt: json['verifiedAt'] as String?,
  isValid: json['isValid'] as bool,
);

Map<String, dynamic> _$BatchHashToJson(BatchHash instance) => <String, dynamic>{
  'id': instance.id,
  'hashId': instance.hashId,
  'batch': instance.batch,
  'batchId': instance.batchId,
  'hashType': instance.hashType,
  'algorithm': instance.algorithm,
  'hashValue': instance.hashValue,
  'sourceDataJson': instance.sourceDataJson,
  'sourceReference': instance.sourceReference,
  'merkleProof': instance.merkleProof,
  'createdAt': instance.createdAt,
  'verifiedAt': instance.verifiedAt,
  'isValid': instance.isValid,
};

MerkleTree _$MerkleTreeFromJson(Map<String, dynamic> json) => MerkleTree(
  id: (json['id'] as num).toInt(),
  treeId: json['treeId'] as String,
  batch: (json['batch'] as num).toInt(),
  batchId: json['batchId'] as String,
  rootHash: json['rootHash'] as String,
  leafCount: (json['leafCount'] as num).toInt(),
  treeData: json['treeData'] as Map<String, dynamic>,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$MerkleTreeToJson(MerkleTree instance) =>
    <String, dynamic>{
      'id': instance.id,
      'treeId': instance.treeId,
      'batch': instance.batch,
      'batchId': instance.batchId,
      'rootHash': instance.rootHash,
      'leafCount': instance.leafCount,
      'treeData': instance.treeData,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

BatchHashCreateRequest _$BatchHashCreateRequestFromJson(
  Map<String, dynamic> json,
) => BatchHashCreateRequest(
  batchId: json['batchId'] as String,
  hashType: json['hashType'] as String,
  algorithm: json['algorithm'] as String,
  sourceData: json['sourceData'] as Map<String, dynamic>,
  sourceReference: json['sourceReference'] as String?,
);

Map<String, dynamic> _$BatchHashCreateRequestToJson(
  BatchHashCreateRequest instance,
) => <String, dynamic>{
  'batchId': instance.batchId,
  'hashType': instance.hashType,
  'algorithm': instance.algorithm,
  'sourceData': instance.sourceData,
  'sourceReference': instance.sourceReference,
};
