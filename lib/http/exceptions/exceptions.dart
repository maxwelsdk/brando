import 'dart:developer';

class AuthenticationException implements Exception {
  final String error;

  AuthenticationException(this.error);

  @override
  String toString() {
    log("AuthenticateAsync.AuthRequestErrorDetails: $error");
    return error;
  }
}
