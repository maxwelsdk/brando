import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Stream Controller', () {
    Future<String> test(String event) async {
      if (event == "refresh") {
        return "refresh ${Dio().hashCode}";
      }
      if (event == "fetch") {
        return "fetch ${Dio().hashCode}";
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
