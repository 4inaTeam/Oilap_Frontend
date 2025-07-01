import 'dart:io';
import 'dart:html' as html show AnchorElement, Blob, Url, document;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PlatformDownloadHelper {
  /// Downloads a file with cross-platform compatibility
  /// Returns the file path on native platforms or a success message on web
  static Future<String> downloadFile({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (kIsWeb) {
      return _downloadWebFile(bytes, fileName, mimeType);
    } else {
      return _downloadNativeFile(bytes, fileName);
    }
  }

  /// Web-specific download implementation
  static String _downloadWebFile(
    List<int> bytes,
    String fileName,
    String mimeType,
  ) {
    try {
      // Create a blob and download link for web
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create a temporary anchor element and trigger download
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      // Clean up the object URL
      html.Url.revokeObjectUrl(url);

      return 'Downloaded: $fileName';
    } catch (e) {
      throw Exception('Web download failed: $e');
    }
  }

  /// Native (Mobile/Desktop) download implementation
  static Future<String> _downloadNativeFile(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // Request storage permission for Android
        await _requestStoragePermission();

        // Try to use Downloads directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // For iOS, use app documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For desktop platforms (Windows, macOS, Linux)
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create the full file path
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write the bytes to file
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Native download failed: $e');
    }
  }

  /// Request storage permissions for Android
  static Future<void> _requestStoragePermission() async {
    if (!Platform.isAndroid) return;

    final permission = await Permission.storage.request();
    if (!permission.isGranted) {
      // Try with manage external storage permission for Android 11+
      final managePermission = await Permission.manageExternalStorage.request();
      if (!managePermission.isGranted) {
        throw Exception('Storage permission denied');
      }
    }
  }

  /// Check if platform supports file opening
  static bool get canOpenFiles => !kIsWeb;

  /// Get platform-specific download message
  static String getDownloadMessage(String fileName) {
    if (kIsWeb) {
      return 'PDF téléchargé avec succès!';
    } else {
      return 'PDF sauvegardé: $fileName';
    }
  }

  /// Get platform name for debugging
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
