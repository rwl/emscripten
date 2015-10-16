// TypedData gets converted to ArrayBuffer in Dartium.
Module['setTypedData'] = function(arrayBuffer, offset) {
  if (typeof arrayBuffer.buffer !== 'undefined') {
    arrayBuffer = arrayBuffer.buffer;
  }
  var bytes = new Uint8Array(arrayBuffer);
  Module['HEAPU8'].set(bytes, offset);
}

Module['getFloat64Array'] = function(ptr, length) {
  return new Float64Array(Module['buffer'], ptr, length);
}

Module['getInt32Array'] = function(ptr, length) {
  return new Int32Array(Module['buffer'], ptr, length);
}

Module['getFS'] = function() {
  return FS;
}
