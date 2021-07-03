import 'package:file_browser/filesystem_interface.dart';
import 'package:get/get.dart';

enum Layout { LIST_VIEW, GRID_VIEW }

typedef SelectionCallback = Future<void> Function(
    FileSystemEntry entry, bool selected);

class FileBrowserController extends GetxController {
  final FilesystemInterface fs;
  final currentDir = new FileSystemEntry.blank().obs;
  final currentLayout = Layout.LIST_VIEW.obs;
  final showDirectoriesFirst = false.obs;

  SelectionCallback? onSelectionUpdate;

  final RxSet<FileSystemEntry> selected;

  FileBrowserController({required this.fs, this.onSelectionUpdate})
      : selected = RxSet<FileSystemEntry>();

  Future<List<FileSystemEntryStat>> sortedListing(FileSystemEntry entry) async {
    final contents = await fs.listContents(entry);
    contents.sort((a, b) {
      if (showDirectoriesFirst.value) {
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

  void toggleSelect(FileSystemEntry entry) async {
    final contains = selected.contains(entry);
    if (contains) {
      selected.remove(entry);
    } else {
      selected.add(entry);
    }
    if (onSelectionUpdate != null) {
      await onSelectionUpdate!(entry, !contains);
    }
  }
}
