// Web‐only implementations using dart:html
import 'dart:html' as html;

/// Opens a URL in a new browser tab (Web only).
void openInNewTab(String url) {
  html.window.open(url, '_blank');
}

/// Triggers download of a PDF file (Web only).
void downloadPdfWeb(String url, String fileName) {
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
}
