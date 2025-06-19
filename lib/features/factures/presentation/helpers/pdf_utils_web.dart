// Web-only implementations using dart:html
import 'dart:html' as html;

/// Opens a URL in a new browser tab (Web only).
void openInNewTab(String url) {
  html.window.open(url, '_blank');
}

/// Triggers download of a PDF file (Web only).
void downloadPdfWeb(String url, String fileName) {
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..setAttribute('target', '_blank')
    ..click();
}

/// Alternative download method using fetch for better CORS handling
Future<void> downloadPdfWithFetch(String url, String fileName) async {
  try {
    final response = await html.window.fetch(url);
    if (response.ok) {
      final blob = await response.blob();
      final objectUrl = html.Url.createObjectUrlFromBlob(blob);
      
      html.AnchorElement(href: objectUrl)
        ..setAttribute('download', fileName)
        ..click();
      
      // Clean up the object URL
      html.Url.revokeObjectUrl(objectUrl);
    }
  } catch (e) {
    // Fallback to simple download
    downloadPdfWeb(url, fileName);
  }
}