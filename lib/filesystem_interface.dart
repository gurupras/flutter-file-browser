import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';

class FileSystemEntry {
  final String name;
  final String path;
  final String relativePath;
  final bool isDir;

  FileSystemEntry(
      {required this.name,
      required this.path,
      required this.relativePath,
      required this.isDir});

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['name'] = this.name;
    map['relativePath'] = this.relativePath;
    map['path'] = this.path;
    map['isDir'] = this.isDir;
    return map;
  }

  factory FileSystemEntry.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    String relativePath = json['relativePath'];
    String path = json['path'];
    bool isDir = json['isDir'];
    return new FileSystemEntry(
        name: name, path: path, relativePath: relativePath, isDir: isDir);
  }

  factory FileSystemEntry.blank() {
    return FileSystemEntry(isDir: false, name: '', path: '', relativePath: '');
  }
}

class FileSystemEntryStat {
  final FileSystemEntry entry;
  int lastModified;
  int size;
  int mode;
  FileSystemEntryStat(
      {required this.entry,
      required this.lastModified,
      required this.size,
      required this.mode});

  factory FileSystemEntryStat.fromJson(dynamic json) {
    final entry = FileSystemEntry.fromJson(json['entry']);
    int lastModified = json['lastModified'];
    int mode = json['mode'];
    int size = json['size'];

    return FileSystemEntryStat(
        entry: entry, lastModified: lastModified, mode: mode, size: size);
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['entry'] = entry.toJson();
    map['lastModified'] = lastModified;
    map['mode'] = mode;
    map['size'] = size;
    return map;
  }
}

class FileEntry extends FileSystemEntry {
  FileEntry(
      {required String name,
      required String path,
      required String relativePath})
      : super(name: name, path: path, relativePath: relativePath, isDir: false);
}

class FolderEntry extends FileSystemEntry {
  FolderEntry(
      {required String name,
      required String path,
      required String relativePath})
      : super(
          name: name,
          path: path,
          relativePath: relativePath,
          isDir: true,
        );
}

abstract class FilesystemInterface {
  final String root;
  FilesystemInterface({required this.root});

  Future<List<FileSystemEntryStat>> listContents(FileSystemEntry entry);
  Future<Widget> getThumbnail(FileSystemEntry entry,
      {double width, double height});

  Future<Stream<List<int>>> read(FileSystemEntry entry, {int bufferSize = 512});
  Future<List<int>> readImage(FileSystemEntry entry,
      {double? width, double? height});
}
