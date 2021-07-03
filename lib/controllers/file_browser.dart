import 'package:file_browser/filesystem_interface.dart';
import 'package:get/get.dart';

enum Layout { LIST_VIEW, GRID_VIEW }

class FileBrowserController extends GetxController {
  final FilesystemInterface fs;
  final currentDir = new FileSystemEntry.blank().obs;
  final currentLayout = Layout.LIST_VIEW.obs;
  final dirFirst = false.obs;

  final RxSet<FileSystemEntry> selected;

  FileBrowserController({required this.fs})
      : selected = RxSet<FileSystemEntry>();

  Future<List<FileSystemEntryStat>> sortedListing(FileSystemEntry entry) async {
    final contents = await fs.listContents(entry);
    contents.sort((a, b) {
      if (dirFirst.value) {
        // We need to put dirs first
        if (a.entry.isDir && !b.entry.isDir) {
          return -1;
        } else if (!a.entry.isDir && b.entry.isDir) {
          return 1;
        }
      }
      return a.entry.name.compareTo(b.entry.name);
    });
    return contents;
  }

  void toggleSelect(FileSystemEntry entry) {
    if (selected.contains(entry)) {
      selected.remove(entry);
    } else {
      selected.add(entry);
    }
  }
}
