// lib/core/utils/pdf_utils_stub.dart
import 'dart:typed_data';

/// Stub implementation for unsupported platforms
const String platformName = 'Unsupported';
const bool supportsDownload = false;

/// Stub implementation for downloading PDF from bytes
Future<String> downloadPdfFromBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  throw UnsupportedError(
    'PDF download from bytes is not supported on this platform',
  );
}

/// Stub implementation for downloading PDF from URL
Future<String> downloadPdfFromUrl({
  required String url,
  required String fileName,
  Map<String, String>? headers,
}) async {
  throw UnsupportedError(
    'PDF download from URL is not supported on this platform',
  );
}

/// Stub implementation for opening URL
Future<void> openUrl(String url) async {
  throw UnsupportedError('Opening URLs is not supported on this platform');
}

/// Gets a user-friendly download success message
String getDownloadSuccessMessage(String fileName) {
  return 'Download not supported on this platform: $fileName';
}
