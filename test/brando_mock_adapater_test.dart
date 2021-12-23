import 'dart:io';
import 'dart:math';

import 'package:brando/brando.dart';
import 'package:brando/http/clients/dio_http_request_methods_impl.dart';
import 'package:brando/http/enum/http_verbs.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class _TokenMessage {
  Future<String> getTokenByEvent(String event) async {
    if (event == 'fetch') {
      return Future.value("cachedToken");
    } else if (event == 'refresh') {
      return Future.value("newToken");
    }
    return Future.value("no-getTokenByEvent");
  }
}

void main() {
  final _TokenMessage _tokenMessage = _TokenMessage();
  late Dio dio;
  late DioAdapter dioAdapter;
  late Brando _brando;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    _brando = Brando(DioHttpRequestMethodsImpl(dio),
        tokenFuture: _tokenMessage.getTokenByEvent);
  });

  test('Should perform a GET: /wallet and retrieve a list', () async {
    dioAdapter.onGet("/wallet/cards", (server) {
      server.reply(200, {'cards': []});
    });

    Response _response =
        await _brando.request(httpVerbs: HttpVerbs.get, uri: "/wallet/cards");

    expect(_response.statusCode, 200);
    expect(_response.data['cards'], isA<List>());
    expect(_brando.headers['access_token'], 'cachedToken');
  });

  test("Should perform a DELETE http method", () async {
    dioAdapter.onDelete("/wallet/1", (server) {
      server.reply(HttpStatus.noContent, {});
    });

    Response _response =
        await _brando.request(httpVerbs: HttpVerbs.delete, uri: "/wallet/1");

    expect(_response.statusCode, 204);
  });

  test("Should perform a POST: /wallet creating a resource", () async {
    dioAdapter.onPost("/wallet", (server) {
      server.reply(HttpStatus.created, {"wallet_id": Random().nextInt(100)});
    });

    Response _response =
        await _brando.request(httpVerbs: HttpVerbs.post, uri: "/wallet");

    expect(_response.statusCode, 201);
  });

  test("Should perform a PUT: /wallet/card/2 creating a resource", () async {
    dioAdapter.onPut("/wallet/card/2", (server) {
      server.reply(HttpStatus.ok, {"id": Random().nextInt(100)});
    });

    Response _response =
        await _brando.request(httpVerbs: HttpVerbs.put, uri: "/wallet/card/2");

    expect(_response.statusCode, 200);
  });

  test("Should perform a GET: /wallet/2 on a non existing resource", () async {
    dioAdapter.onGet("/wallet/2", (server) {
      server.reply(HttpStatus.notFound, {});
    });

    expect(
      () async => await _brando.request(
        httpVerbs: HttpVerbs.get,
        uri: "/wallet/2",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "device_type": 0,
          "version": 0
        },
      ),
      throwsA(
        predicate((actual) {
          expect(actual, isA<DioError>());
          if (actual is DioError) {
            expect(actual.response?.statusCode, 404);
          }
          return true;
        }),
      ),
    );
  });

  test(
      'Should perform a GET: /wallet and throw a unauthorized exception from DioError',
      () {
    dioAdapter.onGet("/wallet", (server) {
      server.reply(HttpStatus.unauthorized, {});
    });

    expect(
      () async => await _brando.request(
        httpVerbs: HttpVerbs.get,
        uri: "/wallet",
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "device_type": 0,
          "version": 0
        },
      ),
      throwsA(
        predicate((actual) {
          expect(actual, isA<DioError>());
          if (actual is DioError) {
            expect(actual.response?.statusCode, 401);
          }
          return true;
        }),
      ),
    );
  });
}
