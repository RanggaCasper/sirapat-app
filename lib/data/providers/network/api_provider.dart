import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sirapat_app/data/providers/network/api_request_representable.dart';

class APIProvider {
  static const requestTimeOut = Duration(seconds: 30);
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

  dynamic _returnResponse(Response<dynamic> response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 404:
        throw NotFoundException('Resource not found');
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
    return "[$code]: $message ${details != null ? '\n$details' : ''}";
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
