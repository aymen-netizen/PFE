import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final List<dynamic>? errors;
  final int? count;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.count,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'],
      count: json['count'],
    );
  }

  @override
  List<Object?> get props => [success, message, data, errors, count];
}
