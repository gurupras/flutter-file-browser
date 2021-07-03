import 'dart:io';

import 'package:file_browser/file_browser.dart';
import 'package:file_browser/filesystem_interface.dart';
import 'package:file_browser/local_filesystem.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

FileSystemEntry? rootEntry;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FileBrowser Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(title: Text('File Browser')),
            backgroundColor: Colors.white,
            body: Demo()));
  }
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkAndRequestPermission(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as FileSystemEntry?;
          if (data != null) {
            return FileBrowser(root: rootEntry!);
          }
        }
        return Container();
      },
    );
  }

  Future<FileSystemEntry?> checkAndRequestPermission() async {
    if (Platform.isLinux || Platform.isMacOS) {
      rootEntry = new FileSystemEntry(
          name: '/', path: '/', relativePath: '/', isDir: true);
    } else if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        // We didn't ask for permission yet or the permission has been denied before but not permanently.
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        return null;
      }
      await checkAndRequestManageStoragePermission();
      final directories = await getExternalStorageDirectories();
      final rootPath = directories![0].path;
      final name = path.basename(rootPath);
      rootEntry = new FileSystemEntry(
          name: name, path: rootPath, relativePath: name, isDir: true);
    }
    return rootEntry;
  }

  Future<bool> checkAndRequestManageStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }
}
