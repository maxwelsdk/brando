/// Classe base para métodos HTTP.
abstract class HttpRequestMethods {
  Future post({required String uri, Map? headers, Map? body});

  Future get({required String uri, Map? headers});

  Future delete({required String uri, Map? headers});

  Future put({required String uri, Map? headers, Map? body});

  Future options({required String uri, Map? headers});
}
