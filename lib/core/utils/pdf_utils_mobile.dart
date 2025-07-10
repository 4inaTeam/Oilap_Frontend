import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

/// Mobile/Desktop-specific PDF utilities implementation
String get platformName {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

const bool supportsDownload = true;

/// Downloads a PDF file from bytes (Mobile/Desktop implementation)
Future<String> downloadPdfFromBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  try {
    // Request permissions if needed
    await _requestStoragePermissions();

    // Get appropriate directory
    final directory = await _getDownloadDirectory();

    // Create the full file path
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Write the bytes to file
    await file.writeAsBytes(bytes);

    // For mobile platforms, also share the file
    if (Platform.isAndroid || Platform.isIOS) {
      await Share.shareXFiles([XFile(filePath)], text: 'PDF: $fileName');
      return 'PDF sauvegardé et partagé: $fileName';
    }

    return 'PDF sauvegardé: $filePath';
  } catch (e) {
    throw Exception('Mobile download failed: $e');
  }
}

/// Downloads a PDF file from URL (Mobile/Desktop implementation)
Future<String> downloadPdfFromUrl({
  required String url,
  required String fileName,
  Map<String, String>? headers,
}) async {
  try {
    // First try to fetch the PDF data
    final response = await http
        .get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/pdf',
            'Cache-Control': 'max-age=300',
            'Accept-Encoding': 'gzip, deflate',
            ...?headers,
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      // Verify content type
      final contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/pdf')) {
        throw Exception('Response is not a PDF. Content-Type: $contentType');
      }

      // Download using bytes
      return await downloadPdfFromBytes(
        bytes: response.bodyBytes,
        fileName: fileName,
      );
    } else {
      throw Exception('Failed to fetch PDF: ${response.statusCode}');
    }
  } catch (e) {
    // Fallback: try to open URL externally
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return 'PDF ouvert dans l\'application externe';
      } else {
        throw Exception('Cannot launch URL: $url');
      }
    } catch (fallbackError) {
      throw Exception('All download methods failed: $e, $fallbackError');
    }
  }
}

/// Opens a URL in external browser (Mobile/Desktop implementation)
Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Cannot launch URL: $url');
  }
}

/// Gets a user-friendly download success message
String getDownloadSuccessMessage(String fileName) {
  if (Platform.isAndroid || Platform.isIOS) {
    return 'PDF sauvegardé et partagé: $fileName';
  }
  return 'PDF sauvegardé: $fileName';
}

/// Requests storage permissions for Android
Future<void> _requestStoragePermissions() async {
  if (!Platform.isAndroid) return;

  // For Android 13+ (API 33+), we don't need storage permissions for downloads
  // But for older versions, we still need them
  try {
    if (Platform.isAndroid) {
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        // Try with manage external storage permission for Android 11+
        final managePermission =
            await Permission.manageExternalStorage.request();
        if (!managePermission.isGranted) {
          // For newer Android versions, we can still save to app-specific directories
          print('Storage permission denied, using app-specific directory');
        }
      }
    }
  } catch (e) {
    // Permissions might fail, but we can still save to app directories
    print('Permission request failed: $e');
  }
}

/// Gets the appropriate download directory for each platform
Future<Directory> _getDownloadDirectory() async {
  if (Platform.isAndroid) {
    // Try to use Downloads directory first
    try {
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      }
    } catch (e) {
      // Fallback to external storage directory
    }

    // Fallback to external storage directory
    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      final downloadDir = Directory('${externalDir.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }

    // Final fallback to app documents directory
    return await getApplicationDocumentsDirectory();
  } else if (Platform.isIOS) {
    // For iOS, use app documents directory
    return await getApplicationDocumentsDirectory();
  } else {
    // For desktop platforms (Windows, macOS, Linux)
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return downloadsDir;
    }

    // Fallback to documents directory
    return await getApplicationDocumentsDirectory();
  }
}
