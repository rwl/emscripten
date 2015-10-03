library emscripten.worker;

import 'dart:math';
import 'dart:async';
import 'dart:html';

/// Posts messages to a [Worker] and provides an asynchronous response.
class AsyncWorker {
  final Worker _worker;
  final Random _r;

  /// Creates a worker that executes the script at [scriptUrl].
  AsyncWorker(String scriptUrl)
      : _worker = new Worker(scriptUrl),
        _r = new Random();

  _generateId() => _r.nextInt(65535);

  /// Associates an ID with the [message] before posting it to the [Worker].
  /// The returned [Future] completes when the worker posts a reply with the
  /// same ID. For example, within the worker script:
  ///
  ///     this.onmessage = function (event) {
  ///       event["data"]; // [id, message]
  ///
  ///       if (error) {
  ///         this.postMessage([id, ["error", error]]);
  ///       }
  ///       this.postMessage([id, result]);
  ///     }
  Future post(List message) {
    var c = new Completer();
    var id = _generateId();

    StreamSubscription subscription;

    onReply(MessageEvent event) {
      var reply = event.data;
      if (reply is List && reply.isNotEmpty && reply[0] == id) {
        subscription.cancel();
        if (reply.length > 1) {
          // Unpack the result
          var result = reply[1];
          if (result is List && result.isNotEmpty && result[0] == "error") {
            c.completeError(result.length > 1 ? result[1] : null);
          } else {
            c.complete(result);
          }
        } else {
          c.complete();
        }
      } else if (reply is String && reply.startsWith("error")) {
        c.completeError(reply);
      }
    }

    subscription = _worker.onMessage.listen(onReply);
    _worker.postMessage([id, message]);

    return c.future;
  }

  /// Immediately terminates the [Worker].
  void terminate() => _worker.terminate();
}
