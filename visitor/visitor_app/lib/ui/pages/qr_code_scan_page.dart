// Veuillet Gaëtan
// 2025
// Description: QR code scan page with camera scanning only

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/qr_code_dao.dart';
import 'package:visitor_app/ui/pages/visitor_exhibit_info_page.dart';

class QRCodeScanPage extends StatefulWidget {
  final VisitorDao visitorDao;
  final QRCodeDao qrCodeDao;
  final int sessionId;

  const QRCodeScanPage({
    super.key,
    required this.visitorDao,
    required this.qrCodeDao,
    required this.sessionId,
  });

  @override
  State<QRCodeScanPage> createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  bool _isLoading = false;
  bool _isProcessing = false;
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String qrData) async {
    // Prevent processing multiple QR codes at once
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _isLoading = true;
    });

    try {
      // Parse JSON format: {"exhibit_id": 1, "room_id": 2}
      final data = jsonDecode(qrData);
      final exhibitId = data['exhibit_id'] as int;
      
      // Register the scan
      await widget.visitorDao.recordQRScan(
        sessionId: widget.sessionId,
        exhibitId: exhibitId,
      );

      // Get exhibit details
      final exhibitDetails = await widget.visitorDao.getExhibitDetails(exhibitId);

      if (!mounted) return;

      if (exhibitDetails != null) {
        // Navigate to exhibit info page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitorExhibitInfoPage(
              exhibitDetails: exhibitDetails,
              visitorDao: widget.visitorDao,
              sessionId: widget.sessionId,
            ),
          ),
        );
        
        // Reset processing state when returning from exhibit page
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isLoading = false;
          });
        }
      } else {
        _showErrorDialog('Exhibit not found (ID: $exhibitId)');
        setState(() {
          _isProcessing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error: ${e.toString()}');
        setState(() {
          _isProcessing = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text('Error', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[700]!, Colors.deepPurple[700]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Toggle flashlight',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading exhibit information...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Camera view
                MobileScanner(
                  controller: _scannerController, 
                  onDetect: (capture) {
                    if (_isProcessing) return;
                    
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _processQRCode(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                
                // Overlay with scanning instructions
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Instructions
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[300]!, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 40,
                            color: Colors.purple[300],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Point your camera at the QR code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The exhibit will load automatically',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Scanning frame
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.purple[300]!,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Animated scanning line
                            AnimatedScanLine(),
                            
                            // Corner decorations
                            Positioned(
                              top: -2,
                              left: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.purple, width: 6),
                                    left: BorderSide(color: Colors.purple, width: 6),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.purple, width: 6),
                                    right: BorderSide(color: Colors.purple, width: 6),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              left: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.purple, width: 6),
                                    left: BorderSide(color: Colors.purple, width: 6),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.purple, width: 6),
                                    right: BorderSide(color: Colors.purple, width: 6),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Session info at bottom
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[800]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 18,
                            color: Colors.purple[300],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Session ID: ${widget.sessionId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
    );
  }
}

// Animated scanning line widget
class AnimatedScanLine extends StatefulWidget {
  const AnimatedScanLine({super.key});

  @override
  State<AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<AnimatedScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value * 250,
          left: 20,
          right: 20,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.purple[300]!,
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}