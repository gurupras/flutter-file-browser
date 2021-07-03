import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chunked_stream/chunked_stream.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path/path.dart' as path;
import 'package:file_browser/filesystem_interface.dart';

class LocalFileSystem extends FilesystemInterface {
  LocalFileSystem({required String root}) : super(root: root);

  @override
  Future<Widget> getThumbnail(FileSystemEntry entry,
      {double width = 64.0, double height = 64.0}) async {
    if (entry.isDir) {
      return Icon(Icons.folder_outlined, size: height, color: Colors.grey);
    } else {
      final ext = path.extension(entry.name).toLowerCase();
      if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
        final bytes = await readImage(entry, width: width, height: height);
        return Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain);
      }
    }
    return Icon(Icons.description, size: height, color: Colors.grey);
  }

  @override
  Future<List<FileSystemEntryStat>> listContents(FileSystemEntry entry) {
    var files = <FileSystemEntryStat>[];
    var completer = Completer<List<FileSystemEntryStat>>();
    final dir = Directory(entry.path);
    var lister = dir.list(recursive: false);
    lister.listen((file) async {
      final name = path.basename(file.path);
      final relativePath = path.join(entry.relativePath, name);
      if (File(file.path).existsSync()) {
        final child = new FileEntry(
            name: name, path: file.path, relativePath: relativePath);
        final stat = File(file.path).statSync();
        files.add(new FileSystemEntryStat(
            entry: child,
            lastModified: stat.modified.millisecondsSinceEpoch,
            size: stat.size,
            mode: stat.mode));
      } else if (Directory(file.path).existsSync()) {
        final child = new FolderEntry(
            name: name, path: file.path, relativePath: relativePath);
        final stat = Directory(file.path).statSync();
        files.add(new FileSystemEntryStat(
            entry: child,
            lastModified: stat.modified.millisecondsSinceEpoch,
            size: stat.size,
            mode: stat.mode));
      }
    },
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }

  @override
  Future<Stream<List<int>>> read(FileSystemEntry entry,
      {int bufferSize = 512}) async {
    final stream = bufferChunkedStream(new File(entry.path).openRead(),
        bufferSize: bufferSize);
    return stream;
  }

  @override
  Future<List<int>> readImage(FileSystemEntry entry,
      {double? width, double? height}) async {
    final image = imageLib.decodeImage(new File(entry.path).readAsBytesSync());
    if (image != null) {
      // Resize the image to a thumbnail (maintaining the aspect ratio).
      int? rw, rh;
      if (width != null) {
        rw = width.round();
      }
      if (height != null) {
        rh = height.round();
      }
      final thumbnail = imageLib.copyResize(image, width: rw, height: rh);
      final bytes = imageLib.encodePng(thumbnail);
      return bytes;
    } else {
      throw 'Error decoding image';
    }
  }
}
