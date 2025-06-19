// Stub implementations for non-web platforms

/// Opens a URL in a new browser tab (Stub for non-web platforms).
void openInNewTab(String url) {
  // This is a stub implementation for non-web platforms
  print('openInNewTab called with: $url (not supported on this platform)');
}

/// Triggers download of a PDF file (Stub for non-web platforms).
void downloadPdfWeb(String url, String fileName) {
  // This is a stub implementation for non-web platforms
  print('downloadPdfWeb called with: $url, fileName: $fileName (not supported on this platform)');
}

/// Alternative download method (Stub for non-web platforms).
Future<void> downloadPdfWithFetch(String url, String fileName) async {
  // This is a stub implementation for non-web platforms
  print('downloadPdfWithFetch called with: $url, fileName: $fileName (not supported on this platform)');
}