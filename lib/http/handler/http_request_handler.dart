import 'package:brando/http/enum/http_verbs.dart';

/// Classe base para manipulação das requisições HTTP.
/// Possui contrato com a classe [HttpRequestHandlerImpl]
abstract class HttpRequestHandler {
  Future request({
    required HttpVerbs httpVerbs,
    required String uri,
    Map? headers,
    Map? body,
  });
}
