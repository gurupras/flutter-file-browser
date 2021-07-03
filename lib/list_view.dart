import 'package:file_browser/controllers/file_browser.dart';
import 'package:file_browser/filesystem_interface.dart';
import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ListViewLayout extends StatelessWidget {
  final FileBrowserController controller;
  final FileSystemEntry entry;
  ListViewLayout({required this.controller, required this.entry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: controller.sortedListing(entry),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data as List<FileSystemEntryStat>;
            final showParentEntry = this.entry.path != controller.fs.root;
            return ListView.separated(
              shrinkWrap: true,
              itemCount: data.length + (showParentEntry ? 1 : 0),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                FileSystemEntryStat? entry;
                bool showInfo = true;
                if (showParentEntry && index == 0) {
                  showInfo = false;
                  final parentEntry = new FileSystemEntry(
                      name: '..',
                      isDir: true,
                      path: path.dirname(this.entry.path),
                      relativePath: path.dirname(this.entry.relativePath));
                  entry = new FileSystemEntryStat(
                      entry: parentEntry, lastModified: 0, size: 0, mode: 0);
                } else {
                  final idx = index - (showParentEntry ? 1 : 0);
                  entry = data[idx];
                }
                return Obx(() => InkWell(
                    splashColor: controller.selected.length == 0
                        ? Colors.blue[100]
                        : Colors.transparent,
                    onTap: () {
                      if (controller.selected.length > 0) {
                        // controller.toggleSelect(entry!.entry);
                      } else {
                        //
                      }
                      if (showParentEntry && index == 0) {
                        controller.currentDir.value = entry!.entry;
                      } else if (entry!.entry.isDir) {
                        controller.currentDir.value = entry.entry;
                      }
                    },
                    onLongPress: () {
                      controller.toggleSelect(entry!.entry);
                    },
                    child: Container(
                        color: controller.selected.contains(entry!.entry)
                            ? Colors.blue[200]
                            : Colors.transparent,
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.only(
                            left: 20.0, top: 10.0, bottom: 10.0),
                        child: ListViewEntry(
                            fs: controller.fs,
                            entry: entry,
                            showInfo: showInfo))));
              },
              separatorBuilder: (context, index) => Divider(
                height: 1.0,
              ),
            );
          } else {
            return Container();
          }
        });
  }
}

class ListViewEntry extends StatelessWidget {
  final FilesystemInterface fs;
  final FileSystemEntryStat entry;
  final bool showInfo;

  ListViewEntry({required this.fs, required this.entry, this.showInfo = true});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              child: Thumbnail(fs: fs, entry: entry.entry)),
          Flexible(
              child: Container(
                  margin: EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          child: Text(entry.entry.name,
                              style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                  color: Colors.black))),
                      if (showInfo)
                        Flexible(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: 64.0,
                                child: Text(
                                  filesize(entry.size, 0),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      color: Colors.grey),
                                )),
                            Text(
                                DateFormat('yyyy-MM-dd').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        entry.lastModified)),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    color: Colors.grey))
                          ],
                        ))
                    ],
                  )))
        ]);
  }
}

class Thumbnail extends StatelessWidget {
  final FilesystemInterface fs;
  final FileSystemEntry entry;

  Thumbnail({required this.fs, required this.entry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fs.getThumbnail(entry, height: 36),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final thumbnail = snapshot.data as Widget;
          return thumbnail;
        } else {
          return Container();
        }
      },
    );
  }
}
