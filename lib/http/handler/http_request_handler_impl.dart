import 'dart:async';
import 'dart:io';

import 'package:brando/http/http_handler_sb.dart';

const _defaultTimeOutDuration = Duration(seconds: 120);

/// Classe para gerenciamento de requisições HTTP.
///
/// Contém funcionalidades que determinam fluxo de dados da requisição baseado
/// no tipo de [HttpVerbs] utilizado.
class HttpRequestHandlerImpl implements HttpRequestHandler {
  /// Requer implementação dos métodos através da classe base [HttpRequestMethods].
  ///
  /// Permite que a classe ignore o tipo de 'cliente' utilizado para as requisições
  /// HTTP.
  final HttpRequestMethods httpRequestMethods;

  final Map<String, String> defaultHeaders = {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptHeader: "application/json",
  };

  /// Gerenciador de requisições HTTP.
  ///
  /// Provê açúcar sintático (Syntax Sugar) para utilização de métodos para
  /// requisições HTTP.
  ///
  /// * [httpRequestMethods] Implementação dos métodos de requisição HTTP
  /// com o Http Client que desejar.
  HttpRequestHandlerImpl({required this.httpRequestMethods});

  @override
  Future request({
    required HttpVerbs httpVerbs,
    required String uri,
    Map? headers,
    Map? body,
  }) async {
    switch (httpVerbs) {
      case HttpVerbs.post:
        return await httpRequestMethods
            .post(uri: uri, body: body, headers: headers)
            .timeout(_defaultTimeOutDuration,
                onTimeout: () => throw TimeoutException("message"));
      case HttpVerbs.get:
        return await httpRequestMethods.get(uri: uri, headers: headers).timeout(
            _defaultTimeOutDuration,
            onTimeout: () => throw TimeoutException("message from interactor"));
      case HttpVerbs.put:
        return await httpRequestMethods.put(
            uri: uri, headers: headers, body: body);
      case HttpVerbs.delete:
        return await httpRequestMethods.delete(uri: uri, headers: headers);
      case HttpVerbs.options:
        return await httpRequestMethods.options(uri: uri, headers: headers);
      default:
        throw UnimplementedError();
    }
  }
}
