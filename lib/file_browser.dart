library file_browser;

import 'package:file_browser/controllers/file_browser.dart';
import 'package:file_browser/filesystem_interface.dart';
import 'package:file_browser/list_view.dart';
import 'package:file_browser/local_filesystem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileBrowser extends StatelessWidget {
  late final FileBrowserController controller;
  FileBrowser(
      {List<FileSystemEntryStat>? roots, FileBrowserController? controller}) {
    if (controller != null) {
      this.controller = controller;
    } else {
      if (roots == null) {
        throw 'Must specify roots or controller';
      }
      this.controller = FileBrowserController(fs: LocalFileSystem());
      this.controller.updateRoots(roots);
      this.controller.showDirectoriesFirst.value = true;
    }
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
