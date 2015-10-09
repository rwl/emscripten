library emscripten.fs;

import 'dart:js' as js;
import 'dart:typed_data';

//class FSType {
//  final _value;
//  const FSType._(this._value);
//  toString() => 'FSType.$_value';
//
//  static const MEMFS = const FSType._('MEMFS');
//  static const NODEFS = const FSType._('NODEFS');
//  static const IDBFS = const FSType._('IDBFS');
//  static const WORKERFS = const FSType._('WORKERFS');
//}

class FS {
  final js.JsObject _module;

  FS({js.JsObject context, String moduleName: 'FS'})
      : _module = (context == null ? js.context : context)[moduleName];

  /// Converts a major and minor number into a single unique integer. This
  /// is used as an id to represent the device.
  int makedev(int ma, int mi) => _module.callMethod('makedev', [ma, mi]);

  /// Registers the specified device driver with a set of callbacks.
  void registerDevice(int dev, Map<String, Function> ops) {
    var _ops = new js.JsObject.jsify(ops);
    _module.callMethod('registerDevice', [dev, _ops]);
  }

  /// Sets up standard I/O devices for `stdin`, `stdout`, and `stderr`.
  void init([input(), output(code), error(code)]) {
    _module.callMethod('init', [input, output, error]);
  }

  /// Mounts the FS object specified by [type] to the directory specified by
  /// [mountpoint]. The [opts] map is specific to each file system type.
  mount(FSType type, Map<String, dynamic> opts, String mountpoint) {
    var _opts = new js.JsObject.jsify(opts);
    return _module.callMethod('mount', [type._value, _opts, mountpoint]);
  }

  /// Unmounts the specified [mountpoint].
  void unmount(String mountpoint) {
    _module.callMethod('unmount', [mountpoint]);
  }

  /// Responsible for iterating and synchronizing all mounted file systems
  /// in an asynchronous fashion.
  void syncfs(bool populate, callback(errno)) {
    _module.callMethod('syncfs', [populate, callback]);
  }

  /// Creates a new directory node in the file system.
  mkdir(String path, [int mode = 511]) {
    return _module.callMethod('mkdir', [path, mode]);
  }

  /// Creates a new device node in the file system referencing the registered
  /// device driver ([registerDevice]) for [dev].
  mkdev(String path, int dev, [int mode = 438]) {
    return _module.callMethod('mkdev', [path, mode, dev]);
  }

  /// Creates a symlink node at [newpath] linking to [oldpath].
  symlink(String oldpath, String newpath) {
    return _module.callMethod('symlink', [oldpath, newpath]);
  }

  /// Renames the node at [oldpath] to [newpath].
  void rename(String oldpath, String newpath) {
    _module.callMethod('rename', [oldpath, newpath]);
  }

  /// Removes an empty directory located at [path].
  void rmdir(String path) => _module.callMethod('rmdir', [path]);

  /// Unlinks the node at [path].
  ///
  /// This removes a name from the file system. If that name was the last link
  /// to a file (and no processes have the file open) the file is deleted.
  void unlink(String path) => _module.callMethod('unlink', [path]);

  /// Gets the string value stored in the symbolic link at [path].
  String readlink(String path) => _module.callMethod('readlink', [path]);

  /// Gets a map containing statistics about the node at [path].
  Map<String, dynamic> stat(String path) {
    return _module.callMethod('stat', [path]);
  }

  /// Identical to [stat]. However, if [path] is a symbolic link then the
  /// returned stats will be for the link itself, not the file that it links
  /// to.
  Map<String, dynamic> lstat(String path) {
    return _module.callMethod('lstat', [path]);
  }

  /// Change the mode flags for [path] to [mode].
  void chmod(String path, int mode) {
    _module.callMethod('chmod', [path, mode]);
  }

  /// Identical to [chmod]. However, if [path] is a symbolic link then the
  /// mode will be set on the link itself, not the file that it links to.
  void lchmod(String path, int mode) {
    _module.callMethod('lchmod', [path, mode]);
  }

  /// Identical to [chmod]. However, a raw file descriptor is supplied as [fd].
  void fchmod(int fd, int mode) {
    _module.callMethod('fchmod', [fd, mode]);
  }

  /// Change the ownership of the specified file to the given user or group id.
  void chown(String path, int uid, int gid) {
    _module.callMethod('chown', [path, uid, gid]);
  }

  /// Identical to [chown]. However, if [path] is a symbolic link then the
  /// properties will be set on the link itself, not the file that it links to.
  void lchown(String path, int uid, int gid) {
    _module.callMethod('lchown', [path, uid, gid]);
  }

  /// Identical to [chown]. However, a raw file descriptor is supplied as [fd].
  void fchown(int fd, int uid, int gid) {
    _module.callMethod('fchown', [fd, uid, gid]);
  }

  /// Truncates a file to the specified [length].
  void truncate(String path, int length) {
    _module.callMethod('truncate', [path, length]);
  }

  /// Truncates the file identified by the [fd] to the specified [length].
  void ftruncate(int fd, int length) {
    _module.callMethod('ftruncate', [fd, length]);
  }

