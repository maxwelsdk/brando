import 'dart:io';

import 'package:brando/http/exceptions/exceptions.dart';
import 'package:dio/dio.dart';

class HttpResponses {
  static dynamic getJsonOrThrowException(Response response) {
    switch (response.statusCode) {
      case HttpStatus.ok:
      case HttpStatus.created:
        return response.data;
      case HttpStatus.unauthorized:
        throw UnauthorizedException();
      case HttpStatus.notFound:
        throw NotFoundException();
      case HttpStatus.noContent:
        throw NoContentException();
      case HttpStatus.badRequest:
        throw BadRequestException();
      default:
        throw Exception();
    }
  }
}
