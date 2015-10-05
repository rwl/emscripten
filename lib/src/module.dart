library emscripten.module;

import 'dart:js' as js;
import 'dart:typed_data';

class Pointer {
  static final Pointer NIL = const Pointer._(0);
  final int addr;
  const Pointer._(this.addr);
}

const int SIZEOF_PTR = Int32List.BYTES_PER_ELEMENT; // Pointers are 32-bit
const int SIZEOF_INT = Int32List.BYTES_PER_ELEMENT;
const int SIZEOF_DBL = Float64List.BYTES_PER_ELEMENT;

class Module {
  final js.JsObject module;

  Module({String moduleName: 'Module', js.JsObject context})
      : module = (context == null ? js.context : context)[moduleName] {
    if (module == null) {
      throw new ArgumentError.notNull('module');
    }
  }

  Module.from(this.module) {
    if (module == null) {
      throw new ArgumentError.notNull('module');
    }
  }

  callFunc(String method, [List args]) => module.callMethod('_$method', args);

  Pointer heapStrings(List<String> l) {
    if (l == null) {
      throw new ArgumentError.notNull('l');
    }
    if (l.isEmpty) {
      throw new ArgumentError.value(l, 'l', 'empty');
    }

    var ptr = malloc(l.length * SIZEOF_PTR);
    for (var i = 0; i < l.length; i++) {
      var p = heapString(l[i]);
      var addr = ptr.addr + (i * SIZEOF_PTR);
      module.callMethod('setValue', [addr, p.addr, '*']);
    }
    return ptr;
  }

  List<String> derefStrings(Pointer ptr, int n, [bool free = true]) {
    if (ptr == null || ptr == Pointer.NIL) {
      throw new ArgumentError.notNull('ptr');
    }
    if (n == null || n <= 0) {
      throw new ArgumentError.value(n, 'n', 'non positive');
    }
    var l = new List<String>(n);
    for (var i = 0; i < n; i++) {
      var addr = ptr.addr + (i * SIZEOF_PTR);
      int p = module.callMethod('getValue', [addr, '*']);
      l[i] = stringify(new Pointer._(p), free);
    }
    if (free) {
      this.free(ptr);
    }
    return l;
  }

  Pointer heapDoubles(Float64List l) {
    if (l == null) {
      throw new ArgumentError.notNull('l');
    }
    if (l.isEmpty) {
      throw new ArgumentError.value(l, 'l', 'empty');
    }
    var ptr = malloc(l.lengthInBytes);
    module.callMethod('setTypedData', [l, ptr.addr]);
    return ptr;
  }

  Float64List derefDoubles(Pointer ptr, int n, [bool free = true]) {
    if (ptr == null || ptr == Pointer.NIL) {
      throw new ArgumentError.notNull('ptr');
    }
    if (n == null || n <= 0) {
      throw new ArgumentError.value(n, 'n', 'non positive');
    }
    var l = module.callMethod('getFloat64Array', [ptr.addr, n]);
    if (free) {
      this.free(ptr);
    }
    return l;
  }

  Pointer heapString(String s) {
    if (s == null) {
      return Pointer.NIL;
    }
    var ptr = malloc(s.length + 1);
    module.callMethod('writeStringToMemory', [s, ptr.addr]);
    return ptr;
  }

  Pointer heapInt(int i) {
    var ptr = malloc(SIZEOF_INT);
    if (i != null) {
      module.callMethod('setValue', [ptr.addr, i, 'i32']);
    }
    return ptr;
  }

  Pointer heapDouble(double d) {
    var ptr = malloc(SIZEOF_DBL);
    if (d != null) {
      module.callMethod('setValue', [ptr.addr, d, 'double']);
    }
    return ptr;
  }

  int derefInt(Pointer ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var i = module.callMethod('getValue', [ptr.addr, 'i32']);
    if (free) {
      this.free(ptr);
    }
    return i;
  }

  double derefDouble(Pointer ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var d = module.callMethod('getValue', [ptr.addr, 'double']);
    if (free) {
      this.free(ptr);
    }
    return d;
  }

  String stringify(Pointer ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var s = module.callMethod('Pointer_stringify', [ptr.addr]);
    if (free) {
      this.free(ptr);
    }
    return s;
  }

  Pointer malloc(int numBytes) {
    if (numBytes == null) {
      throw new ArgumentError.notNull('numBytes');
    }
    var addr = module.callMethod('_malloc', [numBytes]);
    return new Pointer._(addr);
  }

  void free(Pointer ptr) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    module.callMethod('_free', [ptr.addr]);
  }
}
