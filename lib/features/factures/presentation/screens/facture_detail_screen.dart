// Updated FactureDetailScreen - Key changes for PDF download
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oilab_frontend/shared/services/stripe_service.dart';
import 'package:oilab_frontend/shared/widgets/app_layout.dart';
import 'package:oilab_frontend/core/constants/app_colors.dart';
import 'package:oilab_frontend/core/constants/consts.dart';
import 'package:oilab_frontend/core/models/facture_model.dart';
import 'package:oilab_frontend/core/utils/pdf_utils.dart';
import '../bloc/facture_bloc.dart';
import '../bloc/facture_event.dart';
import '../bloc/facture_state.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// Import the dialog widgets
import 'package:oilab_frontend/shared/dialogs/success_dialog.dart';
import 'package:oilab_frontend/shared/dialogs/error_dialog.dart';

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
  bool _isDownloading = false;
  PdfControllerPinch? _pdfController;
  bool _isLoadingPdf = false;
  String? _pdfError;
  Uint8List? _pdfBytes;

  // Add a reference to the BlocProvider to access it safely
  FactureBloc? _factureBloc;

  @override
  void initState() {
    super.initState();
    _factureBloc = context.read<FactureBloc>();
    _factureBloc?.add(GetFacturePdf(widget.factureId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _factureBloc ??= context.read<FactureBloc>();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _pdfController = null;
    _factureBloc = null;
    super.dispose();
  }

  Future<void> _loadPdfController(String pdfUrl) async {
    if (!mounted) return;
    if (_pdfController != null || _isLoadingPdf) return;

    setState(() {
      _isLoadingPdf = true;
      _pdfError = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(pdfUrl),
            headers: {
              'Accept': 'application/pdf',
              'Cache-Control': 'max-age=300',
              'Accept-Encoding': 'gzip, deflate',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && !contentType.contains('application/pdf')) {
          throw Exception('Response is not a PDF. Content-Type: $contentType');
        }

        if (response.bodyBytes.length < 100) {
          throw Exception(
            'PDF data is too small (${response.bodyBytes.length} bytes)',
          );
        }

        _pdfBytes = response.bodyBytes;

        final document = PdfDocument.openData(_pdfBytes!);
        final controller = PdfControllerPinch(
          document: document,
          initialPage: 1,
        );

        if (!mounted) {
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
        showCustomErrorDialog(
          context,
          message: 'Erreur lors du chargement du PDF',
          showRetry: true,
          onRetry: () {
            Navigator.of(context).pop();
            _loadPdfController(pdfUrl);
          },
        );
      }
    }
  }

  // UPDATED: Simplified download method using unified PdfUtils
  Future<void> _downloadPdf(String pdfUrl) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final fileName = 'facture_${widget.facture.factureNumber}.pdf';

      // Use the unified PDF utils - it will handle platform-specific logic
      final result = await PdfUtils.downloadPdfFromUrl(
        url: pdfUrl,
        fileName: fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomErrorDialog(
          context,
          message: 'Erreur lors du téléchargement: ${e.toString()}',
          showRetry: true,
          onRetry: () {
            Navigator.of(context).pop();
            _downloadPdf(pdfUrl);
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  // Rest of your existing methods remain the same...
  Future<void> _processPayment() async {
    if (!mounted) return;

    if (widget.facture.paymentStatus == 'paid') {
      if (mounted) {
        showCustomErrorDialog(
          context,
          message: 'Cette facture a déjà été payée',
          showRetry: false,
        );
      }
      return;
    }

    if (widget.facture.finalTotal < AppConfig.minPaymentAmount) {
      if (mounted) {
        showCustomErrorDialog(
          context,
          message:
              'Le montant minimum pour un paiement est de \${AppConfig.minPaymentAmount}. Montant actuel: \${widget.facture.finalTotal}',
          showRetry: false,
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
        _factureBloc?.add(GetFacturePdf(widget.factureId));
        _showPaymentSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        showCustomErrorDialog(
          context,
          message: 'Erreur de paiement: ${e.toString()}',
          showRetry: true,
          onRetry: () {
            Navigator.of(context).pop();
            _processPayment();
          },
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

    showSuccessDialog(
      context,
      title: 'Paiement réussi',
      message:
          'Votre paiement a été traité avec succès. La facture a été marquée comme payée.',
      onContinue: () {
        Navigator.of(context).pop();
        _goBackToList();
      },
    );
  }

  void _goBackToList() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/factures/client');
    }
  }

  // Your existing _buildOptimizedPdfViewer method remains the same...
  Widget _buildOptimizedPdfViewer(String pdfUrl) {
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
                          _isDownloading || pdfUrl == null
                              ? null
                              : () => _downloadPdf(pdfUrl!),
                      icon:
                          _isDownloading
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
                        _isDownloading ? 'Téléchargement...' : 'Télécharger',
                        style: const TextStyle(color: Colors.white),
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
