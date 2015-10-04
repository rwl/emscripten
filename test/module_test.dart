library emscripten.module.test;

import 'package:test/test.dart';
import 'package:emscripten/emscripten.dart';

testModule() {
  group('module', () {
    Module module;
    setUp(() {
      module = new Module(moduleName: 'TestModule', exportedFunctions: ['sum']);
    });
    test('constructor', () {
      expect(() {
        new Module(moduleName: 'Zyxwvu');
      }, throwsArgumentError);
    });

    test('proxy', () {
      expect(module.sum(1, 2), equals(3));
    });

    test('callMethod', () {
      expect(module.callMethod('sum', [2, 2]), equals(4));
    });

    group('malloc', () {
      test('string', () {
        Pointer ptr = module.heapString('the quick brown fox');
        expect(ptr.addr, isNonZero);
      });
      test('int', () {
        Pointer ptr = module.heapInt(42);
        expect(ptr.addr, isNonZero);
      });
      test('double', () {
        Pointer ptr = module.heapDouble(3.14);
        expect(ptr.addr, isNonZero);
      });
    });

    group('deref', () {
      group('free', () {
        test('string', () {
          var str = 'the quick brown fox';
          Pointer ptr = module.heapString(str);
          expect(module.stringify(ptr), equals(str));
          module.heapString(str.toUpperCase());
          expect(module.stringify(ptr, false), isNot(equals(str)));
        });
        test('int', () {
          var i = 42;
          Pointer ptr = module.heapInt(i);
          expect(module.derefInt(ptr), equals(i));
          module.heapInt(-i);
          expect(module.derefInt(ptr, false), isNot(equals(i)));
        });
        test('double', () {
          var d = 3.14;
          Pointer ptr = module.heapDouble(d);
          expect(module.derefDouble(ptr), equals(d));
          module.heapDouble(-d);
          expect(module.derefDouble(ptr, true), isNot(equals(d)));
        });
      });
      group('keep', () {
        test('string', () {
          var str = 'the quick brown fox';
          Pointer ptr = module.heapString(str);
          expect(module.stringify(ptr, false), equals(str));
          expect(module.stringify(ptr), equals(str));
        });
        test('int', () {
          var i = 42;
          Pointer ptr = module.heapInt(i);
          expect(module.derefInt(ptr, false), equals(i));
          expect(module.derefInt(ptr), equals(i));
        });
        test('double', () {
          var d = 3.14;
          Pointer ptr = module.heapDouble(d);
          expect(module.derefDouble(ptr, false), equals(d));
          expect(module.derefDouble(ptr), equals(d));
        });
      });
    });

    test('malloc', () {
      expect(module.malloc(4), isNotNull);
      expect(module.malloc(4).addr, isNonZero);
    });

    test('free', () {
      var ptr = module.malloc(4);
      expect(() => module.free(ptr), returnsNormally);
      expect(() => module.free(ptr), throws);
    });
  });
}
