// QR Code Helper - Handles QR code download and sharing functionality
// Supports multiple platforms: Desktop (Windows/Linux/macOS) and Mobile (Android/iOS)

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:editor_app/data/qr_code_generator.dart';

class QRCodeHelper {
  // Download and optionally share QR code for an exhibit
  // Returns true if operation was successful, false otherwise
  static Future<bool> downloadQRCode({
    required int exhibit_id,
    required String exhibitTitle,
  }) async {
    try {
      // Generate QR code image from exhibit ID only
      final Uint8List qrBytes =
          await QRCodeGenerator.generateQRCodeImage(exhibit_id);

      // Create filename based on exhibit title
      final filename = QRCodeGenerator.getQRCodeFilename(exhibitTitle);

      // ─────────────────────────────────────────────────────────────
      // DESKTOP PLATFORMS (Windows / Linux / macOS)
      // ─────────────────────────────────────────────────────────────
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // Show save file dialog for desktop users
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save QR Code',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['png'], // Only PNG format supported
        );

        if (outputPath == null) return false; // User cancelled

        // Ensure file has .png extension
        if (!outputPath.endsWith('.png')) {
          outputPath += '.png';
        }

        // Write QR code bytes to selected location
        await File(outputPath).writeAsBytes(qrBytes);
        return true;
      }

      // ─────────────────────────────────────────────────────────────
      // MOBILE PLATFORMS (Android / iOS)
      // ─────────────────────────────────────────────────────────────
      if (Platform.isAndroid || Platform.isIOS) {
        // Android requires storage permission
        if (Platform.isAndroid) {
          await Permission.storage.request();
        }

        // Save QR code to app's documents directory
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(qrBytes);

        // Share the file using platform's native sharing dialog
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'QR Code for "$exhibitTitle"', // Optional share text
        );

        return true;
      }

      // Unsupported platform
      return false;
    } catch (e) {
      debugPrint('Error downloading QR code: $e');
      return false;
    }
  }
}