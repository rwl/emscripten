library emscripten.module;

import 'dart:js' as js;
import 'dart:typed_data';

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

  int heapStrings(List<String> list) {
    if (list == null) {
      throw new ArgumentError.notNull('list');
    }
    if (list.isEmpty) {
      throw new ArgumentError.value(list, 'list', 'empty');
    }

    var ptr = malloc(list.length * SIZEOF_PTR);
    for (var i = 0; i < list.length; i++) {
      var p = heapString(list[i]);
      var addr = ptr + (i * SIZEOF_PTR);
      module.callMethod('setValue', [addr, p, '*']);
    }
    return ptr;
  }

  List<String> derefStrings(int ptr, int n, [bool free = true]) {
    if (ptr == null || ptr == 0) {
      throw new ArgumentError.notNull('ptr');
    }
    if (n == null || n <= 0) {
      throw new ArgumentError.value(n, 'n', 'non positive');
    }
    var list = new List<String>(n);
    for (var i = 0; i < n; i++) {
      var addr = ptr + (i * SIZEOF_PTR);
      int p = module.callMethod('getValue', [addr, '*']);
      list[i] = stringify(p, free);
    }
    if (free) {
      this.free(ptr);
    }
    return list;
  }

  /// Requires `--post-js packages/emscripten/post.js` on compilation.
  int heapDoubles(Float64List list) {
    if (list == null) {
      throw new ArgumentError.notNull('list');
    }
    if (list.isEmpty) {
      throw new ArgumentError.value(list, 'list', 'empty');
    }
    var ptr = malloc(list.lengthInBytes);
    module.callMethod('setTypedData', [list, ptr]);
    return ptr;
  }

  /// Requires `--post-js packages/emscripten/post.js` on compilation.
  Float64List derefDoubles(int ptr, int n, [bool free = true]) {
    if (ptr == null || ptr == 0) {
      throw new ArgumentError.notNull('ptr');
    }
    if (n == null || n <= 0) {
      throw new ArgumentError.value(n, 'n', 'non positive');
    }
    Float64List list = module.callMethod('getFloat64Array', [ptr, n]);
    list = new Float64List.fromList(list);
    if (free) {
      this.free(ptr);
    }
    return list;
  }

  /// Requires `--post-js packages/emscripten/post.js` on compilation.
  int heapInts(Int32List list) {
    if (list == null) {
      throw new ArgumentError.notNull('list');
    }
    if (list.isEmpty) {
      throw new ArgumentError.value(list, 'list', 'empty');
    }
    var ptr = malloc(list.lengthInBytes);
    module.callMethod('setTypedData', [list, ptr]);
    return ptr;
  }

  /// Requires `--post-js packages/emscripten/post.js` on compilation.
  Int32List derefInts(int ptr, int n, [bool free = true]) {
    if (ptr == null || ptr == 0) {
      throw new ArgumentError.notNull('ptr');
    }
    if (n == null || n <= 0) {
      throw new ArgumentError.value(n, 'n', 'non positive');
    }
    Int32List list = module.callMethod('getInt32Array', [ptr, n]);
    list = new Int32List.fromList(list);
    if (free) {
      this.free(ptr);
    }
    return list;
  }

  int heapString(String s) {
    if (s == null) {
      return 0;
    }
    var ptr = malloc(s.length + 1);
    module.callMethod('writeStringToMemory', [s, ptr]);
    return ptr;
  }

  int heapInt([int i = 0]) {
    var ptr = malloc(SIZEOF_INT);
    if (i != null) {
      module.callMethod('setValue', [ptr, i, 'i32']);
    }
    return ptr;
  }

  int heapDouble([double d = 0.0]) {
    var ptr = malloc(SIZEOF_DBL);
    if (d != null) {
      module.callMethod('setValue', [ptr, d, 'double']);
    }
    return ptr;
  }

  int derefInt(int ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var i = module.callMethod('getValue', [ptr, 'i32']);
    if (free) {
      this.free(ptr);
    }
    return i;
  }

  double derefDouble(int ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var d = module.callMethod('getValue', [ptr, 'double']);
    if (free) {
      this.free(ptr);
    }
    return d;
  }

  String stringify(int ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var s = module.callMethod('Pointer_stringify', [ptr]);
    if (free) {
      this.free(ptr);
    }
    return s;
  }

  int malloc(int numBytes) {
    if (numBytes == null) {
      throw new ArgumentError.notNull('numBytes');
    }
    return module.callMethod('_malloc', [numBytes]);
  }

  void free(int ptr) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    module.callMethod('_free', [ptr]);
  }
}
