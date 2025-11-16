class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final String timestamp;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) => {
    'status': status,
    'message': message,
    'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    'timestamp': timestamp,
  };
}
