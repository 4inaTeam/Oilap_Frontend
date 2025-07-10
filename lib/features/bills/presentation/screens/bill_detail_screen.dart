import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/core/models/bill_model.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../../../bills/data/bill_repository.dart';
import '../../../auth/data/auth_repository.dart';
import 'package:oilab_frontend/core/utils/pdf_utils.dart';

// Import the dialog widgets
import 'package:oilab_frontend/shared/dialogs/success_dialog.dart';
import 'package:oilab_frontend/shared/dialogs/error_dialog.dart';

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

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
  bool isDownloading = false;
  double _scale = 1.0;
  double _previousScale = 1.0;

  // Repositories
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

      // Use the improved repository method
      final imageBytes = await _billRepository.fetchBillImageBytes(imageUrl);

      if (imageBytes != null) {
        if (kIsWeb) {
          setState(() {
            this.imageBytes = imageBytes;
            localPath = null;
            isLoading = false;
          });
        } else {
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

      // Show specific error message for auth issues
      if (e.toString().contains('Authentication')) {
        showCustomErrorDialog(
          context,
          message: 'Session expirée. Veuillez vous reconnecter.',
          showRetry: false,
        );
        // Optionally navigate to login
        // Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  // UPDATED: Simplified download method using both repository and PdfUtils
  Future<void> _downloadPdf() async {
    final billId = widget.billId ?? widget.bill.id;
    if (billId == null) {
      showCustomErrorDialog(
        context,
        message: 'ID de facture non disponible',
        showRetry: false,
      );
      return;
    }

    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      // Method 1: Try using the repository's PDF fetching (recommended)
      final pdfUrl = _billRepository.getBillPdfUrl(widget.bill);
      if (pdfUrl != null) {
        // Get PDF bytes using repository
        final pdfBytes = await _billRepository.fetchBillPdfBytes(pdfUrl);
        if (pdfBytes != null) {
          // Use PdfUtils to download/save
          final fileName = 'facture_$billId.pdf';
          final result = await PdfUtils.downloadPdfFromBytes(
            bytes: pdfBytes,
            fileName: fileName,
          );

          if (mounted) {
            showSuccessDialog(
              context,
              title: 'Téléchargement réussi',
              message: result,
            );
          }
          return;
        }
      }

      // Method 2: Fallback to direct URL download if repository method fails
      final token = await _authRepository.getAccessToken();
      if (token == null) {
        throw Exception('Non authentifié. Veuillez vous reconnecter.');
      }

      final fileName = 'facture_$billId.pdf';
      final url = 'http://localhost:8000/api/bills/$billId/download/';

      final result = await PdfUtils.downloadPdfFromUrl(
        url: url,
        fileName: fileName,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) {
        showSuccessDialog(
          context,
          title: 'Téléchargement réussi',
          message: result,
        );
      }
    } catch (e) {
      print('Download error: $e'); // Debug log

      // Handle specific error types with custom dialogs
      if (e.toString().contains('Authentication') ||
          e.toString().contains('401') ||
          e.toString().contains('403')) {
        showCustomErrorDialog(
          context,
          message: 'Session expirée. Veuillez vous reconnecter.',
          showRetry: false,
        );
        // Optionally redirect to login
        // Navigator.pushReplacementNamed(context, '/login');
      } else if (e.toString().contains('404')) {
        showCustomErrorDialog(
          context,
          message: 'PDF non trouvé pour cette facture.',
          showRetry: false,
        );
      } else if (e.toString().contains('500')) {
        showCustomErrorDialog(
          context,
          message: 'Erreur serveur. Veuillez réessayer plus tard.',
          showRetry: true,
          onRetry: () {
            Navigator.of(context).pop();
            _downloadPdf();
          },
        );
      } else {
        showCustomErrorDialog(
          context,
          message: 'Erreur: ${e.toString()}',
          showRetry: true,
          onRetry: () {
            Navigator.of(context).pop();
            _downloadPdf();
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
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
            // Top action bar
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
    return ElevatedButton.icon(
      onPressed: isLoading || hasError || isDownloading ? null : _downloadPdf,
      icon:
          isDownloading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.download, color: Colors.white),
      label: Text(
        isDownloading
            ? 'Téléchargement...'
            : kIsWeb
            ? 'Télécharger PDF'
            : 'Télécharger et Partager PDF',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
