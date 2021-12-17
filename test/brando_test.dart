import 'dart:async';
import 'dart:math';

import 'package:brando/http/clients/dio_http_request_methods_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([DioHttpRequestMethodsImpl, DioFake])
class DioFake with DioMixin implements Dio {
}

void main() {
  test('description', () {
    // final DioFake dio = DioFake();
    // final dioHttpImpl = DioHttpRequestMethodsImpl(dio);

    // when(dioHttpImpl.get(uri: "uri")).thenThrow(DioError(requestOptions: RequestOptions(path: '')));
  });

  test('Stream Controller', () {
    Future<String> test(String event) async {
      if (event == "refresh") {
        return "refresh ${DioFake().hashCode}";
      }
      if (event == "fetch") {
        return "fetch ${DioFake().hashCode}";
      }
      return "";
    }

    Giorno giorno = Giorno(test);

    giorno.request('refresh');
    giorno.request('fetch');

  });
}


class Giorno {
  Future<String> Function(String) stream;

  Giorno(this.stream);

  void request(String event) async {
    await stream.call(event).then((value) => print(value));
  }
}