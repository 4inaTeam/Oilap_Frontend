import 'dart:typed_data';

// Stub implementation for non-web platforms
class WebDownloadHelper {
  static void downloadFile(Uint8List bytes, String filename) {
    throw UnsupportedError('Web download not supported on this platform');
  }
}
