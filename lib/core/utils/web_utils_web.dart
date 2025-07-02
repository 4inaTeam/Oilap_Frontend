// File: lib/core/utils/web_utils_web.dart
// Web-only implementations using dart:html

import 'dart:html' as html;
import 'dart:typed_data';

/// Downloads a PDF file (Web only).
void downloadPdfWeb(Uint8List bytes, String fileName) {
  try {
    // Create blob from bytes
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create and trigger download
    final anchor =
        html.AnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';

    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();

    // Clean up the object URL
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error downloading PDF: $e');
  }
}

/// Opens a URL in a new browser tab (Web only).
void openInNewTab(String url) {
  html.window.open(url, '_blank');
}
