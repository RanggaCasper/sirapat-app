import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';

class APIProvider {
  static const requestTimeOut = AppConstants.connectionTimeout;
  final Dio _dio = Dio(
    BaseOptions(connectTimeout: requestTimeOut, receiveTimeout: requestTimeOut),
  );

  static final _singleton = APIProvider._internal();
  static APIProvider get instance => _singleton;

  APIProvider._internal();

  Future<dynamic> request(APIRequestRepresentable request) async {
    try {
      final response = await _dio.request(
        request.url,
        options: Options(
          method: request.method.string,
          headers: request.headers,
        ),
        queryParameters: request.query,
        data: request.body,
      );
      return _returnResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeOutException('Request timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw FetchDataException('No Internet connection');
      } else if (e.response != null) {
        return _returnResponse(e.response!);
      } else {
        throw FetchDataException(e.message ?? 'Unknown error occurred');
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  // Convenience methods for common HTTP operations
  Future<dynamic> get(String url, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(url, queryParameters: query);
      return _returnResponse(response);
    } on DioException catch (e) {
      return _handleDioException(e);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> post(
    String url,
    dynamic data, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
      return _returnResponse(response);
    } on DioException catch (e) {
      return _handleDioException(e);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> put(
    String url,
    dynamic data, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.put(url, data: data, queryParameters: query);
      return _returnResponse(response);
    } on DioException catch (e) {
      return _handleDioException(e);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> delete(String url, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.delete(url, queryParameters: query);
      return _returnResponse(response);
    } on DioException catch (e) {
      return _handleDioException(e);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  dynamic _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw TimeOutException('Request timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      throw FetchDataException('No Internet connection');
    } else if (e.response != null) {
      return _returnResponse(e.response!);
    } else {
      throw FetchDataException(e.message ?? 'Unknown error occurred');
    }
  }

  dynamic _returnResponse(Response<dynamic> response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 302:
      case 301:
      case 307:
      case 308:
        // Redirect - biasanya masalah autentikasi atau session expired
        throw UnauthorisedException('Session expired or unauthorized access');
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 404:
        throw NotFoundException('Resource not found');
      case 422:
        // Validation error - return data untuk di-parse sebagai ApiException
        return response.data;
      case 429:
        return response.data;
      case 500:
      case 502:
      case 503:
        throw InternalServerException('Internal Server Error');
      default:
        throw FetchDataException(
          'Error occurred with StatusCode: ${response.statusCode}',
        );
    }
  }
}

// Exception Classes
class AppException implements Exception {
  final String? code;
  final String? message;
  final String? details;

  AppException({this.code, this.message, this.details});

  @override
  String toString() {
    return details ?? message ?? '';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String? details)
    : super(
        code: "fetch-data",
        message: "Error During Communication",
        details: details,
      );
}

class BadRequestException extends AppException {
  BadRequestException(String? details)
    : super(
        code: "invalid-request",
        message: "Invalid Request",
        details: details,
      );
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String? details)
    : super(code: "unauthorised", message: "Unauthorised", details: details);
}

class NotFoundException extends AppException {
  NotFoundException(String? details)
    : super(code: "not-found", message: "Not Found", details: details);
}

class InternalServerException extends AppException {
  InternalServerException(String? details)
    : super(
        code: "internal-server-error",
        message: "Internal Server Error",
        details: details,
      );
}

class TimeOutException extends AppException {
  TimeOutException(String? details)
    : super(
        code: "request-timeout",
        message: "Request Timeout",
        details: details,
      );
}
