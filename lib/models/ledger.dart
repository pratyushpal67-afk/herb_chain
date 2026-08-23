import 'package:json_annotation/json_annotation.dart';

part 'ledger.g.dart';

@JsonSerializable()
class LedgerTransaction {
  final int id;
  final String transactionId;
  final int batch;
  final String batchId;
  final String ledgerType;
  final String transactionHash;
  final int? blockNumber;
  final String blockHash;
  final String status;
  final int? gasUsed;
  final int? gasPrice;
  final String fromAddress;
  final String toAddress;
  final Map<String, dynamic> dataPayload;
  final String submittedAt;
  final String? confirmedAt;
  final String errorMessage;
  final Map<String, dynamic> metadataJson;

  LedgerTransaction({
    required this.id,
    required this.transactionId,
    required this.batch,
    required this.batchId,
    required this.ledgerType,
    required this.transactionHash,
    this.blockNumber,
    required this.blockHash,
    required this.status,
    this.gasUsed,
    this.gasPrice,
    required this.fromAddress,
    required this.toAddress,
    required this.dataPayload,
    required this.submittedAt,
    this.confirmedAt,
    required this.errorMessage,
    required this.metadataJson,
  });

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) => _$LedgerTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$LedgerTransactionToJson(this);

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
}

@JsonSerializable()
class BatchHash {
  final int id;
  final String hashId;
  final int batch;
  final String batchId;
  final String hashType;
  final String algorithm;
  final String hashValue;
  final Map<String, dynamic> sourceDataJson;
  final String sourceReference;
  final Map<String, dynamic> merkleProof;
  final String createdAt;
  final String? verifiedAt;
  final bool isValid;

  BatchHash({
    required this.id,
    required this.hashId,
    required this.batch,
    required this.batchId,
    required this.hashType,
    required this.algorithm,
    required this.hashValue,
    required this.sourceDataJson,
    required this.sourceReference,
    required this.merkleProof,
    required this.createdAt,
    this.verifiedAt,
    required this.isValid,
  });

  factory BatchHash.fromJson(Map<String, dynamic> json) => _$BatchHashFromJson(json);
  Map<String, dynamic> toJson() => _$BatchHashToJson(this);
}

@JsonSerializable()
class MerkleTree {
  final int id;
  final String treeId;
  final int batch;
  final String batchId;
  final String rootHash;
  final int leafCount;
  final Map<String, dynamic> treeData;
  final String createdAt;
  final String updatedAt;

  MerkleTree({
    required this.id,
    required this.treeId,
    required this.batch,
    required this.batchId,
    required this.rootHash,
    required this.leafCount,
    required this.treeData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerkleTree.fromJson(Map<String, dynamic> json) => _$MerkleTreeFromJson(json);
  Map<String, dynamic> toJson() => _$MerkleTreeToJson(this);
}

@JsonSerializable()
class BatchHashCreateRequest {
  final String batchId;
  final String hashType;
  final String algorithm;
  final Map<String, dynamic> sourceData;
  final String? sourceReference;

  BatchHashCreateRequest({
    required this.batchId,
    required this.hashType,
    required this.algorithm,
    required this.sourceData,
    this.sourceReference,
  });

  factory BatchHashCreateRequest.fromJson(Map<String, dynamic> json) => _$BatchHashCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BatchHashCreateRequestToJson(this);
}