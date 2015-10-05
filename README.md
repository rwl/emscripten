# Emscripten

Access [Emscripten](http://emscripten.org) modules from
[Dart](https://dartlang.org).

## Usage

```dart
import 'package:emscripten/emscripten.dart';

main() {
  var module = new Module();
  var name = module.heapString('Alice');
  var greet = module.callFunc('greeting', [name]);
  print(module.stringify(greet));
  module.free(name);
}
```
