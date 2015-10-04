library emscripten.test.worker;

import 'package:test/test.dart';
import 'package:emscripten/emscripten.dart';

testWorker() {
  group('worker', () {
    AsyncWorker worker;
    setUp(() {
      worker = new AsyncWorker('worker_test.js');
    });
    test('post', () async {
      var message = ['sum', 2, 2];
      var result = await worker.post(message);
      expect(result, equals(4));
    });
    test('error', () {
      var message = ['error'];
      worker.post(message).then((result) {
        fail(result);
      }, onError: (err, st) {
        expect(err, 'error message');
      });
    });
  });
}
