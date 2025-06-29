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
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// Platform-specific imports
import '../helpers/pdf_utils_stub.dart'
    if (dart.library.html) '../helpers/pdf_utils_web.dart'
    as pdf_utils;

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
  // State variables
  bool _isProcessingPayment = false;
  PdfControllerPinch? _pdfController;
  bool _isLoadingPdf = false;
  String? _pdfError;
  Uint8List? _pdfBytes;

  // Add a reference to the BlocProvider to access it safely
  FactureBloc? _factureBloc;

  @override
  void initState() {
    super.initState();
    // Initialize the bloc reference early
    _factureBloc = context.read<FactureBloc>();
    _factureBloc?.add(GetFacturePdf(widget.factureId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store the bloc reference when dependencies change
    _factureBloc ??= context.read<FactureBloc>();
  }

  @override
  void dispose() {
    // Dispose PDF controller first
    _pdfController?.dispose();
    _pdfController = null;

    // Clear the bloc reference
    _factureBloc = null;

    super.dispose();
  }

  Future<void> _loadPdfController(String pdfUrl) async {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    if (_pdfController != null || _isLoadingPdf) return;

    if (!mounted) return;
    setState(() {
      _isLoadingPdf = true;
      _pdfError = null;
    });

    try {
      // Optimized HTTP request with smaller timeout and better headers
      final response = await http
          .get(
            Uri.parse(pdfUrl),
            headers: {
              'Accept': 'application/pdf',
              'Cache-Control': 'max-age=300', // Allow caching for 5 minutes
              'Accept-Encoding': 'gzip, deflate',
            },
          )
          .timeout(const Duration(seconds: 15)); // Reduced timeout

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      if (response.statusCode == 200) {
        // Verify content type
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/pdf')) {
          throw Exception('Response is not a PDF. Content-Type: $contentType');
        }

        // Verify we have actual PDF data
        if (response.bodyBytes.length < 100) {
          throw Exception(
            'PDF data is too small (${response.bodyBytes.length} bytes)',
          );
        }

        _pdfBytes = response.bodyBytes;

        // Create PDF controller with optimized settings
        final document = PdfDocument.openData(_pdfBytes!);
        final controller = PdfControllerPinch(
          document: document,
          initialPage: 1,
        );

        if (!mounted) {
          // If widget is no longer mounted, dispose the controller
          controller.dispose();
          return;
        }

        setState(() {
          _pdfController = controller;
          _isLoadingPdf = false;
          _pdfError = null;
        });
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingPdf = false;
        _pdfError = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement du PDF'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(String pdfUrl) async {
    if (kIsWeb) {
      // Use web-specific download
      pdf_utils.downloadPdfWeb(
        pdfUrl,
        'facture_${widget.facture.factureNumber}.pdf',
      );
    } else {
      // Use URL launcher for mobile/desktop
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir le lien du PDF'),
            ),
          );
        }
      }
    }
  }

  Future<void> _processPayment() async {
    // Check if widget is still mounted
    if (!mounted) return;

    // Check if facture is already paid
    if (widget.facture.paymentStatus == 'paid') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cette facture a déjà été payée'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Check if payment amount is valid
    if (widget.facture.finalTotal < AppConfig.minPaymentAmount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Le montant minimum pour un paiement est de \${AppConfig.minPaymentAmount}. Montant actuel: \${widget.facture.finalTotal}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final success = await StripeService.instance.makePayment(
        factureId: widget.factureId,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        // Use the stored bloc reference instead of context.read
        _factureBloc?.add(GetFacturePdf(widget.factureId));
        _showPaymentSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de paiement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showPaymentSuccessDialog() {
    if (!mounted) return;

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
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/factures/client');
    }
  }

  Widget _buildOptimizedPdfViewer(String pdfUrl) {
    // Auto-load PDF when URL is available
    if (_pdfController == null && !_isLoadingPdf && _pdfError == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadPdfController(pdfUrl);
        }
      });
    }

    if (_isLoadingPdf) {
      return Container(
        height: kIsWeb ? 600 : MediaQuery.of(context).size.height * 0.6,
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
    }

    if (_pdfError != null) {
      return Container(
        height: kIsWeb ? 600 : MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erreur lors du chargement du PDF',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _pdfController?.dispose();
                      _pdfController = null;
                      _isLoadingPdf = false;
                      _pdfError = null;
                      _pdfBytes = null;
                    });
                    _loadPdfController(pdfUrl);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_pdfController != null) {
      return Container(
        height: kIsWeb ? 600 : MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: PdfViewPinch(
            controller: _pdfController!,
            scrollDirection: Axis.vertical,
            onDocumentError: (error) {
              if (mounted) {
                setState(() {
                  _pdfError = 'Erreur de document PDF';
                });
              }
            },
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(
                loaderSwitchDuration: Duration(milliseconds: 300),
              ),
              documentLoaderBuilder:
                  (_) => const Center(child: CircularProgressIndicator()),
              pageLoaderBuilder:
                  (_) => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );
    }

    return Container(
      height: kIsWeb ? 600 : MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'PDF non disponible',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: "/factures/client/detail",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                          onPressed: () {
                            // Use the stored bloc reference instead of context.read
                            _factureBloc?.add(GetFacturePdf(widget.factureId));
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is FacturePdfLoaded) {
                  return _buildOptimizedPdfViewer(state.pdfUrl);
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
