library file_browser;

import 'package:file_browser/controllers/file_browser.dart';
import 'package:file_browser/filesystem_interface.dart';
import 'package:file_browser/list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileBrowser extends StatelessWidget {
  late final FileBrowserController controller;
  late final FileSystemEntry root;
  FileBrowser(FilesystemInterface fs, FileSystemEntry entry,
      {bool dirFirst = true}) {
    this.root = entry;
    controller = FileBrowserController(fs: fs);
    controller.currentDir.value = entry;
    controller.dirFirst.value = dirFirst;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentLayout.value == Layout.LIST_VIEW) {
        return ListViewLayout(
            controller: controller, entry: controller.currentDir.value);
      } else {
        return Container();
      }
    });
  }
}
