import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGenerator {
  /// Generate QR code image as PNG bytes
  static Future<Uint8List> generateQRCodeImage(
    int exhibitId, {
    int size = 512,
  }) async {
    final qrData = jsonEncode({
      'exhibit_id': exhibitId,
    });

    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    qrPainter.paint(canvas, Size(size.toDouble(), size.toDouble()));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static String getQRCodeFilename(String exhibitTitle) {
    final cleanTitle = exhibitTitle
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    return 'qr_exhibit_$cleanTitle.png';
  }
}
