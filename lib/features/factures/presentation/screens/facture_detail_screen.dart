import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/shared/services/stripe_service.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/core/constants/consts.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';
import '../bloc/facture_bloc.dart';
import '../bloc/facture_event.dart';
import '../bloc/facture_state.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// **Conditional import** picks web or stub automatically:

// Conditional imports for web
import 'dart:html' as html show window, AnchorElement;

class FactureDetailScreen extends StatefulWidget {
  final int factureId;
  final Facture facture;

  const FactureDetailScreen({
    super.key,
    required this.factureId,
    required this.facture,
  });

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  bool _isProcessingPayment = false;
  Uint8List? _pdfBytes;
  bool _isLoadingPdfBytes = false;

  @override
  void initState() {
    super.initState();
    context.read<FactureBloc>().add(GetFacturePdf(widget.factureId));
  }

  // Fetch PDF bytes for web
  Future<void> _fetchPdfBytes(String pdfUrl) async {
    if (kIsWeb && _pdfBytes == null && !_isLoadingPdfBytes) {
      setState(() {
        _isLoadingPdfBytes = true;
      });

      try {
        final response = await http.get(
          Uri.parse(pdfUrl),
          headers: {'Accept': 'application/pdf'},
        );

        if (response.statusCode == 200) {
          setState(() {
            _pdfBytes = response.bodyBytes;
            _isLoadingPdfBytes = false;
          });
        } else {
          setState(() {
            _isLoadingPdfBytes = false;
          });
          throw Exception('Failed to load PDF: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _isLoadingPdfBytes = false;
        });
        print('Error fetching PDF bytes: $e');

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement du PDF: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadPdf(String pdfUrl) async {
    if (kIsWeb) {
      // For web, create a download link
      html.AnchorElement(href: pdfUrl)
        ..setAttribute(
          'download',
          'facture_${widget.facture.factureNumber}.pdf',
        )
        ..click();
    } else {
      // For mobile platforms
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d\'ouvrir le lien de téléchargement du PDF',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openPdfInNewTab(String pdfUrl) async {
    if (kIsWeb) {
      html.window.open(pdfUrl, '_blank');
    } else {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _processPayment() async {
    // Check if facture is already paid
    if (widget.facture.paymentStatus == 'paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette facture a déjà été payée'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if payment amount is valid
    if (widget.facture.finalTotal < AppConfig.minPaymentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le montant minimum pour un paiement est de \${AppConfig.minPaymentAmount}. Montant actuel: \${widget.facture.finalTotal}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final success = await StripeService.instance.makePayment(
        factureId: widget.factureId,
        context: context,
      );

      if (success) {
        // Refresh the facture data after successful payment
        context.read<FactureBloc>().add(GetFacturePdf(widget.factureId));

        // Show success dialog
        _showPaymentSuccessDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de paiement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Paiement réussi'),
            ],
          ),
          content: const Text(
            'Votre paiement a été traité avec succès. La facture a été marquée comme payée.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                _goBackToList(); 
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _goBackToList() {
    Navigator.of(context).pushReplacementNamed('/factures');
  }

  // Build PDF viewer based on platform
  Widget _buildPdfViewer(String pdfUrl) {
    if (kIsWeb) {
      // For web, first try to load PDF bytes
      if (_pdfBytes != null) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SfPdfViewer.memory(
            _pdfBytes!,
            onDocumentLoadFailed: (details) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading PDF: ${details.error}')),
              );
            },
          ),
        );
      } else if (_isLoadingPdfBytes) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement du PDF...'),
              ],
            ),
          ),
        );
      } else {
        // Try to fetch PDF bytes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fetchPdfBytes(pdfUrl);
        });

        // Show fallback message with options
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Aperçu PDF non disponible',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utilisez les boutons ci-dessus pour ouvrir ou télécharger le PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _openPdfInNewTab(pdfUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ouvrir dans le navigateur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // For mobile platforms, use SfPdfViewer.network
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SfPdfViewer.network(
          pdfUrl,
          onDocumentLoadFailed: (details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading PDF: ${details.error}')),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBackToList,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Facture Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facture #${widget.facture.factureNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant total: \$${widget.facture.finalTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.facture.paymentStatus == 'paid'
                                    ? Colors.green
                                    : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.facture.paymentStatus == 'paid'
                                ? 'Payée'
                                : 'En attente',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isProcessingPayment ||
                              widget.facture.paymentStatus == 'paid'
                          ? null
                          : _processPayment,
                  icon:
                      _isProcessingPayment
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.payment, color: Colors.white),
                  label: Text(
                    _isProcessingPayment
                        ? 'Traitement...'
                        : widget.facture.paymentStatus == 'paid'
                        ? 'Déjà payée'
                        : 'Payer',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.facture.paymentStatus == 'paid'
                            ? Colors.grey
                            : AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<FactureBloc, FactureState>(
                  builder: (context, state) {
                    String? pdfUrl;
                    if (state is FacturePdfLoaded) {
                      pdfUrl = state.pdfUrl;
                    }
                    return ElevatedButton.icon(
                      onPressed:
                          pdfUrl != null ? () => _downloadPdf(pdfUrl!) : null,
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Télécharger',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<FactureBloc, FactureState>(
              builder: (context, state) {
                if (state is FactureLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FactureError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<FactureBloc>().add(
                                GetFacturePdf(widget.factureId),
                              ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is FacturePdfLoaded) {
                  return Column(
                    children: [
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Ouvrir dans le navigateur'),
                            onPressed: () => _openPdfInNewTab(state.pdfUrl),
                          ),
                          if (kIsWeb)
                            TextButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Recharger PDF'),
                              onPressed: () {
                                setState(() {
                                  _pdfBytes = null;
                                  _isLoadingPdfBytes = false;
                                });
                                _fetchPdfBytes(state.pdfUrl);
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPdfViewer(state.pdfUrl),
                    ],
                  );
                }
                return const Center(
                  child: Text(
                    'Une erreur s\'est produite lors du chargement du PDF',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
