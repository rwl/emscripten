if (this.document === undefined) {
  this.onmessage = function(event) {
    var payload = event["data"];
    var id = payload[0], message = payload[1];
    var cmd = message[0];
    var result;

    if (cmd == "sum") {
      result = message[1] + message[2];
    }

    if (cmd == "error") {
      result = ["error", "error message"];
    }

    this.postMessage([id, result]);
  }
}
