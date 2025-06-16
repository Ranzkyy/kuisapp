import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class CertificateService {
  Future<void> generateAndShareCertificate({
    String? userName,
    required String courseName,
    required DateTime completionDate,
  }) async {
    // Ambil nama lengkap dari SharedPreferences jika userName null
    String finalName = userName ?? '';
    if (finalName.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      finalName = prefs.getString('userName') ?? 'User';
    }

    // Minta izin penyimpanan
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        // Izin diberikan
      } else if (await Permission.manageExternalStorage.request().isGranted) {
        // Izin diberikan untuk Android 11+
      } else {
        throw Exception('Izin penyimpanan diperlukan untuk mengunduh sertifikat');
      }
    }

    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(0xFF6C63FF);
    final accentColor = PdfColor.fromInt(0xFF4A45B1);
    final logoBytes = await rootBundle.load('assets/logo_kuisapp.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [themeColor, accentColor],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Stack(
              children: [
                // Watermark/logo transparan di tengah
                pw.Positioned(
                  left: 0,
                  right: 0,
                  top: 60,
                  child: pw.Center(
                    child: pw.Opacity(
                      opacity: 0.10,
                      child: pw.Image(logoImage, width: 350),
                    ),
                  ),
                ),
                // Isi utama sertifikat
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Header
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(
                            children: [
                              pw.Image(logoImage, width: 48),
                              pw.SizedBox(width: 12),
                              pw.Text(
                                'KuisApp',
                                style: pw.TextStyle(
                                  fontSize: 32,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text('SERTIFIKAT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: themeColor)),
                          ),
                        ],
                      ),
                      pw.Spacer(),
                      // Elemen kuis (trophy, badge)
                      pw.Image(logoImage, width: 60),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'SERTIFIKAT KELULUSAN',
                        style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 18),
                      pw.Text(
                        'Diberikan kepada',
                        style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        finalName,
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Atas keberhasilan menyelesaikan modul:',
                        style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        courseName,
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 18),
                      pw.Text(
                        'Tanggal Kelulusan:',
                        style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                      ),
                      pw.Text(
                        DateFormat('dd MMMM yyyy', 'id_ID').format(completionDate),
                        style: pw.TextStyle(fontSize: 20, color: PdfColors.amber),
                      ),
                      pw.Spacer(),
                      // Penanda keaslian
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Asli diterbitkan oleh KuisApp',
                            style: pw.TextStyle(fontSize: 14, color: PdfColors.white, fontStyle: pw.FontStyle.italic),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Text(
                              'ID: KUISAPP-${DateFormat('yyyyMMddHHmmss').format(completionDate)}',
                              style: pw.TextStyle(fontSize: 12, color: themeColor, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Simpan PDF ke folder Downloads
    String? filePath;
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final fileName = 'Sertifikat_${finalName}_${DateFormat('yyyyMMdd').format(completionDate)}.pdf';
      filePath = '${directory.path}/$fileName';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Sertifikat_${finalName}_${DateFormat('yyyyMMdd').format(completionDate)}.pdf';
      filePath = '${directory.path}/$fileName';
    }

    final file = File(filePath!);
    await file.writeAsBytes(await pdf.save());

    // Bagikan file
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Sertifikat Kelulusan Modul $courseName',
    );
  }
} 