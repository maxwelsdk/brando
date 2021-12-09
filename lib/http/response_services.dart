import 'dart:convert';
import 'dart:io';

import 'package:brando/http/exceptions/exceptions.dart';
import 'package:dio/dio.dart';

class ResponseService {
  static dynamic getJsonOrThrowException(Response response) {
    switch (response.statusCode) {
      case HttpStatus.ok:
      case HttpStatus.created:
        return jsonDecode(response.data);
      case HttpStatus.unauthorized:
        return UnauthorizedException();
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
