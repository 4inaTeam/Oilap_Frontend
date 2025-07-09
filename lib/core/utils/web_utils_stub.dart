import 'dart:typed_data';

/// Downloads a PDF file (Stub for non-web platforms).
void downloadPdfWeb(Uint8List bytes, String fileName) {
  // This is a stub implementation for non-web platforms
  print(
    'downloadPdfWeb called with fileName: $fileName (not supported on this platform)',
  );
}

/// Downloads a PDF file to mobile device storage (Stub for web platforms).
Future<void> downloadPdfMobile(Uint8List bytes, String fileName) async {
  // This is a stub implementation for web platforms
  print(
    'downloadPdfMobile called with fileName: $fileName (not supported on this platform)',
  );
}

/// Opens a URL in a new browser tab (Stub for non-web platforms).
void openInNewTab(String url) {
  // This is a stub implementation for non-web platforms
  print('openInNewTab called with: $url (not supported on this platform)');
}
