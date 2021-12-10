part of brando;

class _DioHttpRequestMethodsImpl implements _HttpRequestMethods {
  late final Dio _dio;

  _DioHttpRequestMethodsImpl(this._dio);

  @override
  Future delete({
    required String uri,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.delete(uri, options: Options(headers: headers));
    } catch (e, s) {
      log("delete", error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future get({
    required String uri,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response _response =
          await _dio.get(uri, options: Options(headers: headers));
      return HttpResponses.getJsonOrThrowException(_response);
    } catch (e, s) {
      log("get", error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future post(
      {required String uri,
      Map<String, dynamic>? headers,
      dynamic body}) async {
    try {
      final Response _response =
          await _dio.post(uri, options: Options(headers: headers), data: body);
      return HttpResponses.getJsonOrThrowException(_response);
    } catch (e, s) {
      log("post", error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future put(
      {required String uri,
      Map<String, dynamic>? headers,
      dynamic body}) async {
    try {
      final Response _response =
          await _dio.put(uri, options: Options(headers: headers), data: body);
      return HttpResponses.getJsonOrThrowException(_response);
    } catch (e, s) {
      log("put", error: e, stackTrace: s);
      rethrow;
    }
  }
}
