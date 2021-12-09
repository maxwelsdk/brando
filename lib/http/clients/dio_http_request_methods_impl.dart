import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:brando/http/exceptions/exceptions.dart';
import 'package:brando/http/http_methods/http_request_methods.dart';
import 'package:dio/dio.dart';

class DioHttpRequestMethodsImpl implements HttpRequestMethods {
  late final Dio _dio;

  DioHttpRequestMethodsImpl(this._dio);

  @override
  Future delete({required String uri, Map? headers}) async {
    late final Response _response;
    try {
      _response = await _dio.delete(uri);
    } catch (e, s) {
      log("delete", error: e, stackTrace: s);
      throw Exception(e);
    }
    return _response;
  }

  @override
  Future get({required String uri, Map? headers}) async {
    late final Response _response;
    try {
      _response = await _dio.get(uri);
    } catch (e, s) {
      log("get", error: e, stackTrace: s);
      throw Exception(e);
    }
    return _response;
  }

  @override
  Future options({required String uri, Map? headers}) {
    // TODO: implement options
    throw UnimplementedError();
  }

  @override
  Future post({required String uri, Map? headers, Map? body}) {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future put({required String uri, Map? headers, Map? body}) {
    // TODO: implement put
    throw UnimplementedError();
  }
}


