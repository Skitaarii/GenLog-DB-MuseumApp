import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:editor_app/data/qr_code_generator.dart';

class QRCodeHelper {

    static Future<XFile?> generateQRCodeFile({
    required int exhibit_id,
    required int roomId,
    required String exhibitTitle,
    required String roomName,
  }) async {
    try {
      final qrBytes = await QRCodeGenerator.generateQRCodeImage(
        exhibit_id,
        roomId,
      );
      
      final filename = QRCodeGenerator.getQRCodeFilename(exhibitTitle, roomName);
      
      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(qrBytes);
      
      return XFile(file.path);
    } catch (e) {
      print('Error generating QR code file: $e');
      return null;
    }
  }
  
  
  static Future<bool> downloadQRCode({
    required int exhibit_id,
    required int roomId,
    required String exhibitTitle,
    required String roomName,
  }) async {
    try {
      // Generate QR code from QR_id ONLY
      final Uint8List qrBytes =
          await QRCodeGenerator.generateQRCodeImage(exhibit_id,roomId);

      final filename = QRCodeGenerator.getQRCodeFilename(
        exhibitTitle, roomName
      );

      // ─────────────────────────────────────────────────────────────
      // DESKTOP (Windows / Linux / macOS)
      // ─────────────────────────────────────────────────────────────
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save QR Code',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['png'],
        );

        if (outputPath == null) return false;

        if (!outputPath.endsWith('.png')) {
          outputPath += '.png';
        }

        await File(outputPath).writeAsBytes(qrBytes);
        return true;
      }

      // ─────────────────────────────────────────────────────────────
      // MOBILE (Android / iOS)
      // ─────────────────────────────────────────────────────────────
      if (Platform.isAndroid || Platform.isIOS) {
        if (Platform.isAndroid) {
          await Permission.storage.request();
        }

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(qrBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'QR Code for "$exhibitTitle"',
        );

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error downloading QR code: $e');
      return false;
    }
  }
}