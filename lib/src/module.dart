library emscripten.module;

import 'dart:js' as js;
import 'dart:typed_data';

class Pointer {
  static final Pointer NIL = const Pointer._(0);
  final int addr;
  const Pointer._(this.addr);
}

@proxy
class Module {
  final js.JsObject module;
  Map<Symbol, String> _exportedFunctions;

  factory Module(
      {String moduleName: 'Module',
      js.JsObject context,
      List<String> exportedFunctions: const []}) {
    var m = (context == null ? js.context : context)[moduleName];
    return new Module.from(m, exportedFunctions: exportedFunctions);
  }

  Module.from(this.module, {List<String> exportedFunctions: const []})
      : _exportedFunctions = new Map<Symbol, String>.fromIterable(
            exportedFunctions,
            key: (String name) => new Symbol(name),
            value: (String name) => name) {
    if (module == null) {
      throw new ArgumentError.notNull('module');
    }
  }

  noSuchMethod(Invocation invocation) {
    if (invocation.isMethod &&
        _exportedFunctions.containsKey(invocation.memberName)) {
      var name = _exportedFunctions[invocation.memberName];
      return module.callMethod('_$name', invocation.positionalArguments);
    } else {
      super.noSuchMethod(invocation);
    }
  }

  callMethod(String method, [List args]) => module.callMethod('_$method', args);

  Pointer heapString(String s) {
    if (s == null) {
      return Pointer.NIL;
    }
    var ptr = malloc(s.length + 1);
    module.callMethod('writeStringToMemory', [s, ptr.addr]);
    return ptr;
  }

  Pointer heapInt(int i) {
    var ptr = malloc(Int32List.BYTES_PER_ELEMENT);
    if (i != null) {
      module.callMethod('setValue', [ptr.addr, i, 'i32']);
    }
    return ptr;
  }

  Pointer heapDouble(double d) {
    var ptr = malloc(Float64List.BYTES_PER_ELEMENT);
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
