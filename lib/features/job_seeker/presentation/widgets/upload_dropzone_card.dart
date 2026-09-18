import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Ensures a locally openable path exists for a picked file. The picker can
/// return a [PlatformFile] whose [PlatformFile.path] is null (content URIs),
/// so the bytes are copied into the temp dir in that case.
Future<String> _localPath(PlatformFile file) async {
  final p = file.path;
  if (p != null && p.isNotEmpty) return p;
  final tmp = File('${Directory.systemTemp.path}/${file.name}');
  await tmp.writeAsBytes(await file.readAsBytes(), flush: true);
  return tmp.path;
}

class ResumeUploadCard extends StatelessWidget {
  final String? fileName;
  final String? fileSize;
  final void Function(String name, String size, String path) onFileSelected;
  final VoidCallback onFileRemoved;

  const ResumeUploadCard({
    super.key,
    this.fileName,
    this.fileSize,
    required this.onFileSelected,
    required this.onFileRemoved,
  });

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
    );
    if (result.isNotEmpty) {
      final file = result.first;
      final path = await _localPath(file);
      final bytes = await file.length();
      final sizeMb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      onFileSelected(file.name, '$sizeMb MB', path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fileName ?? 'Upload your resume',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fileSize != null ? 'Size: $fileSize' : 'PDF, DOCX (Max 5MB)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(140, 42),
                ),
                child: const Text('Browse Files'),
              ),
              if (fileName != null && fileName!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: onFileRemoved,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(0, 42),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoUploadCard extends StatelessWidget {
  final String? videoName;
  final String? videoSize;
  final void Function(String name, String size, String path) onVideoSelected;
  final VoidCallback onVideoRemoved;

  const VideoUploadCard({
    super.key,
    this.videoName,
    this.videoSize,
    required this.onVideoSelected,
    required this.onVideoRemoved,
  });

  Future<void> _pickVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
    );
    if (result.isNotEmpty) {
      final file = result.first;
      final path = await _localPath(file);
      final bytes = await file.length();
      final sizeMb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      onVideoSelected(file.name, '$sizeMb MB', path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.videocam_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            videoName ?? 'Record / Upload Introduction Video',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            videoSize != null
                ? 'Size: $videoSize'
                : 'Upload a short video (MP4, MOV up to 50MB, max 2 mins) introducing yourself to potential employers, or record via camera.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('Browse Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(120, 42),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam, size: 16),
                label: const Text('Record Video'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: const Size(120, 42),
                ),
              ),
              if (videoName != null && videoName!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: onVideoRemoved,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: const Size(0, 42),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
