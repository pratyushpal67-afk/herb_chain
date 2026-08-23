import 'package:json_annotation/json_annotation.dart';
import 'batch.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String phone;
  final String status;
  final Collector? collector;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phone,
    required this.status,
    this.collector,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName'.trim();
  bool get isCollector => role == 'COLLECTOR' || role == 'FARMER';
  bool get isLab => role == 'LAB';
  bool get isManufacturer => role == 'MANUFACTURER';
  bool get isAdmin => role == 'ADMIN';
  bool get isCustomer => role == 'CUSTOMER';
}

@JsonSerializable()
class AuthTokens {
  final String access;
  final String refresh;
  final User user;

  AuthTokens({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}