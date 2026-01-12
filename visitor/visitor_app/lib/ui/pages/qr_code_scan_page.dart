// Veuillet Gaëtan et Weber Benno
// 2025
// Description : QR code scan page with real camera scanning
// Main scanning interface for QR code detection and manual exhibit ID input

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/itinerary_dao.dart';
import 'package:visitor_app/data/favorites_dao.dart';
import 'package:visitor_app/ui/pages/visitor_exhibit_info_page.dart';
import 'package:visitor_app/ui/pages/visitor_browse_page.dart';
import 'package:visitor_app/utils/language_manager.dart';
import 'dart:convert';

class QRCodeScanPage extends StatefulWidget {
  final VisitorDao visitorDao;
  final ItineraryDao itineraryDao;
  final FavoritesDao favoritesDao;
  final int sessionId;

  const QRCodeScanPage({
    super.key,
    required this.visitorDao,
    required this.itineraryDao,
    required this.favoritesDao,
    required this.sessionId,
  });

  @override
  State<QRCodeScanPage> createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  late MobileScannerController _scannerController; // Camera controller for QR scanning
  bool _isProcessing = false; // Prevents multiple QR code processing at once
  bool _isLoading = false; // Loading state during data processing

  @override
  void initState() {
    super.initState();
    // Initialize camera controller with default settings
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose(); // Clean up camera resources
    super.dispose();
  }
  

  // Process scanned QR code data and navigate to exhibit page
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
      final roomId = data['room_id'] as int? ?? 1; // Default to room 1 if not specified
      
      // Register the scan in database
      await widget.visitorDao.recordQRScan(
        sessionId: widget.sessionId,
        exhibitId: exhibitId,
      );

      // Get exhibit details from database
      final exhibitDetails = await widget.visitorDao.getExhibitDetails(exhibitId);

      if (!mounted) return; // Check if widget is still in tree

      if (exhibitDetails != null) {
        // Navigate to exhibit info page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitorExhibitInfoPage(
              exhibitDetails: exhibitDetails,
              visitorDao: widget.visitorDao,
              favoritesDao: widget.favoritesDao,
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
        // Exhibit not found
        _showErrorDialog('${'exhibit_notfound'.tr} (ID: $exhibitId)'.tr);
        setState(() {
          _isProcessing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Invalid QR code format
      if (mounted) {
        _showErrorDialog('${'qrcode_invalid'.tr }: ${e.toString()}');
        setState(() {
          _isProcessing = false;
          _isLoading = false;
        });
      }
    }
  }

  // Show error dialog for invalid QR codes or exhibit not found
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  // Toggle camera flash on/off
  void _toggleTorch() {
    _scannerController.toggleTorch();
  }

  // Navigate to browse page with itineraries and favorites
  void _navigateToBrowsePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitorBrowsePage(
          visitorDao: widget.visitorDao,
          itineraryDao: widget.itineraryDao,
          favoritesDao: widget.favoritesDao,
          sessionId: widget.sessionId,
        ),
      ),
    );
  }

  // Show dialog for manual exhibit ID input
  void _showManualInputDialog() {
    final TextEditingController idController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'enter_exhibit'.tr,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'exhibit_id'.tr,
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  hintText: 'exemple'.tr,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.numbers, color: Colors.purple[300]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel'.tr,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            // Submit button
            ElevatedButton(
              onPressed: () {
                final id = int.tryParse(idController.text);
                if (id != null) {
                  Navigator.pop(context);
                  // Create JSON format like QR code would have
                  final qrData = '{"exhibit_id": $id, "room_id": 1}';
                  _processQRCode(qrData);
                } else {
                  // Invalid number input
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('enter_validNbr'.tr),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Go'.tr,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'scan_qr'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Flash toggle button
          IconButton(
            icon: const Icon(
              Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'toggle_flash'.tr,
          ),
          const LanguageSelector(), // Language selector in app bar
        ],
      ),
      // Browse button floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBrowsePage,
        backgroundColor: Colors.purple[700],
        child: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListenableBuilder(
          listenable: LanguageManager(), 
          builder: (context, builder) => _isLoading
          ? // Loading state when processing QR code
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'loading'.tr,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : // Main scanning interface
          Stack(
              children: [
                // Camera view for QR scanning
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    if (_isProcessing) return; // Prevent multiple processing
                    
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _processQRCode(barcode.rawValue!);
                        break; // Process first valid QR code
                      }
                    }
                  },
                ),
                
                // Overlay gradient for better visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7), // Top gradient
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7), // Bottom gradient
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Instructions overlay
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
                          Text(
                            "camera_qr".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'exhibit_load'.tr,
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
                    
                    // Scanning frame (visual guide for QR placement)
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
                            const AnimatedScanLine(),
                            
                            // Corner decorations for better visibility
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
                    
                    // Manual input button (alternative to QR scanning)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextButton.icon(
                        onPressed: _showManualInputDialog,
                        icon: Icon(Icons.keyboard, color: Colors.purple[300], size: 20),
                        label: Text(
                          'manual_id'.tr,
                          style: TextStyle(
                            color: Colors.purple[300],
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Session info display at bottom
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[800]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 16,
                            color: Colors.purple[300],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Session: ${widget.sessionId}',
                            style: TextStyle(
                              fontSize: 13,
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
          )    ),
    );
  }
}

// Animated scanning line widget for visual feedback
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
    // Create animation controller for continuous scanning line movement
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Loop animation

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
          top: _animation.value * 250, // Animated vertical position
          left: 20,
          right: 20,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.purple[300]!, // Center highlight
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