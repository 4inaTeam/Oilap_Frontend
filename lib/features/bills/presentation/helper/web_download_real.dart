// lib/features/bills/presentation/screens/web_download_real.dart
import 'dart:html' as html;
import 'dart:typed_data';

// Real implementation for web platform
class WebDownloadHelper {
  static void downloadFile(Uint8List bytes, String filename) {
    try {
      // Create a blob with the PDF data
      final blob = html.Blob([bytes], 'application/pdf');

      // Create a download URL
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element and trigger download
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', filename)
            ..style.display = 'none';

      // Add to DOM, click, and remove
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      // Clean up the URL
      html.Url.revokeObjectUrl(url);

      print('Web download triggered for: $filename');
    } catch (e) {
      print('Error in web download: $e');
      throw Exception('Erreur lors du téléchargement web: $e');
    }
  }
}
