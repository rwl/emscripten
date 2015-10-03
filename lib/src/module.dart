library emscripten.module;

import 'dart:js' as js;
import 'dart:typed_data';

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
    Symbol s;
    if (invocation.isMethod &&
        _exportedFunctions.containsKey(invocation.memberName)) {
      var name = _exportedFunctions[invocation.memberName];
      return module.callMethod('_$name', invocation.positionalArguments);
    } else {
      super.noSuchMethod(invocation);
    }
  }

  callMethod(String method, [List args]) => module.callMethod('_$method', args);

  int heapString(String s) {
    if (s == null) {
      return 0;
    }
    var ptr = module.callMethod('_malloc', [s.length + 1]);
    module.callMethod('writeStringToMemory', [s, ptr]);
    return ptr;
  }

  int heapInt(int i) {
    const i32 = Int32List.BYTES_PER_ELEMENT;
    var ptr = module.callMethod('_malloc', [i32]);
    module.callMethod('setValue', [ptr, i, 'i32']);
    return ptr;
  }

  int heapDouble(double d) {
    const bytes = Float64List.BYTES_PER_ELEMENT;
    var ptr = module.callMethod('_malloc', [bytes]);
    module.callMethod('setValue', [ptr, d, 'double']);
    return ptr;
  }

  int derefInt(int ptr, [bool free = true]) {
    var i = module.callMethod('getValue', [ptr, 'i32']);
    if (free) {
      this.free(ptr);
    }
    return i;
  }

  double derefDouble(int ptr, [bool free = true]) {
    var d = module.callMethod('getValue', [ptr, 'double']);
    if (free) {
      this.free(ptr);
    }
    return d;
  }

  String stringify(int ptr, {/*int len,*/ bool free: true}) {
    var args = [ptr];
    /*if (len != null) {
      args.add(len);
    }*/
    var s = module.callMethod('Pointer_stringify', args);
    if (free) {
      this.free(ptr);
    }
    return s;
  }

  void free(int ptr) {
    module.callMethod('_free', [ptr]);
  }
}
