library brando;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:brando/http/enum/http_verbs.dart';
import 'package:brando/http/exceptions/exceptions.dart';
import 'package:brando/http/http_methods/http_request_methods.dart';
import 'package:dio/dio.dart';

// Headers Key's
const accessTokenKey = "access_token";
const String version = "version";
const String deviceType = "device_type";

// Headers Values
const noTokenValue = "no-token";
const String applicationJson = "application/json";

// Default values
const _defaultTimeOutDuration = Duration(seconds: 120);

// Events
const String _refreshEvent = "refresh";
const String _fetchEvent = "fetch";

/// [Brando] é um assistente de requisições autenticadas para um módulo Flutter.
///
/// Esta classe espera um instância do [Dio]. [Brando] então realiza requisições HTTP em Dart.
///
/// [Brando] realizará uma nova requisição automáticamente em caso de falha
/// com [DioError] 401 `unauthorized`, na primeira falha é executado o [tokenFuture] com
/// evento de 'refresh'.
///
/// Caso exceção persistir a mesma será lançada.
///
/// Brando necessita um `access_token`, válido e autenticado.
/// Este token é fornecido pela aplicação anfitriã ou HostApp para o módulo.
class Brando {
  final Map<String, dynamic> _brandoHeaders = {
    accessTokenKey: noTokenValue,
    HttpHeaders.contentTypeHeader: applicationJson,
    HttpHeaders.acceptHeader: applicationJson,
    'device_type': 0,
    'version': 0,
  };

  late final HttpRequestMethods _httpRequestMethods;

  /// Evite utilizar uma referência future do pigeon, deixe que o evento invoque novamente o método para busca do token
  /// essa abordagem evita que um Future entregue um valor já computado.
  late final Future<String> Function(String) _tokenFuture;

  Map<String, dynamic> get headers => _brandoHeaders;

  set headers(Map<String, dynamic> header) {
    _brandoHeaders.addAll(header);
  }

  /// Assistente de requições HTTP autenticadas utilizando [Dio] como `Client`
  /// de requisições HTTP.
  ///
  /// Provê açúcar sintático (Syntax Sugar) para utilização de métodos para
  /// requisições HTTP. Verifique [httpRequestMethods].
  ///
  /// * [tokenFuture] Future que contém implementação do [Pigeon] para recuperação de token.
  /// e.g.:
  ///
  /// ```dart
  /// // Exemplo de implementação
  /// Future<String> getTokenByEvent(String event) async {
  ///     if (event == "refresh") {
  ///      return await TokenMessages().fetchToken();
  ///     }
  ///     if (event == "fetch") {
  ///       return await TokenMessages().refreshAuthentication();
  ///     }
  ///     return "";
  ///   }
  ///
  /// // Exemplo de uso
  /// @override
  /// Widget build(BuildContext context) {
  /// final _services = Services(
  ///       Brando(
  ///         Dio(),
  ///         tokenFuture: getTokenByEvent,
  ///       ),
  ///     );
  /// }
  /// ```
  ///
  /// * [Dio] Cliente HTTP para Dart.
  Brando(
    this._httpRequestMethods, {
    required Future<String> Function(String) tokenFuture,
  }) {
    _tokenFuture = tokenFuture;
  }

  /// Açúcar sintático para requisições HTTP.
  /// * [HttpVerbs] Verbos de métodos de requisição HTTP.
  Future  request({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (headers != null) {
      _brandoHeaders.addAll(headers);
    }

    if (_brandoHeaders[accessTokenKey] == null ||
        _brandoHeaders[accessTokenKey].isEmpty ||
        _brandoHeaders[accessTokenKey] == noTokenValue) {
      await _tokenFuture.call(_fetchEvent).then((value) => _updateToken(value));
    }

    return await _attempt(
      httpVerbs: httpVerbs,
      uri: uri,
      body: body,
    );
  }

  void _updateToken(String token) {
    if (token.contains("error")) {
      throw AuthenticationException(token);
    }
    headers = {accessTokenKey: token};
  }

  Future<dynamic> _retryOnUnauthorized({
    required HttpVerbs httpVerbs,
    required String uri,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool retryRequestAttempt = true,
  }) async {
    await _tokenFuture.call(_refreshEvent).then((state) => _updateToken(state));

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
      rethrow;
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      rethrow;
    }
  }
}
