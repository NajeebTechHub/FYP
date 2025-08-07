import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';

import '../../models/certificate.dart';
import '../../widgets/certificate_widgets/certificate_template.dart';

class CertificatePreviewScreen extends StatefulWidget {
  final Certificate certificate;
  final String studentName;

  const CertificatePreviewScreen({
    Key? key,
    required this.certificate,
    required this.studentName,
  }) : super(key: key);

  @override
  State<CertificatePreviewScreen> createState() => _CertificatePreviewScreenState();
}

class _CertificatePreviewScreenState extends State<CertificatePreviewScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _downloadCertificate(BuildContext context) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to download the certificate.')),
        );
        return;
      }

      final image = await screenshotController.capture();
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture certificate.')),
        );
        return;
      }

      final fileName = '${widget.certificate.courseName}_${widget.certificate.id}.png';
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';

      final file = File(tempPath);
      await file.writeAsBytes(image);

      MediaStore.appFolder = 'MentorCraft';
      await MediaStore.ensureInitialized();

      final mediaStore = MediaStore();
      await mediaStore.saveFile(
        tempFilePath: tempPath,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  Future<void> _shareCertificate(BuildContext context) async {
    final image = await screenshotController.capture();
    if (image == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${widget.certificate.id}.png');
    await file.writeAsBytes(image);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Check out my certificate for ${widget.certificate.courseName}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(widget.certificate.issueDate);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                child: CertificateTemplate(
                  courseName: widget.certificate.courseName,
                  studentName: widget.studentName,
                  issueDate: formattedDate,
                  certificateId: widget.certificate.id,
                  instructor: widget.certificate.instructor,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDark
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certificate Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Course', widget.certificate.courseName, theme),
                    _buildDetailRow('Category', widget.certificate.category, theme),
                    _buildDetailRow('Instructor', widget.certificate.instructor, theme),
                    _buildDetailRow('Date of Issue', formattedDate, theme),
                    _buildDetailRow('Certificate ID', widget.certificate.id, theme),
                    _buildDetailRow('Status', widget.certificate.getStatusText(), theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadCertificate(context),
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                        side: BorderSide(color: AppColors.darkBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareCertificate(context),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textFaded : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
