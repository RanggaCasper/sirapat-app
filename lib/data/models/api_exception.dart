class ApiException implements Exception {
  final bool status;
  final String message;
  final Map<String, List<String>>? errors;
  final String? timestamp;

  ApiException({
    required this.status,
    required this.message,
    this.errors,
    this.timestamp,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? parsedErrors;

    if (json['errors'] != null) {
      parsedErrors = {};
      final errorsMap = json['errors'] as Map<String, dynamic>;
      errorsMap.forEach((key, value) {
        if (value is List) {
          parsedErrors![key] = List<String>.from(value);
        }
      });
    }

    return ApiException(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      errors: parsedErrors,
      timestamp: json['timestamp'] as String?,
    );
  }

  String getFirstError() {
    if (errors != null && errors!.isNotEmpty) {
      final firstKey = errors!.keys.first;
      final firstErrors = errors![firstKey];
      if (firstErrors != null && firstErrors.isNotEmpty) {
        return firstErrors.first;
      }
    }
    return message;
  }

  String? getFieldError(String fieldName) {
    if (errors != null && errors!.containsKey(fieldName)) {
      final fieldErrors = errors![fieldName];
      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        return fieldErrors.first;
      }
    }
    return null;
  }

  @override
  String toString() => message;
}
