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
    final DioFake dio = DioFake();
    final dioHttpImpl = DioHttpRequestMethodsImpl(dio);
    
    // when(dioHttpImpl.get(uri: "uri")).thenThrow(DioError(requestOptions: RequestOptions(path: '')));

  });

}
