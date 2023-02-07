import 'dart:io';

import 'package:file_browser/controllers/file_browser.dart';
import 'package:file_browser/file_browser.dart';
import 'package:file_browser/filesystem_interface.dart';
import 'package:file_browser/local_filesystem.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

FileSystemEntryStat? rootEntry;

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
  final fs = LocalFileSystem();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkAndRequestPermission(fs),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as List<FileSystemEntryStat>?;
          if (data != null) {
            final controller = FileBrowserController(fs: fs);
            controller.updateRoots(data);
            return FileBrowser(controller: controller);
          }
        }
        return Container();
      },
    );
  }

  Future<List<FileSystemEntryStat>?> checkAndRequestPermission(
      LocalFileSystem fs) async {
    var entry = FileSystemEntry.blank();
    if (Platform.isLinux || Platform.isMacOS) {
      entry = new FileSystemEntry(
          name: '/', path: '/', relativePath: '/', isDirectory: true);
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
      final roots = await Future.wait(directories!.map((dir) {
        final name = path.basename(dir.path);
        final relativePath = name;
        final dirPath = dir.path;
        final entry = new FileSystemEntry(
            name: name,
            path: dirPath,
            relativePath: relativePath,
            isDirectory: true);
        return fs.stat(entry);
      }));
      return roots;
    }
    rootEntry = await fs.stat(entry);
    return List.from([rootEntry]);
  }

  Future<bool> checkAndRequestManageStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }
}
