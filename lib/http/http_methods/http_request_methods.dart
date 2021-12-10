part of brando;
/// Classe base para métodos HTTP.
abstract class _HttpRequestMethods {
  Future post(
      {required String uri, Map<String, dynamic>? headers, dynamic body});

  Future get({
    required String uri,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  });

  Future delete({
    required String uri,
    Map<String, dynamic>? headers,
  });

  Future put({
    required String uri,
    Map<String, dynamic>? headers,
    dynamic body,
  });
}
