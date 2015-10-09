library emscripten.module;

import 'dart:js' as js;
import 'dart:typed_data';

const int SIZEOF_PTR = Int32List.BYTES_PER_ELEMENT; // Pointers are 32-bit
const int SIZEOF_INT = Int32List.BYTES_PER_ELEMENT;
const int SIZEOF_DBL = Float64List.BYTES_PER_ELEMENT;

class Module {
  final js.JsObject _module;

  Module({String moduleName: 'Module', js.JsObject context})
      : _module = (context == null ? js.context : context)[moduleName] {
    if (_module == null) {
      throw new ArgumentError.notNull('module');
    }
  }

  Module.from(this._module) {
    if (_module == null) {
      throw new ArgumentError.notNull('module');
    }
  }

  /// Prepends [name] with an `_` before calling module method with [args].
  callFunc(String name, [List args]) => _module.callMethod('_$name', args);

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
      _module.callMethod('setValue', [addr, p, '*']);
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
      int p = _module.callMethod('getValue', [addr, '*']);
      list[i] = stringify(p, free);
    }
    if (free) {
      this.free(ptr);
    }
    return list;
  }

  void freeStrings(int ptr, int n) {
    if (ptr == null || ptr == 0) {
      throw new ArgumentError.notNull('ptr');
    }
    if (n == null || n <= 0) {
      throw new ArgumentError.value(n, 'n', 'non positive');
    }
    for (var i = 0; i < n; i++) {
      var addr = ptr + (i * SIZEOF_PTR);
      int p = _module.callMethod('getValue', [addr, '*']);
      free(ptr);
    }
    free(ptr);
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
    _module.callMethod('setTypedData', [list, ptr]);
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
    Float64List list = _module.callMethod('getFloat64Array', [ptr, n]);
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
    _module.callMethod('setTypedData', [list, ptr]);
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
    Int32List list = _module.callMethod('getInt32Array', [ptr, n]);
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
    _module.callMethod('writeStringToMemory', [s, ptr]);
    return ptr;
  }

  int heapInt([int i = 0]) {
    var ptr = malloc(SIZEOF_INT);
    if (i != null) {
      _module.callMethod('setValue', [ptr, i, 'i32']);
    }
    return ptr;
  }

  int heapDouble([double d = 0.0]) {
    var ptr = malloc(SIZEOF_DBL);
    if (d != null) {
      _module.callMethod('setValue', [ptr, d, 'double']);
    }
    return ptr;
  }

  int derefInt(int ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var i = _module.callMethod('getValue', [ptr, 'i32']);
    if (free) {
      this.free(ptr);
    }
    return i.toInt();
  }

  double derefDouble(int ptr, [bool free = true]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var d = _module.callMethod('getValue', [ptr, 'double']);
    if (free) {
      this.free(ptr);
    }
    return d.toDouble();
  }

  String stringify(int ptr, [bool free = true, int len]) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    var args = [ptr];
    if (len != null) {
      args.add(len);
    }
    var s = _module.callMethod('Pointer_stringify', args);
    if (free) {
      this.free(ptr);
    }
    return s;
  }

  int malloc(int numBytes) {
    if (numBytes == null) {
      throw new ArgumentError.notNull('numBytes');
    }
    return _module.callMethod('_malloc', [numBytes]);
  }

  void free(int ptr) {
    if (ptr == null) {
      throw new ArgumentError.notNull('ptr');
    }
    _module.callMethod('_free', [ptr]);
  }
}
