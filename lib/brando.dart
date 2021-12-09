library brando;

import 'dart:async';
import 'dart:io';

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
/// Este token é fornecido pela aplicação anfitriã ou HostApp para módulo.
class Brando {
  final Dio dio;
  final Map _brandoHeaders = {
    accessTokenKey: noTokenValue,
    HttpHeaders.contentTypeHeader: applicationJson,
    HttpHeaders.acceptHeader: applicationJson,
  };
  late final HttpRequestMethods _httpRequestMethods;

  /// Assistente de requições HTTP autenticadas utilizando [Dio] como `Client`
  /// de requisições HTTP.
  ///
  /// Provê açúcar sintático (Syntax Sugar) para utilização de métodos para
  /// requisições HTTP. Verifique [httpRequestMethods].
  ///
  /// * [httpRequestMethods] Implementação dos métodos de requisição HTTP.
  /// * [Dio] Cliente HTTP para Dart.
  Brando(this.dio) {
    _httpRequestMethods = DioHttpRequestMethodsImpl(dio);
  }

  set accessToken(String token) => _brandoHeaders[accessTokenKey] = token;

  Map get headers => _brandoHeaders;

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

    switch (httpVerbs) {
      case HttpVerbs.post:
        return await _httpRequestMethods
            .post(uri: uri, body: body, headers: headers)
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
  }
}
