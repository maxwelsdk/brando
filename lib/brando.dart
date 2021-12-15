library brando;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:brando/http/enum/http_verbs.dart';
import 'package:brando/http/exceptions/exceptions.dart';
import 'package:brando/http/http_methods/http_request_methods.dart';
import 'package:dio/dio.dart';

import 'http/clients/dio_http_request_methods_impl.dart';

// Headers Key's
const accessTokenKey = "access_token";
const String version = "version";
const String deviceType = "device_type";

// Headers Values
const noTokenValue = "no-token";
const String applicationJson = "application/json";

// Default values
const _defaultTimeOutDuration = Duration(seconds: 120);

/// [Brando] é um assistente de requisições autenticadas para um módulo Flutter.
///
/// Esta classe espera um instância do [Dio]. [Brando] então realiza requisições HTTP em Dart.
///
/// [Brando] realizará uma nova requisição automáticamente em caso de falha
/// com [UnauthorizedException], na primeira falha é executado o [onUnauthorized]
/// para solicitação de novo [access_token] e então é feita a requisição adicional.
/// Caso exceção persistir a mesma será lançada.
///
/// Brando necessita um `access_token`, válido e autenticado.
/// Este token é fornecido pela aplicação anfitriã ou HostApp para o módulo.
class Brando {
  final Dio _dio;
  final Map<String, dynamic> _brandoHeaders = {
    accessTokenKey: noTokenValue,
    HttpHeaders.contentTypeHeader: applicationJson,
    HttpHeaders.acceptHeader: applicationJson,
  };
  late final HttpRequestMethods _httpRequestMethods;

  late final Future<Map<String?, String?>> _fetchToken;

  late final Future<bool> _onUnauthorized;

  Map get headers => _brandoHeaders;

  /// Assistente de requições HTTP autenticadas utilizando [Dio] como `Client`
  /// de requisições HTTP.
  ///
  /// Provê açúcar sintático (Syntax Sugar) para utilização de métodos para
  /// requisições HTTP. Verifique [httpRequestMethods].
  ///
  /// * [onUnauthorized] função que contém implementação do [Pigeon], mensagem que retorna
  /// [access_token].
  ///
  /// * [Dio] Cliente HTTP para Dart.
  Brando(
    this._dio, {
    required Future<bool> onUnauthorized,
    required Future<Map<String?, String?>> fetchToken,
  }) {
    _httpRequestMethods = DioHttpRequestMethodsImpl(_dio);
    _fetchToken = fetchToken;
    _onUnauthorized = onUnauthorized;
  }

  /// Açúcar sintático para requisições HTTP.
  /// * [HttpVerbs] Verbos de métodos de requisição HTTP.
  Future request({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (headers != null) {
      _brandoHeaders.addAll(headers);
    }

    await _fetchTokenOrThrowException();

    return _attempt(
      httpVerbs: httpVerbs,
      uri: uri,
      body: body,
    );
  }

  Future<void> _fetchTokenOrThrowException() async {
    final Map<String?, String?> token = await _fetchToken;

    if (_hasFreshToken(token)) {
      _brandoHeaders[accessTokenKey] = token['access_token'];
    } else if (_hasAuthenticationError(token)) {
      throw AuthenticationException(token['auth_error_details'] ??
          "Nenhum erro foi informado pela aplicação Host.");
    }
  }

  bool _hasFreshToken(Map<String?, String?> value) {
    return value['token_status'] != null && value['token_status'] == "fresh";
  }

  bool _hasAuthenticationError(Map<String?, String?> value) {
    return value['token_status'] != null && value['token_status'] == "stale";
  }

  dynamic _retryOnUnauthorized({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool retryRequestAttempt = true,
  }) async {
    await _onUnauthorized.whenComplete(
      () async => await _fetchTokenOrThrowException(),
    );
    if (retryRequestAttempt) {
      return await _attempt(
        httpVerbs: httpVerbs,
        uri: uri,
        body: body,
        queryParameters: queryParameters,
        retryRequestAttempt: false,
      );
    }
  }

  Future _attempt({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool retryRequestAttempt = true,
  }) async {
    try {
      switch (httpVerbs) {
        case HttpVerbs.post:
          return await _httpRequestMethods
              .post(
                uri: uri,
                body: body,
                headers: _brandoHeaders,
              )
              .timeout(_defaultTimeOutDuration,
                  onTimeout: () => throw TimeoutException("message"));
        case HttpVerbs.get:
          return await _httpRequestMethods
              .get(
                uri: uri,
                headers: _brandoHeaders,
                queryParameters: queryParameters,
              )
              .timeout(_defaultTimeOutDuration,
                  onTimeout: () =>
                      throw TimeoutException("message from interactor"));
        case HttpVerbs.put:
          return await _httpRequestMethods.put(
            uri: uri,
            headers: _brandoHeaders,
            body: body,
          );
        case HttpVerbs.delete:
          return await _httpRequestMethods.delete(
            uri: uri,
            headers: _brandoHeaders,
          );
        default:
          throw UnimplementedError();
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        _retryOnUnauthorized(
          httpVerbs: httpVerbs,
          uri: uri,
          queryParameters: queryParameters,
          body: body,
          retryRequestAttempt: retryRequestAttempt,
        );
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      rethrow;
    }
  }
}
