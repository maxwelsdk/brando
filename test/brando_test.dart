import 'package:brando/brando.dart';
import 'package:brando/http/http_handler_sb.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // test('Should run http use case with Dio Client', () async {
  //   final Brando brando = Brando(Dio());
  //
  //   await brando
  //       .request(
  //           httpVerbs: HttpVerbs.get,
  //           uri: "https://www.omdbapi.com/?s=Batman&apiKey=ec6cf447")
  //       .then((value) => print(value));
  // });

  test('Should update header access_token key', () async {
    const token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6OTkyMjIzOTIsInBybiI6IjU1MzkxMyIsImV4dHJhIjoiNjEzMjA1IiwiaXNzIjoiYWNjb3VudHMiLCJhdWQiOiI4MjE0MDgiLCJleHAiOjE2Mzg5OTIyNTI3MzYsInNjb3BlIjpbIlVTRVIiXX0=.46udpu1rppZtMIKEtd/EW7IrXFzHrn45fE8T/BK2OdM=";
    final Brando brando = Brando(Dio());

    brando.accessToken = token;

    await brando.request(
        httpVerbs: HttpVerbs.get,
        uri: "https://www.omdbapi.com/?s=Batman&apiKey=ec6cf447");

    expect(brando.headers[accessTokenKey], token);
  });

  test('Should fail when trying to fetch data without token', () async {
    final Brando brando = Brando(Dio());

    expect(await brando.request(httpVerbs: HttpVerbs.get, uri: "https://thisShouldFail.com"), isA<AssertionError>());

  });
}
