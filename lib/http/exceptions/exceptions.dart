import 'dart:developer';

class BadRequestException implements Exception {}

class NoContentException implements Exception {}

class NotFoundException implements Exception {}

class UnauthorizedException implements Exception {}

class AuthenticationException implements Exception {
  final String error;

  AuthenticationException(this.error);

  @override
  String toString() {
    log("AuthenticateAsync.AuthRequestErrorDetails: $error");
    return error;
  }
}
