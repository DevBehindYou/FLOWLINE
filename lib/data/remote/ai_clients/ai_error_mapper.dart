import 'package:dio/dio.dart';

/// Turns a Dio failure into a short, honest, user-facing sentence instead
/// of a raw exception string — used by every hosted-vendor client so the
/// chat bubble says something a non-developer can act on.
String describeDioError(DioException error, String vendorName) {
  final status = error.response?.statusCode;
  if (status == 401 || status == 403) {
    return 'That API key was rejected by $vendorName.';
  }
  if (status == 429) {
    return '$vendorName rate-limited this request \u2014 try again shortly.';
  }
  if (status != null) {
    return '$vendorName returned an error (HTTP $status).';
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return "Couldn't reach $vendorName \u2014 check your connection.";
  }
  return "Couldn't reach $vendorName.";
}
