import 'package:test/test.dart';

import 'module_test.dart' as moduleTest;
import 'worker_test.dart' as workerTest;
import 'fs_test.dart' as fsTest;

main() {
  group('module', moduleTest.main);
  group('worker', workerTest.main);
  group('fs', fsTest.main);
}