  /// Change the timestamps of the file located at [path]. The times passed
  /// to the arguments are in *milliseconds* since January 1, 1970 (midnight
  /// UTC/GMT).
  void utime(String path, int atime, int mtime) {
    _module.callMethod('utime', [path, atime, mtime]);
  }

  /// Opens a file with the specified flags. [flags] can be:
  ///
  /// - `r` — Open file for reading.
  /// - `r+` — Open file for reading and writing.
  /// - `w` — Open file for writing.
  /// - `wx` — Like `w` but fails if path exists.
  /// - `w+` — Open file for reading and writing. The file is created if it
  ///   does not exist or truncated if it exists.
  /// - `wx+` — Like `w+` but fails if path exists.
  /// - `a` — Open file for appending. The file is created if it does not
  ///   exist.
  /// - `ax` — Like `a` but fails if path exists.
  /// - `a+` — Open file for reading and appending. The file is created if it
  ///   does not exist.
  /// - `ax+` — Like `a+` but fails if path exists.
  open(String path, String flags, [int mode = 438]) {
    _module.callMethod('open', [path, flags, mode]);
  }

  /// Closes the file stream.
  void close(stream) => _module.callMethod('close', [stream]);

  /// Repositions the offset of the stream [offset] bytes relative to the
  /// beginning, current position, or end of the file, depending on the
  /// [whence] parameter.
  int llseek(stream, int offset, int whence) {
    return _module.callMethod('llseek', [stream, offset, whence]);
  }

  /// Read [length] bytes from the stream, storing them into [buffer] starting
  /// at [offset].
  int read(stream, TypedData buffer, int offset, int length, [int position]) {
    if (position != null) {
      return _module.callMethod(
          'read', [stream, buffer, offset, length, position]);
    } else {
      return _module.callMethod('read', [stream, buffer, offset, length]);
    }
  }

  /// Writes [length] bytes from [buffer], starting at [offset].
  int write(stream, TypedData buffer, int offset, int length, [int position]) {
    if (position != null) {
      return _module.callMethod(
          'write', [stream, buffer, offset, length, position]);
    } else {
      return _module.callMethod('write', [stream, buffer, offset, length]);
    }
  }

  /// Reads the entire file at [path] and returns it as a [String] (encoding
  /// is `utf8`), or as a new [Uint8List] buffer (encoding is `binary`).
  readFile(String path,
      [Map<String, String> opts = const {'encoding': 'utf8'}]) {
    var args = [path];
    if (opts != null) {
      args.add(new js.JsObject.jsify(opts));
    }
    return _module.callMethod('readFile', args);
  }

  /// Writes the entire contents of [data] to the file at [path].
  void writeFile(String path, String data, [Map<String, String> opts]) {
    var args = [path, data];
    if (opts == null) {
      opts = {'encoding': 'utf8'};
    } else if (!opts.containsKey('encoding')) {
      opts['encoding'] = 'utf8';
    }
    args.add(new js.JsObject.jsify(opts));
    _module.callMethod('writeFile', args);
  }

  void writeBinaryFile(String path, TypedData data,
      [Map<String, String> opts = const {'encoding': 'binary'}]) {
    var args = [path, data];
    if (opts == null) {
      opts = {'encoding': 'binary'};
    } else if (!opts.containsKey('encoding')) {
      opts['encoding'] = 'binary';
    }
    args.add(new js.JsObject.jsify(opts));
    _module.callMethod('writeFile', args);
  }

  /// Creates a file that will be loaded lazily on first access from a given
  /// URL or local file system path, and returns a reference to it.
  createLazyFile(parent, String name, String url, bool canRead, bool canWrite) {
    return _module.callMethod(
        'createLazyFile', [parent, name, url, canRead, canWrite]);
  }

  /// Preloads a file asynchronously.
  void createPreloadedFile(
      parent, String name, String url, bool canRead, bool canWrite) {
    _module.callMethod(
        'createPreloadedFile', [parent, name, url, canRead, canWrite]);
  }

  // File types

  /// Tests if the [mode] bitmask represents a file.
  bool isFile(int mode) => _module.callMethod('isFile', [mode]);

  /// Tests if the [mode] bitmask represents a directory.
  bool isDir(int mode) => _module.callMethod('isDir', [mode]);

  /// Tests if the [mode] bitmask represents a symlink.
  bool isLink(int mode) => _module.callMethod('isLink', [mode]);

  /// Tests if the [mode] bitmask represents a character device.
  bool isChrdev(int mode) => _module.callMethod('isChrdev', [mode]);

  /// Tests if the [mode] bitmask represents a block device.
  bool isBlkdev(int mode) => _module.callMethod('isBlkdev', [mode]);

  /// Tests if the [mode] bitmask represents a socket.
  bool isSocket(int mode) => _module.callMethod('isSocket', [mode]);

  // Paths

  /// Gets the current working directory.
  cwd() => _module.callMethod('cwd');

  /// Looks up the incoming path and returns an object containing both the
  /// resolved path and node.
  Map<String, dynamic> lookupPath(String path, Map<String, bool> opts) {
    var _opts = new js.JsObject.jsify(opts);
    return _module.callMethod('lookupPath', [path, _opts]);
  }

  /// Gets the absolute path to [node], accounting for mounts.
  String getPath(node) => _module.callMethod('getPath', [node]);
}
