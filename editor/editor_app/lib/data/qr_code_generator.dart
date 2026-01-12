// QR Code Generator - Handles QR code creation and file naming
// Generates QR codes containing exhibit ID for museum scanning system

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGenerator {
  /// Generate QR code image as PNG bytes
  /// Creates a QR code containing JSON data with exhibit ID
  /// 
  /// Parameters:
  /// - `exhibitId`: Unique identifier of the exhibit
  /// - `size`: Output image dimensions (default: 512px)
  /// 
  /// Returns: PNG image bytes ready for saving or sharing
  static Future<Uint8List> generateQRCodeImage(
    int exhibitId,
    int roomId, {
    int size = 512,
  }) async {
    // Create JSON structure containing exhibit ID
    final qrData = jsonEncode({
      'exhibit_id': exhibitId,
      'room_id': roomId,
    });

    // Configure QR code painter with optimal settings
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,           // Automatically choose optimal QR version
      errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction for reliability
      color: const Color(0xFF000000),     // Black QR code
      emptyColor: const Color(0xFFFFFFFF), // White background
    );

    // Set up canvas for rendering
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Paint QR code onto canvas
    qrPainter.paint(canvas, Size(size.toDouble(), size.toDouble()));

    // Convert canvas to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static String getQRCodeFilename(String exhibitTitle, String roomName) {
  /// Generate a clean filename for QR code image
  /// Removes special characters and spaces from exhibit title
  /// 
  /// Parameters:
  /// - `exhibitTitle`: Original exhibit title
  /// 
  /// Returns: Sanitized filename (e.g., 'qr_exhibit_mona_lisa.png')

    // Remove special characters, replace spaces with underscores, convert to lowercase
    final cleanTitle = exhibitTitle
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    
    final cleanRoom = roomName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    return 'qr_${cleanRoom}_${cleanTitle}.png';
  }
}