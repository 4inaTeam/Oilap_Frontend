import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Web-specific PDF utilities implementation
const String platformName = 'Web';
const bool supportsDownload = true;

/// Downloads a PDF file from bytes (Web implementation)
Future<String> downloadPdfFromBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  try {
    // Create a blob with the PDF data
    final blob = html.Blob([bytes], 'application/pdf');

    // Create a download URL
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element and trigger download
    final anchor =
        html.AnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';

    // Add to DOM, click, and remove
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    // Clean up the URL
    html.Url.revokeObjectUrl(url);

    return 'PDF downloaded successfully: $fileName';
  } catch (e) {
    throw Exception('Web download failed: $e');
  }
}

/// Downloads a PDF file from URL (Web implementation)
Future<String> downloadPdfFromUrl({
  required String url,
  required String fileName,
  Map<String, String>? headers,
}) async {
  try {
    // First try to fetch the PDF data
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/pdf',
        'Cache-Control': 'max-age=300',
        'Accept-Encoding': 'gzip, deflate',
        ...?headers,
      },
    );

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
    // Fallback: try direct download link
    try {
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..setAttribute('target', '_blank')
        ..click();

      return 'PDF download initiated: $fileName';
    } catch (fallbackError) {
      throw Exception('All download methods failed: $e, $fallbackError');
    }
  }
}

/// Opens a URL in a new browser tab (Web implementation)
Future<void> openUrl(String url) async {
  html.window.open(url, '_blank');
}

/// Gets a user-friendly download success message
String getDownloadSuccessMessage(String fileName) {
  return 'PDF téléchargé avec succès: $fileName';
}
