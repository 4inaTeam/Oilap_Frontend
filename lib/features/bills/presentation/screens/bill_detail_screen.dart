import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:oilab_frontend/core/models/bill_model.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';
import '../../../factures/presentation/bloc/facture_bloc.dart';
import '../../../factures/presentation/bloc/facture_state.dart';

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
  Uint8List? imageBytes; // Fallback for memory storage
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
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

      // Download image from backend
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Try to save to file, fallback to memory if path_provider fails
        try {
          final dir = await getTemporaryDirectory();
          final file = File(
            '${dir.path}/bill_image_${widget.billId ?? widget.bill.id ?? 'temp'}.jpg',
          );
          await file.writeAsBytes(response.bodyBytes);

          setState(() {
            localPath = file.path;
            imageBytes = null; // Clear memory storage
            isLoading = false;
          });
        } catch (pathError) {
          // Fallback to memory storage
          print('Path provider failed, using memory storage: $pathError');
          setState(() {
            imageBytes = response.bodyBytes;
            localPath = null;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadPdf(String pdfUrl) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Téléchargement en cours...'),
          backgroundColor: AppColors.mainColor,
        ),
      );

      final response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/facture_${widget.billId ?? widget.bill.id ?? 'temp'}.pdf',
        );

        await file.writeAsBytes(response.bodyBytes);

        // Share the PDF file
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Facture PDF ${widget.billTitle ?? widget.bill.owner}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF téléchargé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadBillImage() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Téléchargement en cours...'),
          backgroundColor: AppColors.mainColor,
        ),
      );

      if (localPath != null) {
        // Share the image file directly
        await Share.shareXFiles([
          XFile(localPath!),
        ], text: 'Facture ${widget.billTitle ?? widget.bill.owner}');
      } else if (imageBytes != null) {
        // Create temporary file from memory bytes
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/facture_${widget.billId ?? widget.bill.id ?? 'temp'}.jpg',
        );
        await file.writeAsBytes(imageBytes!);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Facture ${widget.billTitle ?? widget.bill.owner}');
      } else {
        throw Exception('Aucune image disponible pour le téléchargement');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image téléchargée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            // Top action bar with download button
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
        onPressed: isLoading || hasError ? null : _downloadBillImage,
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('Télécharger', style: TextStyle(color: Colors.white)),
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
    if (localPath != null) {
      // Display from file
      return Image.file(
        File(localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    } else if (imageBytes != null) {
      // Display from memory
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
