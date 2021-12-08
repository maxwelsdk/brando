library brando;

import 'package:dio/dio.dart';

import 'http/http_handler_sb.dart';

const accessTokenKey = "access_token";
const noTokenValue = "no-token";

///
class Brando {
  final Dio dio;
  final Map _brandoHeaders = {accessTokenKey: noTokenValue};
  late final HttpRequestHandler _requestHandler;

  Brando(this.dio) {
    _requestHandler = HttpRequestHandlerImpl(
        httpRequestMethods: DioHttpRequestMethodsImpl(dio));
  }

  set accessToken(String token) => _brandoHeaders[accessTokenKey] = token;

  Map get headers => _brandoHeaders;

  Future request({
    required HttpVerbs httpVerbs,
    required String uri,
    Map? headers,
  }) async {
    assert(
        _brandoHeaders[accessTokenKey] == noTokenValue ||
            _brandoHeaders[accessTokenKey]!.isNotEmpty,
        "The access_token can not be empty or null");

    if (headers != null) {
      _brandoHeaders.addAll(headers);
    }
    return await _requestHandler.request(
        httpVerbs: httpVerbs, uri: uri, headers: _brandoHeaders);
  }
}
