library emscripten.fs.test;

import 'package:test/test.dart';
import 'package:emscripten/emscripten.dart';
import 'package:emscripten/experimental.dart';

import 'module_test.dart' show str;

main() {
  FS fs;
  setUp(() {
    var module = new Module.func('TestModule');
    fs = new FS.func(module.module);
  });

  test('writeFile', () {
    fs.writeFile('file', str);
    var contents = fs.readFile('file');
    expect(contents, equals(str));
  });
  test('unlink', () {
    fs.writeFile('file', str);
    fs.unlink('file');
  });
}
