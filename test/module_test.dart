library emscripten.module.test;

import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:complex/complex.dart';
import 'package:emscripten/emscripten.dart';

class TestModule extends Module {
  TestModule() : super(moduleName: 'TestModule');

  int sum(int a, int b) => callFunc('sum', [a, b]);
}

const String str = 'the quick brown fox';

final Random _r = new Random();

int rint() => _r.nextInt(9) + 1;

double rand() => _r.nextDouble();

main() {
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
      int ptr = module.heapString('the quick brown fox');
      expect(ptr, isNonZero);
    });
    test('int', () {
      int ptr = module.heapInt(42);
      expect(ptr, isNonZero);
    });
    test('double', () {
      int ptr = module.heapDouble(3.14);
      expect(ptr, isNonZero);
    });
    test('complex', () {
      var c = new Complex(rand(), rand());
      int ptr = module.heapComplex(c);
      expect(ptr, isNonZero);
      var c2 = module.derefComplex(ptr);
      expect(c2, equals(c));
    });
    test('strings', () {
      var l = new List<String>.generate(rint(), (i) => str);
      int ptr = module.heapStrings(l);
      expect(ptr, isNonZero);
    });
    test('doubles', () {
      var l = new Float64List(rint());
      int ptr = module.heapDoubles(l);
      expect(ptr, isNonZero);
    });
    test('ints', () {
      var l = new Int32List(rint());
      int ptr = module.heapInts(l);
      expect(ptr, isNonZero);
    });
    test('complex list', () {
      int n = rint();
      var l = new List.generate(n, (_) => new Complex(rand(), rand()));
      int ptr = module.heapComplexList(l);
      expect(ptr, isNonZero);
    });
  });

  group('deref', () {
    group('free', () {
      test('string', () {
        int ptr = module.heapString(str);
        expect(module.stringify(ptr), equals(str));
        module.heapString(str.toUpperCase());
        expect(module.stringify(ptr, false), isNot(equals(str)));
      });
      test('int', () {
        var i = rint();
        int ptr = module.heapInt(i);
        expect(module.derefInt(ptr), equals(i));
        module.heapInt(-i);
        expect(module.derefInt(ptr, false), isNot(equals(i)));
      });
      test('double', () {
        var d = rand();
        int ptr = module.heapDouble(d);
        expect(module.derefDouble(ptr), equals(d));
        module.heapDouble(-d);
        expect(module.derefDouble(ptr, false), isNot(equals(d)));
      });
      test('complex', () {
        var c = new Complex(rand(), rand());
        int ptr = module.heapComplex(c);
        expect(module.derefComplex(ptr), equals(c));
        module.heapComplex(-c);
        expect(module.derefComplex(ptr, false), isNot(equals(c)));
      });
      test('strings', () {
        var n = rint();
        var l = new List<String>.generate(n, (i) => str);
        int ptr = module.heapStrings(l);
        List<String> l2 = module.derefStrings(ptr, n);
        expect(l2, equals(l));

        var l3 = new List<String>.generate(n, (i) => str.toUpperCase());
        module.heapStrings(l3);
        List<String> l4 = module.derefStrings(ptr, n, false);
        expect(l4, isNot(equals(l)));
        // TODO: test `len` arg
      });
      test('doubles', () {
        var n = rint();
        var l = new Float64List(n);
        for (var i = 0; i < n; i++) {
          l[i] = rand();
        }
        int ptr = module.heapDoubles(l);
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
      test('ints', () {
        var n = rint();
        var l = new Int32List(n);
        for (var i = 0; i < n; i++) {
          l[i] = rint();
        }
        int ptr = module.heapInts(l);
        Int32List l2 = module.derefInts(ptr, n);
        expect(l2, equals(l));

        var l3 = new Int32List(n);
        for (var i = 0; i < n; i++) {
          l3[i] = -l[i];
        }
        module.heapInts(l3);
        Int32List l4 = module.derefInts(ptr, n, false);
        expect(l4, isNot(equals(l)));
      });
      test('complex list', () {
        var n = rint();
        var l = new List<Complex>(n);
        for (var i = 0; i < n; i++) {
          l[i] = new Complex(rand(), rand());
        }
        int ptr = module.heapComplexList(l);
        List<Complex> l2 = module.derefComplexList(ptr, n);
        expect(l2, equals(l));

        var l3 = new List<Complex>(n);
        for (var i = 0; i < n; i++) {
          l3[i] = -l[i];
        }
        module.heapComplexList(l3);
        List<Complex> l4 = module.derefComplexList(ptr, n, false);
        expect(l4, isNot(equals(l)));
      });
    });
    group('keep', () {
      test('string', () {
        var str = 'the quick brown fox';
        int ptr = module.heapString(str);
        expect(module.stringify(ptr, false), equals(str));
        expect(module.stringify(ptr), equals(str));
      });
      test('int', () {
        var i = 42;
        int ptr = module.heapInt(i);
        expect(module.derefInt(ptr, false), equals(i));
        expect(module.derefInt(ptr), equals(i));
      });
      test('double', () {
        var d = 3.14;
        int ptr = module.heapDouble(d);
        expect(module.derefDouble(ptr, false), equals(d));
        expect(module.derefDouble(ptr), equals(d));
      });
      test('strings', () {
        var n = rint();
        var l = new List<String>.generate(n, (i) => str);
        int ptr = module.heapStrings(l);
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
        int ptr = module.heapDoubles(l);
        Float64List l2 = module.derefDoubles(ptr, n, false);
        expect(l2, equals(l));
        // TODO: Check values are copied
        Float64List l3 = module.derefDoubles(ptr, n);
        expect(l3, equals(l));
      });
      test('ints', () {
        var n = rint();
        var l = new Int32List(n);
        for (var i = 0; i < n; i++) {
          l[i] = rint();
        }
        int ptr = module.heapInts(l);
        Int32List l2 = module.derefInts(ptr, n, false);
        expect(l2, equals(l));
        // TODO: Check values are copied
        Int32List l3 = module.derefInts(ptr, n);
        expect(l3, equals(l));
      });
      test('complex list', () {
        var n = rint();
        var l = new List<Complex>(n);
        for (var i = 0; i < n; i++) {
          l[i] = new Complex(rand(), rand());
        }
        int ptr = module.heapComplexList(l);
        List<Complex> l2 = module.derefComplexList(ptr, n, false);
        expect(l2, equals(l));
        // TODO: Check values are copied
        List<Complex> l3 = module.derefComplexList(ptr, n);
        expect(l3, equals(l));
      });
    });
  });

  test('malloc', () {
    expect(module.malloc(4), isNonZero);
  });

  test('free', () {
    var ptr = module.malloc(4);
    expect(() => module.free(ptr), returnsNormally);
    expect(() => module.free(ptr), throws);
  });
  // TODO: test freeStrings
}
