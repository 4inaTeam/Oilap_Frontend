import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Downloads a PDF file to mobile device storage
Future<void> downloadPdfMobile(Uint8List bytes, String fileName) async {
  try {
    // Request storage permission for Android
    if (Platform.isAndroid) {
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        // Try with manage external storage for Android 11+
        final managePermission =
            await Permission.manageExternalStorage.request();
        if (!managePermission.isGranted) {
          throw Exception('Storage permission denied');
        }
      }
    }

    // Get the downloads directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('Could not access external storage');
    }

    // Create downloads path
    final downloadsPath = '${directory.path}/Download';
    final downloadsDir = Directory(downloadsPath);

    // Create directory if it doesn't exist
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // Write the file
    final file = File('$downloadsPath/$fileName');
    await file.writeAsBytes(bytes);
  } catch (e) {
    throw Exception('Mobile download failed: $e');
  }
}
