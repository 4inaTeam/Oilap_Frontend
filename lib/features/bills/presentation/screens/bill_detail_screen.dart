import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:oilab_frontend/core/models/bill_model.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../../../bills/data/bill_repository.dart';
import '../../../auth/data/auth_repository.dart';

// Platform-specific imports
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

// Web-only imports
import 'dart:html' as html;

class BillDetailScreen extends StatefulWidget {
  final String? imageUrl;
  final Bill bill;
  final String? billTitle;
  final int? billId;

  const BillDetailScreen({
    Key? key,
    this.imageUrl,
    required this.bill,
    this.billTitle,
    this.billId,
  }) : super(key: key);

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  String? localPath;
  Uint8List? imageBytes;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  double _scale = 1.0;
  double _previousScale = 1.0;

  // Repositories for download functionality
  late BillRepository _billRepository;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
    _billRepository = context.read<BillRepository>();
    _loadImage();
  }

  String? get _getImageUrl {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return widget.imageUrl;
    }

    if (widget.bill.originalImage != null &&
        widget.bill.originalImage!.isNotEmpty) {
      if (widget.bill.originalImage!.startsWith('http')) {
        return widget.bill.originalImage;
      }
      return 'http://localhost:8000${widget.bill.originalImage}';
    }

    return null;
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final imageUrl = _getImageUrl;
      if (imageUrl == null) {
        throw Exception('No image URL available');
      }

      final imageBytes = await _billRepository.fetchBillImageBytes(imageUrl);

      if (imageBytes != null) {
        if (kIsWeb) {
          // For web, just store in memory
          setState(() {
            this.imageBytes = imageBytes;
            localPath = null;
            isLoading = false;
          });
        } else {
          // For mobile/desktop, try to save to file
          try {
            final dir = await getTemporaryDirectory();
            final file = io.File(
              '${dir.path}/bill_image_${widget.billId ?? widget.bill.id ?? 'temp'}.jpg',
            );
            await file.writeAsBytes(imageBytes);

            setState(() {
              localPath = file.path;
              this.imageBytes = null;
              isLoading = false;
            });
          } catch (pathError) {
            setState(() {
              this.imageBytes = imageBytes;
              localPath = null;
              isLoading = false;
            });
          }
        }
      } else {
        throw Exception('Failed to load image from server');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadPdf() async {
    final billId = widget.billId ?? widget.bill.id;
    if (billId == null) {
      _showErrorMessage('ID de facture non disponible');
      return;
    }

    try {
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/bills/$billId/download/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/pdf')) {
          if (kIsWeb) {
            _downloadFileWeb(response.bodyBytes, 'facture_$billId.pdf');
          } else {
            await _downloadFileMobile(response.bodyBytes, billId);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF téléchargé avec succès!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception('Le serveur n\'a pas retourné un fichier PDF valide');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Erreur: $e');
    }
  }

  void _downloadFileWeb(Uint8List bytes, String filename) {
    if (kIsWeb) {
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

  // Mobile/Desktop download using file system and share
  Future<void> _downloadFileMobile(Uint8List bytes, int billId) async {
    if (!kIsWeb) {
      try {
        final dir = await getTemporaryDirectory();
        final file = io.File('${dir.path}/facture_$billId.pdf');

        await file.writeAsBytes(bytes);

        print('PDF saved to: ${file.path}');

        // Share the PDF file using the system share dialog
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Facture PDF - ${widget.bill.owner}');
      } catch (e) {
        print('Error in mobile download: $e');
        throw Exception('Erreur lors du téléchargement mobile: $e');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: "/factures/entreprise/detail",
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Top action bar with simple download button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [_buildDownloadButton()],
              ),
            ),
            // Main content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
  Widget _buildDownloadButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16),
      child: ElevatedButton.icon(
        onPressed: isLoading || hasError ? null : _downloadPdf,
        icon: const Icon(Icons.download, color: Colors.white),
        label: Text(
          kIsWeb ? 'Télécharger ' : 'Partager PDF',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (localPath == null && imageBytes == null) {
      return _buildEmptyState();
    }

    return _buildImageViewer();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.mainColor),
          SizedBox(height: 16),
          Text(
            'Chargement de l\'image...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur lors du chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadImage,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune image disponible',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onScaleStart: (details) {
            _previousScale = _scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_previousScale * details.scale).clamp(0.5, 5.0);
            });
          },
          onDoubleTap: () {
            setState(() {
              _scale = _scale > 1.0 ? 1.0 : 2.0;
              _previousScale = _scale;
            });
          },
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(
              child: Transform.scale(scale: _scale, child: _buildImage()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (localPath != null && !kIsWeb) {
      return Image.file(
        io.File(localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    } else if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }

    return _buildImageError();
  }

  Widget _buildImageError() {
    return Container(
      height: 200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Impossible d\'afficher l\'image'),
        ],
      ),
    );
  }
}
