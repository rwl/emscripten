library emscripten.module.test;

import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:emscripten/emscripten.dart';

class TestModule extends Module {
  TestModule() : super(moduleName: 'TestModule');

  int sum(int a, int b) => callFunc('sum', [a, b]);
}

const String str = 'the quick brown fox';

final Random _r = new Random();

int rint() => _r.nextInt(9) + 1;

double rand() => _r.nextDouble();

testModule() {
  group('module', () {
    Module module;
    setUp(() {
      module = new Module(moduleName: 'TestModule');
    });
    test('constructor', () {
      expect(() {
        new Module(moduleName: 'Zyxwvu');
      }, throwsArgumentError);
    });

    test('callFunc', () {
      expect(module.callFunc('sum', [2, 2]), equals(4));
    });

    test('extends', () {
      var testModule = new TestModule();
      expect(testModule.sum(2, 1), equals(3));
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
      test('strings', () {
        var l = new List<String>.generate(rint(), (i) => str);
        Pointer ptr = module.heapStrings(l);
        expect(ptr.addr, isNonZero);
      });
      test('doubles', () {
        var l = new Float64List(rint());
        Pointer ptr = module.heapDoubles(l);
        expect(ptr.addr, isNonZero);
      });
    });

    group('deref', () {
      group('free', () {
        test('string', () {
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
          expect(module.derefDouble(ptr, false), isNot(equals(d)));
        });
        test('strings', () {
          var n = rint();
          var l = new List<String>.generate(n, (i) => str);
          Pointer ptr = module.heapStrings(l);
          List<String> l2 = module.derefStrings(ptr, n);
          expect(l2, equals(l));

          var l3 = new List<String>.generate(n, (i) => str.toUpperCase());
          module.heapStrings(l3);
          List<String> l4 = module.derefStrings(ptr, n, false);
          expect(l4, isNot(equals(l)));
        });
        test('doubles', () {
          var n = rint();
          var l = new Float64List(n);
          for (var i = 0; i < n; i++) {
            l[i] = rand();
          }
          Pointer ptr = module.heapDoubles(l);
          Float64List l2 = module.derefDoubles(ptr, n);
          expect(l2, equals(l));

          var l3 = new Float64List(n);
          for (var i = 0; i < n; i++) {
            l3[i] = -l[i];
          }
          module.heapDoubles(l3);
          Float64List l4 = module.derefDoubles(ptr, n, false);
          expect(l4, isNot(equals(l)));
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
        test('strings', () {
          var n = rint();
          var l = new List<String>.generate(n, (i) => str);
          Pointer ptr = module.heapStrings(l);
          List<String> l2 = module.derefStrings(ptr, n, false);
          expect(l2, equals(l));
          List<String> l3 = module.derefStrings(ptr, n);
          expect(l3, equals(l));
        });
        test('doubles', () {
          var n = rint();
          var l = new Float64List(n);
          for (var i = 0; i < n; i++) {
            l[i] = rand();
          }
          Pointer ptr = module.heapDoubles(l);
          Float64List l2 = module.derefDoubles(ptr, n, false);
          expect(l2, equals(l));
          Float64List l3 = module.derefDoubles(ptr, n);
          expect(l3, equals(l));
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
