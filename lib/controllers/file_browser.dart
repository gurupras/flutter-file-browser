import 'package:file_browser/filesystem_interface.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

enum Layout { LIST_VIEW, GRID_VIEW }

typedef SelectionCallback = Future<void> Function(
    FileSystemEntry entry, bool selected);

class FileBrowserController extends GetxController {
  final FileSystemInterface fs;

  List<FileSystemEntryStat> roots = List<FileSystemEntryStat>.empty();
  final rootPathsSet = Set<String>();

  final currentDir = new FileSystemEntry.blank().obs;
  final currentLayout = Layout.LIST_VIEW.obs;
  final showDirectoriesFirst = false.obs;

  SelectionCallback? onSelectionUpdate;

  final RxSet<FileSystemEntry> selected;

  FileBrowserController({required this.fs, this.onSelectionUpdate})
      : selected = RxSet<FileSystemEntry>();

  Future<List<FileSystemEntryStat>> sortedListing(FileSystemEntry entry) async {
    if (isRootEntry(entry)) {
      // Root entry
      return roots;
    }
    final contents = await fs.listContents(entry);
    contents.sort((a, b) {
      if (showDirectoriesFirst.value) {
        // We need to put dirs first
        if (a.entry.isDirectory && !b.entry.isDirectory) {
          return -1;
        } else if (!a.entry.isDirectory && b.entry.isDirectory) {
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

  void updateRoots(List<FileSystemEntryStat> roots) {
    this.roots = roots;
    rootPathsSet.clear();
    roots.forEach((entry) {
      final parent = path.dirname(entry.entry.path);
      // On Linux, parent of '/' is '/', which poses a problem since we have a fake root
      // To deal with this, we don't add '/' to rootPathsSet
      if (parent != '/') {
        rootPathsSet.add(parent);
      }
    });
  }

  bool isRootEntry(FileSystemEntry entry) {
    return entry.path == '';
  }
}
