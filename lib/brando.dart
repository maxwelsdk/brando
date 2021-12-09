library brando;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:brando/http/exceptions/exceptions.dart';
import 'package:dio/dio.dart';

import 'http/http_handler_sb.dart';

// Headers Key's
const accessTokenKey = "access_token";
const String version = "version";
const String deviceType = "device_type";

// Headers Values
const noTokenValue = "no-token";
const String applicationJson = "application/json";

// Default values
const _defaultTimeOutDuration = Duration(seconds: 120);

/// Brando é um assistente de requisições autenticadas para um módulo Flutter.
///
/// Esta classe espera um instância do [Dio]. [Brando] então realiza requisições HTTP em Dart.
///
/// Brando necessita um `access_token`, válido e autenticado.
/// Este token é fornecido pela aplicação anfitriã ou HostApp para o módulo.
class Brando {
  final Dio dio;
  final Map _brandoHeaders = {
    accessTokenKey: noTokenValue,
    HttpHeaders.contentTypeHeader: applicationJson,
    HttpHeaders.acceptHeader: applicationJson,
  };
  late final HttpRequestMethods _httpRequestMethods;

  final Future<String> onUnauthorized;

  Map get headers => _brandoHeaders;

  set _accessToken(String token) => _brandoHeaders[accessTokenKey] = token;

  /// Assistente de requições HTTP autenticadas utilizando [Dio] como `Client`
  /// de requisições HTTP.
  ///
  /// Provê açúcar sintático (Syntax Sugar) para utilização de métodos para
  /// requisições HTTP. Verifique [httpRequestMethods].
  ///
  /// * [httpRequestMethods] Implementação dos métodos de requisição HTTP.
  /// * [Dio] Cliente HTTP para Dart.
  Brando(this.dio, {required this.onUnauthorized}) {
    _httpRequestMethods = DioHttpRequestMethodsImpl(dio);
  }

  /// Açúcar sintático para requisições HTTP.
  Future request({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map? headers,
  }) async {
    assert(
        _brandoHeaders[accessTokenKey] == noTokenValue ||
            _brandoHeaders[accessTokenKey]!.isNotEmpty,
        "The access_token can not be empty or null");

    if (headers != null) {
      _brandoHeaders.addAll(headers);
    }

    return _attempt(
      httpVerbs: httpVerbs,
      uri: uri,
      body: body,
      headers: headers,
    );
  }

  Future _attempt({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map? headers,
    bool retryRequestAttempt = true,
  }) async {
    dynamic _retryOnUnauthorized(UnauthorizedException onError) async {
      _accessToken = await onUnauthorized;
      if (retryRequestAttempt) {
        return await _attempt(
          httpVerbs: httpVerbs,
          uri: uri,
          body: body,
          headers: _brandoHeaders,
          retryRequestAttempt: false,
        );
      }
    }

    try {
      switch (httpVerbs) {
        case HttpVerbs.post:
          return await _httpRequestMethods
              .post(uri: uri, body: body, headers: _brandoHeaders)
              .timeout(_defaultTimeOutDuration,
                  onTimeout: () => throw TimeoutException("message"));
        case HttpVerbs.get:
          return await _httpRequestMethods
              .get(uri: uri, headers: _brandoHeaders)
              .timeout(_defaultTimeOutDuration,
                  onTimeout: () =>
                      throw TimeoutException("message from interactor"));
        case HttpVerbs.put:
          return await _httpRequestMethods.put(
              uri: uri, headers: headers, body: body);
        case HttpVerbs.delete:
          return await _httpRequestMethods.delete(
              uri: uri, headers: _brandoHeaders);
        case HttpVerbs.options:
          return await _httpRequestMethods.options(
              uri: uri, headers: _brandoHeaders);
        default:
          throw UnimplementedError();
      }
    } catch (e, s) {
      if (e is UnauthorizedException) {
        _retryOnUnauthorized(e);
      }
      log(e.toString(), stackTrace: s);
      rethrow;
    }
  }
}
