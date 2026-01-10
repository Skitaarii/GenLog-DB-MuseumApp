// Gaëtan Veuillet
// 2025
// QR Code Generator Utility (Editor App)

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGenerator {
  /// Generate QR code image as PNG bytes
  static Future<Uint8List> generateQRCodeImage(
    int exhibitId, 
    int roomId, {
    int size = 512,
  }) async {
    // Create JSON data for QR code
    final qrData = jsonEncode({
      'exhibit_id': exhibitId,
      'room_id': roomId,
    });

    // Create QR code painter
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );

    // Create image from painter
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    qrPainter.paint(canvas, Size(size.toDouble(), size.toDouble()));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    
    // Convert to PNG bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Get filename for QR code
  static String getQRCodeFilename(int exhibitId, int roomId, String exhibitTitle) {
    // Clean exhibit title for filename
    final cleanTitle = exhibitTitle
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    
    return 'qr_exhibit_${exhibitId}_room_${roomId}_${cleanTitle}.png';
  }
}