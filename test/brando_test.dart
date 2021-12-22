import 'package:brando/brando.dart';
import 'package:brando/http/clients/dio_http_request_methods_impl.dart';
import 'package:brando/http/enum/http_verbs.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'brando_test.mocks.dart';

const uriFake = "www.socialbank.com.br";

abstract class TokenMessage {
  Future<String> getTokenByEvent(String event);
}

@GenerateMocks([Brando, DioHttpRequestMethodsImpl, TokenMessage])
void main() {
  final mockDioHttpRequestMethodImpl = MockDioHttpRequestMethodsImpl();
  final MockTokenMessage mockTokenMessage = MockTokenMessage();
  final Brando brando = Brando(mockDioHttpRequestMethodImpl,
      tokenFuture: mockTokenMessage.getTokenByEvent);

  test('Should update the token with fetch event', () {
    when(brando.request(
      httpVerbs: HttpVerbs.get,
      uri: uriFake,
      headers: {
        "access_token": '',
        "content-type": "application/json",
        "accept": "application/json",
        "device_type": 0,
        "version": 0
      },
    )).thenAnswer(
      (_) => Future.value(
        Response(
          data: Object(),
          requestOptions: RequestOptions(path: uriFake),
        ),
      ),
    );

    when(mockTokenMessage.getTokenByEvent('fetch'))
        .thenAnswer((_) => Future.value("fetch"));

    expect(() async => await brando.request(httpVerbs: HttpVerbs.get, uri: uriFake, headers: {
      "access_token": 'fetch',
      "content-type": "application/json",
      "accept": "application/json",
      "device_type": 0,
      "version": 0
    }), isA<Response>());

    expect(brando.headers['access_token'], 'fetch');
  });

  test('get', () {
    when(brando.request(
      httpVerbs: HttpVerbs.get,
      uri: uriFake,
      headers: {
        "access_token": '',
        "content-type": "application/json",
        "accept": "application/json",
        "device_type": 0,
        "version": 0
      },
    )).thenThrow(DioError(
        requestOptions: RequestOptions(path: uriFake),
        type: DioErrorType.response,
        error: 401));

    when(mockTokenMessage.getTokenByEvent('fetch'))
        .thenAnswer((_) => Future.value("fetch"));

    expect(
        () async => await brando.request(
              httpVerbs: HttpVerbs.get,
              uri: uriFake,
              headers: {
                "access_token": "fetch",
                "content-type": "application/json",
                "accept": "application/json",
                "device_type": 0,
                "version": 0
              },
            ),
        throwsA(isA<DioError>()));
    expect(brando.headers['access_token'], 'fetch');
  });
}
