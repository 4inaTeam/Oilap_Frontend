import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:oilab_frontend/core/models/bill_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_layout.dart';

class BillDetailScreen extends StatefulWidget {
  final String? imageUrl; // Changed from pdfUrl to imageUrl
  final Bill bill;
  final String? billTitle;
  final int? billId;

  const BillDetailScreen({
    Key? key,
    this.imageUrl, // Now optional since we can get it from bill
    required this.bill,
    this.billTitle,
    this.billId,
  }) : super(key: key);

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  String? localPath;
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
    // Priority: widget.imageUrl > bill.originalImage
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return widget.imageUrl;
    }
    
    if (widget.bill.originalImage != null && widget.bill.originalImage!.isNotEmpty) {
      // If the URL is already absolute, return it
      if (widget.bill.originalImage!.startsWith('http')) {
        return widget.bill.originalImage;
      }
      // If it's relative, make it absolute (assuming your base URL)
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
        // Get temporary directory
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/bill_image_${widget.billId ?? widget.bill.id ?? 'temp'}.jpg',
        );

        // Write image bytes to file
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localPath = file.path;
          isLoading = false;
        });
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

  Future<void> _shareImage() async {
    try {
      if (localPath == null) return;

      // Share the image file
      await Share.shareXFiles([
        XFile(localPath!),
      ], text: 'Facture ${widget.billTitle ?? widget.bill.owner}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image partagée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _previousScale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButtons(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.billTitle ?? 'Facture ${widget.bill.owner}',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (!isLoading && !hasError && localPath != null)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Image',
              style: TextStyle(color: AppColors.mainColor, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (localPath == null) {
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
          Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
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
              child: Transform.scale(
                scale: _scale,
                child: Image.file(
                  File(localPath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
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
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (isLoading || hasError || localPath == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom In
        FloatingActionButton(
          heroTag: "zoom_in",
          mini: true,
          backgroundColor: AppColors.mainColor,
          onPressed: () {
            setState(() {
              _scale = (_scale * 1.2).clamp(0.5, 5.0);
              _previousScale = _scale;
            });
          },
          child: const Icon(Icons.zoom_in, color: Colors.white),
        ),
        const SizedBox(height: 8),

        // Zoom Out
        FloatingActionButton(
          heroTag: "zoom_out",
          mini: true,
          backgroundColor: AppColors.mainColor,
          onPressed: () {
            setState(() {
              _scale = (_scale / 1.2).clamp(0.5, 5.0);
              _previousScale = _scale;
            });
          },
          child: const Icon(Icons.zoom_out, color: Colors.white),
        ),
        const SizedBox(height: 8),

        // Reset Zoom
        FloatingActionButton(
          heroTag: "reset_zoom",
          mini: true,
          backgroundColor: Colors.orange,
          onPressed: _resetZoom,
          child: const Icon(Icons.center_focus_strong, color: Colors.white),
        ),
        const SizedBox(height: 8),

        // Share Image
        FloatingActionButton(
          heroTag: "share",
          backgroundColor: Colors.green,
          onPressed: _shareImage,
          child: const Icon(Icons.share, color: Colors.white),
        ),
        const SizedBox(height: 8),

        // Save to Gallery (optional)
        FloatingActionButton(
          heroTag: "save",
          mini: true,
          backgroundColor: Colors.blue,
          onPressed: () {
            // Implement save to gallery functionality if needed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité de sauvegarde à venir'),
              ),
            );
          },
          child: const Icon(Icons.save_alt, color: Colors.white),
        ),
      ],
    );
  }
}

// Updated extension for navigation
extension BillDetailNavigation on BuildContext {
  void navigateToBillDetail({
    String? imageUrl, // Changed from pdfUrl to imageUrl
    required Bill bill,
    String? billTitle,
    int? billId,
  }) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => BillDetailScreen(
          imageUrl: imageUrl,
          bill: bill,
          billTitle: billTitle,
          billId: billId,
        ),
      ),
    );
  }
}