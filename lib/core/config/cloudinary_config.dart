class CloudinaryConfig {
  static const String cloudName = 'dzj4er35i';
  static const String apiKey = '119567968374165';
  static const String apiSecret = 'D2koZhcHpFPGNcfcSTrJcRdj_gQ';

  static const String baseUrl = 'https://res.cloudinary.com/$cloudName';
  static const String secureBaseUrl = 'https://res.cloudinary.com/$cloudName';

  static String buildPdfUrl(String publicId) {
    String cleanPublicId =
        publicId.endsWith('.pdf')
            ? publicId.substring(0, publicId.length - 4)
            : publicId;

    return '$secureBaseUrl/image/upload/$cleanPublicId.pdf';
  }

  static String buildRawPdfUrl(String publicId) {
    String cleanPublicId =
        publicId.endsWith('.pdf')
            ? publicId.substring(0, publicId.length - 4)
            : publicId;

    return '$secureBaseUrl/raw/upload/$cleanPublicId.pdf';
  }

  static String buildVersionedPdfUrl(String publicId, {String? version}) {
    String cleanPublicId =
        publicId.endsWith('.pdf')
            ? publicId.substring(0, publicId.length - 4)
            : publicId;

    if (version != null) {
      return '$secureBaseUrl/image/upload/v$version/$cleanPublicId.pdf';
    }
    return buildPdfUrl(cleanPublicId);
  }

  static List<String> generatePossiblePdfUrls(String publicId) {
    String cleanPublicId =
        publicId.endsWith('.pdf')
            ? publicId.substring(0, publicId.length - 4)
            : publicId;

    return [
      '$secureBaseUrl/image/upload/$cleanPublicId.pdf',
      '$secureBaseUrl/raw/upload/$cleanPublicId.pdf',
      '$secureBaseUrl/image/upload/v1/$cleanPublicId.pdf',
      '$secureBaseUrl/raw/upload/v1/$cleanPublicId.pdf',
      '$secureBaseUrl/auto/upload/$cleanPublicId.pdf',
      publicId.startsWith('http')
          ? publicId
          : '$secureBaseUrl/$cleanPublicId.pdf',
    ];
  }

  static bool isCloudinaryUrl(String url) {
    return url.contains('res.cloudinary.com') || url.contains('cloudinary.com');
  }

  static String? extractPublicId(String cloudinaryUrl) {
    if (!isCloudinaryUrl(cloudinaryUrl)) return null;

    try {
      final uri = Uri.parse(cloudinaryUrl);
      final pathSegments = uri.pathSegments;

      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        final publicIdParts = pathSegments.sublist(uploadIndex + 1);
        String publicId = publicIdParts.join('/');

        if (publicId.contains('.')) {
          publicId = publicId.substring(0, publicId.lastIndexOf('.'));
        }

        return publicId;
      }
    } catch (e) {
      print('Error extracting public ID: $e');
    }

    return null;
  }
}

class CloudinaryEnvironment {
  static bool get isDevelopment =>
      const bool.fromEnvironment('dart.vm.product') == false;

  static String get cloudName {
    if (isDevelopment) {
      return 'dzj4er35i';
    }
    return 'your_prod_cloud_name';
  }

  static String get apiKey {
    if (isDevelopment) {
      return 'dzj4er35i';
    }
    return 'your_prod_api_key';
  }
}
