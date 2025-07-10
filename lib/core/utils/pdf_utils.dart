import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Platform-specific imports using conditional imports
import 'pdf_utils_stub.dart'
    if (dart.library.html) 'pdf_utils_web.dart'
    if (dart.library.io) 'pdf_utils_mobile.dart' as platform;

/// Universal PDF utilities that work across all platforms
class PdfUtils {
  /// Downloads a PDF file from bytes with platform-specific implementation
  static Future<String> downloadPdfFromBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      return await platform.downloadPdfFromBytes(
        bytes: bytes,
        fileName: fileName,
      );
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  /// Downloads a PDF file from URL with platform-specific implementation
  static Future<String> downloadPdfFromUrl({
    required String url,
    required String fileName,
    Map<String, String>? headers,
  }) async {
    try {
      return await platform.downloadPdfFromUrl(
        url: url,
        fileName: fileName,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Failed to download PDF from URL: $e');
    }
  }

  /// Opens a URL in a new tab/external browser
  static Future<void> openUrl(String url) async {
    try {
      await platform.openUrl(url);
    } catch (e) {
      throw Exception('Failed to open URL: $e');
    }
  }

  /// Gets the platform name for debugging
  static String get platformName => platform.platformName;

  /// Checks if the current platform supports file downloads
  static bool get supportsDownload => platform.supportsDownload;

  /// Gets a user-friendly download success message
  static String getDownloadSuccessMessage(String fileName) {
    return platform.getDownloadSuccessMessage(fileName);
  }
}